#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# NOFX Remote Docker Deployment Script
# ═══════════════════════════════════════════════════════════════
# This script deploys the NOFX project to a remote server via SSH
# 
# Usage:
#   ./deploy-remote.sh <server_ip> <ssh_user> [ssh_port]
#
# Example:
#   ./deploy-remote.sh 47.108.148.251 root
#   ./deploy-remote.sh 47.108.148.251 root 22
#
# Security:
#   - Never hardcode passwords in this script
#   - Use SSH key authentication (recommended) or password prompt
#   - Credentials are never committed to git
# ═══════════════════════════════════════════════════════════════

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  🚀 NOFX Remote Docker Deployment                         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Load deployment configuration if exists
if [ -f "deploy-config.sh" ]; then
    print_info "Loading configuration from deploy-config.sh..."
    source deploy-config.sh
fi

# Parse arguments (command line arguments override config file)
if [ $# -ge 2 ]; then
    SERVER_IP=$1
    SSH_USER=$2
    SSH_PORT=${3:-22}
elif [ -n "$DEPLOY_SERVER_IP" ] && [ -n "$DEPLOY_SSH_USER" ]; then
    # Use configuration from deploy-config.sh
    SERVER_IP=$DEPLOY_SERVER_IP
    SSH_USER=$DEPLOY_SSH_USER
    SSH_PORT=${DEPLOY_SSH_PORT:-22}
else
    print_error "Usage: $0 <server_ip> <ssh_user> [ssh_port]"
    echo ""
    echo "Or create deploy-config.sh from deploy-config.example.sh"
    echo ""
    echo "Example:"
    echo "  $0 47.108.148.251 root"
    echo "  $0 47.108.148.251 root 22"
    exit 1
fi

REMOTE_DIR="${DEPLOY_REMOTE_DIR:-/opt/nofx}"
PROJECT_NAME="nofx"

print_header

print_info "Deployment Configuration:"
echo "  Server IP: ${SERVER_IP}"
echo "  SSH User: ${SSH_USER}"
echo "  SSH Port: ${SSH_PORT}"
echo "  Remote Directory: ${REMOTE_DIR}"
echo ""

# Check if local files exist
print_info "Checking local files..."
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found in current directory"
    exit 1
fi

if [ ! -f "config.json" ]; then
    if [ ! -f "config.json.example" ]; then
        print_error "Neither config.json nor config.json.example found"
        exit 1
    fi
    print_warning "config.json not found. Please create it from config.json.example"
    print_info "Creating config.json from config.json.example..."
    cp config.json.example config.json
    print_warning "Please edit config.json with your API keys before deploying"
    read -p "Press Enter to continue after editing config.json, or Ctrl+C to cancel..."
fi

print_success "Local files validated"

# Test SSH connection
print_info "Testing SSH connection to ${SSH_USER}@${SERVER_IP}:${SSH_PORT}..."
if ssh -p ${SSH_PORT} -o ConnectTimeout=10 -o BatchMode=yes ${SSH_USER}@${SERVER_IP} "echo 'SSH connection successful'" 2>/dev/null; then
    print_success "SSH connection successful (using SSH key)"
else
    print_warning "SSH key authentication failed, will use password authentication"
    print_info "You will be prompted for password during deployment"
fi

# Check if Docker is installed on remote server
print_info "Checking Docker installation on remote server..."
if ssh -p ${SSH_PORT} ${SSH_USER}@${SERVER_IP} "command -v docker &> /dev/null"; then
    print_success "Docker is installed on remote server"
else
    print_warning "Docker not found on remote server"
    read -p "Do you want to install Docker on the remote server? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing Docker on remote server..."
        ssh -p ${SSH_PORT} ${SSH_USER}@${SERVER_IP} << 'ENDSSH'
            set -e
            # Install Docker
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            
            # Start Docker service
            systemctl enable docker
            systemctl start docker
            
            # Clean up
            rm get-docker.sh
            
            echo "Docker installation completed"
ENDSSH
        print_success "Docker installed successfully"
    else
        print_error "Docker is required for deployment. Exiting..."
        exit 1
    fi
fi

# Check Docker Compose
print_info "Checking Docker Compose on remote server..."
if ! ssh -p ${SSH_PORT} ${SSH_USER}@${SERVER_IP} "docker compose version &> /dev/null"; then
    print_error "Docker Compose not available on remote server"
    print_info "Please ensure Docker version 20.10+ is installed (includes compose)"
    exit 1
fi
print_success "Docker Compose is available"

# Create remote directory
print_info "Creating remote directory ${REMOTE_DIR}..."
ssh -p ${SSH_PORT} ${SSH_USER}@${SERVER_IP} "mkdir -p ${REMOTE_DIR}"
print_success "Remote directory created"

# Sync project files to remote server
print_info "Syncing project files to remote server..."
rsync -avz --progress \
    -e "ssh -p ${SSH_PORT}" \
    --exclude '.git' \
    --exclude '.github' \
    --exclude 'node_modules' \
    --exclude 'web/node_modules' \
    --exclude 'web/dist' \
    --exclude 'decision_logs' \
    --exclude 'coin_pool_cache' \
    --exclude '.env' \
    ./ ${SSH_USER}@${SERVER_IP}:${REMOTE_DIR}/

print_success "Project files synced"

# Deploy with Docker Compose
print_info "Deploying with Docker Compose on remote server..."
ssh -p ${SSH_PORT} ${SSH_USER}@${SERVER_IP} << ENDSSH
    set -e
    cd ${REMOTE_DIR}
    
    echo "Stopping existing containers (if any)..."
    docker compose down || true
    
    echo "Building and starting containers..."
    docker compose up -d --build
    
    echo "Waiting for services to be healthy..."
    sleep 10
    
    echo "Checking container status..."
    docker compose ps
    
    echo ""
    echo "Deployment completed successfully!"
ENDSSH

print_success "Deployment completed!"

# Display access information
echo ""
print_header
echo -e "${GREEN}🎉 Deployment Successful!${NC}"
echo ""
echo "Access your application at:"
echo "  📱 Web Interface: http://${SERVER_IP}:3000"
echo "  🔧 API Server: http://${SERVER_IP}:8080"
echo "  💚 Health Check: http://${SERVER_IP}:8080/health"
echo ""
echo "Useful commands:"
echo "  📊 View logs: ssh -p ${SSH_PORT} ${SSH_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose logs -f'"
echo "  🔄 Restart: ssh -p ${SSH_PORT} ${SSH_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose restart'"
echo "  🛑 Stop: ssh -p ${SSH_PORT} ${SSH_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose down'"
echo "  📈 Status: ssh -p ${SSH_PORT} ${SSH_USER}@${SERVER_IP} 'cd ${REMOTE_DIR} && docker compose ps'"
echo ""
print_warning "Important: Make sure to configure your firewall to allow ports 3000 and 8080"
print_warning "Remember to update config.json with your actual API keys on the remote server"
echo ""
