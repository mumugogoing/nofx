#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# NOFX Config.json Security Setup Script
# ═══════════════════════════════════════════════════════════════
# 
# 此脚本帮助您安全地设置和保护 config.json 文件
# This script helps you securely setup and protect config.json
#
# 使用方法 / Usage:
#   ./secure-config.sh
# ═══════════════════════════════════════════════════════════════

set -e  # Exit on error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  🔐 NOFX Config Security Setup                            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

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

check_config_exists() {
    if [ ! -f "config.json" ]; then
        print_error "config.json not found!"
        if [ -f "config.json.example" ]; then
            print_info "Creating config.json from config.json.example..."
            cp config.json.example config.json
            print_warning "Please edit config.json with your actual API keys"
            return 1
        else
            print_error "config.json.example not found either!"
            exit 1
        fi
    fi
    return 0
}

check_permissions() {
    local perms=$(stat -c "%a" config.json 2>/dev/null || stat -f "%A" config.json 2>/dev/null)
    echo "$perms"
}

set_secure_permissions() {
    print_info "Setting secure permissions on config.json..."
    
    # Set file ownership to current user
    if [ "$(uname)" = "Linux" ]; then
        chown $(whoami):$(whoami) config.json 2>/dev/null || true
    fi
    
    # Set permissions to 600 (read/write for owner only)
    chmod 600 config.json
    
    local new_perms=$(check_permissions)
    if [ "$new_perms" = "600" ]; then
        print_success "Permissions set to 600 (owner read/write only)"
    else
        print_warning "Permissions set, but verification shows: $new_perms"
    fi
}

check_gitignore() {
    if [ -f ".gitignore" ]; then
        if grep -q "^config.json$" .gitignore; then
            print_success "config.json is in .gitignore"
            return 0
        else
            print_warning "config.json not found in .gitignore"
            return 1
        fi
    else
        print_warning ".gitignore not found"
        return 1
    fi
}

add_to_gitignore() {
    print_info "Adding config.json to .gitignore..."
    if [ ! -f ".gitignore" ]; then
        echo "config.json" > .gitignore
    else
        echo "config.json" >> .gitignore
    fi
    print_success "Added config.json to .gitignore"
}

check_git_status() {
    if command -v git &> /dev/null && [ -d ".git" ]; then
        if git ls-files --error-unmatch config.json &> /dev/null; then
            print_error "WARNING: config.json is tracked by Git!"
            print_warning "You should remove it from Git history:"
            echo ""
            echo "  git rm --cached config.json"
            echo "  git commit -m 'Remove config.json from repository'"
            echo ""
            return 1
        else
            print_success "config.json is not tracked by Git"
            return 0
        fi
    fi
    return 0
}

create_backup() {
    local backup_dir="./backups"
    local backup_file="config.json.backup.$(date +%Y%m%d_%H%M%S)"
    
    print_info "Creating backup..."
    
    mkdir -p "$backup_dir"
    chmod 700 "$backup_dir"
    
    cp config.json "$backup_dir/$backup_file"
    chmod 600 "$backup_dir/$backup_file"
    
    print_success "Backup created: $backup_dir/$backup_file"
}

verify_docker_compose() {
    if [ -f "docker-compose.yml" ]; then
        if grep -q "config.json:/app/config.json:ro" docker-compose.yml; then
            print_success "Docker Compose uses read-only mount (:ro) ✓"
        else
            print_warning "Docker Compose config.json mount should use :ro flag for security"
            echo "  Current: ./config.json:/app/config.json"
            echo "  Recommended: ./config.json:/app/config.json:ro"
        fi
    fi
}

check_sensitive_data() {
    print_info "Checking for placeholder/example API keys..."
    
    local placeholders=(
        "your_binance_api_key"
        "your_binance_secret_key"
        "your_deepseek_api_key"
        "your_qwen_api_key"
        "your_ethereum_private_key"
        "your_aster_api_wallet_private_key"
        "YOUR_BINANCE_API_KEY"
        "YOUR_DEEPSEEK_API_KEY"
    )
    
    local found_placeholder=0
    for placeholder in "${placeholders[@]}"; do
        if grep -q "$placeholder" config.json; then
            print_warning "Found placeholder: $placeholder"
            found_placeholder=1
        fi
    done
    
    if [ $found_placeholder -eq 1 ]; then
        print_error "Placeholder API keys detected!"
        print_warning "Please replace all placeholder values with real API keys"
        return 1
    else
        print_success "No placeholder API keys found"
        return 0
    fi
}

show_security_summary() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  Security Configuration Summary${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    local perms=$(check_permissions)
    echo "📁 File: config.json"
    echo "🔒 Permissions: $perms"
    echo "👤 Owner: $(stat -c "%U" config.json 2>/dev/null || stat -f "%Su" config.json 2>/dev/null)"
    echo ""
    
    echo "Security Checklist:"
    check_gitignore && echo "  ✓ In .gitignore" || echo "  ✗ Not in .gitignore"
    check_git_status && echo "  ✓ Not in Git" || echo "  ✗ Tracked by Git"
    [ "$perms" = "600" ] && echo "  ✓ Secure permissions (600)" || echo "  ⚠ Permissions: $perms"
    verify_docker_compose
    echo ""
}

main() {
    print_header
    
    # Check if config.json exists
    if ! check_config_exists; then
        exit 1
    fi
    
    # Current permissions
    local current_perms=$(check_permissions)
    print_info "Current permissions: $current_perms"
    
    # Create backup before making changes
    create_backup
    
    # Set secure permissions
    set_secure_permissions
    
    # Check .gitignore
    if ! check_gitignore; then
        read -p "Add config.json to .gitignore? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            add_to_gitignore
        fi
    fi
    
    # Check Git status
    check_git_status
    
    # Check for placeholder values
    check_sensitive_data
    
    # Verify Docker Compose configuration
    verify_docker_compose
    
    # Show summary
    show_security_summary
    
    echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    print_success "Security setup complete!"
    echo ""
    print_info "Additional security recommendations:"
    echo "  1. Never commit config.json to Git"
    echo "  2. Regularly rotate your API keys (every 3-6 months)"
    echo "  3. Use minimal API key permissions (only enable what you need)"
    echo "  4. Keep backups in a secure location"
    echo "  5. Monitor your API key usage for suspicious activity"
    echo ""
    print_info "For more details, see: CONFIG_SECURITY_GUIDE.md"
    echo ""
}

# Run main function
main
