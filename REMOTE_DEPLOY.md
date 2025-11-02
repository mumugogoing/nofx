# 🚀 远程服务器Docker部署指南

本指南将帮助你将NOFX项目部署到远程服务器的Docker环境中。

## 📋 前置要求

### 本地机器
- SSH客户端
- rsync（用于文件同步）
- Git（用于克隆项目）

### 远程服务器
- Linux操作系统（推荐Ubuntu 20.04+或CentOS 7+）
- Root或sudo权限
- 至少2GB内存
- 至少10GB可用磁盘空间
- 开放端口：3000（Web界面）、8080（API服务）、22（SSH）

## 🔐 安全最佳实践

**⚠️ 重要安全提示：**

1. **永远不要**将服务器密码提交到Git仓库
2. **强烈推荐**使用SSH密钥认证而不是密码
3. **务必**在部署后更改默认密码
4. **建议**配置防火墙只允许必要的端口访问
5. **建议**使用非root用户进行部署

### 配置SSH密钥认证（推荐）

```bash
# 在本地机器生成SSH密钥（如果还没有）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 将公钥复制到远程服务器
ssh-copy-id -p 22 root@你的服务器IP

# 测试SSH连接（不需要密码）
ssh root@你的服务器IP
```

## 📦 快速部署

### 方法一：使用自动部署脚本（推荐）

1. **克隆项目到本地**

```bash
git clone https://github.com/mumugogoing/nofx.git
cd nofx
```

2. **配置config.json**

```bash
# 复制配置文件模板
cp config.json.example config.json

# 编辑配置文件，填入你的API密钥
nano config.json  # 或使用vim、vscode等编辑器
```

**必须配置的字段：**
```json
{
  "traders": [
    {
      "id": "my_trader",
      "name": "My AI Trader",
      "ai_model": "deepseek",
      "binance_api_key": "你的币安API_KEY",
      "binance_secret_key": "你的币安SECRET_KEY",
      "deepseek_key": "你的DeepSeek_API_KEY",
      "initial_balance": 1000.0,
      "scan_interval_minutes": 3
    }
  ],
  "use_default_coins": true,
  "api_server_port": 8080
}
```

3. **运行部署脚本**

```bash
# 使脚本可执行
chmod +x deploy-remote.sh

# 部署到远程服务器
./deploy-remote.sh 你的服务器IP root

# 示例：
# ./deploy-remote.sh 47.108.148.251 root
```

脚本会自动：
- ✅ 检查SSH连接
- ✅ 检查并安装Docker（如需要）
- ✅ 同步项目文件到服务器
- ✅ 构建并启动Docker容器
- ✅ 显示访问地址和管理命令

4. **访问应用**

部署成功后，打开浏览器访问：
- **Web界面**: http://你的服务器IP:3000
- **API服务**: http://你的服务器IP:8080/health

### 方法二：手动部署

如果自动部署脚本遇到问题，可以手动部署：

1. **连接到服务器**

```bash
ssh root@你的服务器IP
```

2. **安装Docker（如果未安装）**

```bash
# 下载并运行Docker安装脚本
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 启动Docker服务
systemctl enable docker
systemctl start docker

# 验证安装
docker --version
docker compose version
```

3. **克隆项目**

```bash
# 创建项目目录
mkdir -p /opt/nofx
cd /opt/nofx

# 克隆项目
git clone https://github.com/mumugogoing/nofx.git .
```

4. **配置项目**

```bash
# 复制配置文件
cp config.json.example config.json

# 编辑配置文件
nano config.json
```

5. **启动服务**

```bash
# 构建并启动容器
docker compose up -d --build

# 查看容器状态
docker compose ps

# 查看日志
docker compose logs -f
```

## 🔧 服务管理

### 查看状态

```bash
ssh root@服务器IP 'cd /opt/nofx && docker compose ps'
```

### 查看日志

```bash
# 实时查看所有日志
ssh root@服务器IP 'cd /opt/nofx && docker compose logs -f'

# 只查看后端日志
ssh root@服务器IP 'cd /opt/nofx && docker compose logs -f nofx'

# 只查看前端日志
ssh root@服务器IP 'cd /opt/nofx && docker compose logs -f nofx-frontend'
```

### 重启服务

```bash
# 重启所有服务
ssh root@服务器IP 'cd /opt/nofx && docker compose restart'

# 只重启后端
ssh root@服务器IP 'cd /opt/nofx && docker compose restart nofx'
```

### 停止服务

```bash
# 停止所有服务
ssh root@服务器IP 'cd /opt/nofx && docker compose down'

# 停止并删除数据
ssh root@服务器IP 'cd /opt/nofx && docker compose down -v'
```

### 更新应用

```bash
# SSH到服务器
ssh root@服务器IP

# 进入项目目录
cd /opt/nofx

# 拉取最新代码
git pull

# 重新构建并启动
docker compose up -d --build
```

## 🛡️ 防火墙配置

### 使用UFW（Ubuntu）

```bash
# 允许SSH
sudo ufw allow 22/tcp

# 允许Web界面
sudo ufw allow 3000/tcp

# 允许API服务
sudo ufw allow 8080/tcp

# 启用防火墙
sudo ufw enable

# 查看状态
sudo ufw status
```

### 使用firewalld（CentOS/RHEL）

```bash
# 允许端口
sudo firewall-cmd --permanent --add-port=22/tcp
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=8080/tcp

# 重载防火墙
sudo firewall-cmd --reload

# 查看状态
sudo firewall-cmd --list-all
```

### 阿里云安全组配置

如果使用阿里云ECS，需要在控制台配置安全组规则：

1. 登录阿里云控制台
2. 进入 ECS 实例管理
3. 点击"安全组" -> "配置规则"
4. 添加入方向规则：
   - 端口范围：22/22（SSH）
   - 端口范围：3000/3000（Web界面）
   - 端口范围：8080/8080（API服务）
   - 授权对象：0.0.0.0/0（或指定IP）

## 🐛 故障排查

### 无法连接到服务器

```bash
# 检查SSH连接
ssh -v root@服务器IP

# 检查服务器是否在线
ping 服务器IP

# 检查端口是否开放
nc -zv 服务器IP 22
```

### Docker服务无法启动

```bash
# 检查Docker状态
systemctl status docker

# 重启Docker服务
systemctl restart docker

# 查看Docker日志
journalctl -u docker -f
```

### 容器无法启动

```bash
# 查看容器日志
docker compose logs nofx
docker compose logs nofx-frontend

# 检查容器状态
docker compose ps -a

# 重新构建镜像
docker compose build --no-cache
docker compose up -d
```

### 端口被占用

```bash
# 查找占用端口的进程
lsof -i :3000
lsof -i :8080

# 或使用netstat
netstat -tlnp | grep :3000
netstat -tlnp | grep :8080

# 停止占用端口的进程
kill -9 <PID>
```

### 配置文件问题

```bash
# 验证JSON格式
cat config.json | python -m json.tool

# 或使用jq
cat config.json | jq .
```

## 📊 监控和维护

### 查看系统资源使用

```bash
# CPU和内存使用
docker stats

# 磁盘使用
df -h

# Docker资源使用
docker system df
```

### 清理Docker资源

```bash
# 清理未使用的镜像
docker image prune -a

# 清理未使用的卷
docker volume prune

# 清理所有未使用的资源
docker system prune -a
```

### 备份数据

```bash
# 备份配置和日志
tar -czf nofx-backup-$(date +%Y%m%d).tar.gz \
    /opt/nofx/config.json \
    /opt/nofx/decision_logs

# 下载备份到本地
scp root@服务器IP:/opt/nofx/nofx-backup-*.tar.gz ./
```

## 🔒 安全加固建议

1. **更改SSH端口**
```bash
# 编辑SSH配置
sudo nano /etc/ssh/sshd_config
# 将Port 22改为其他端口，如Port 2222

# 重启SSH服务
sudo systemctl restart sshd
```

2. **禁用root密码登录**
```bash
# 编辑SSH配置
sudo nano /etc/ssh/sshd_config
# 设置：PermitRootLogin prohibit-password

# 重启SSH服务
sudo systemctl restart sshd
```

3. **配置fail2ban防止暴力破解**
```bash
# 安装fail2ban
sudo apt-get install fail2ban

# 启动服务
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

4. **定期更新系统**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

## 📞 获取帮助

如果遇到问题：

1. 查看[故障排查](#-故障排查)部分
2. 查看项目的[GitHub Issues](https://github.com/mumugogoing/nofx/issues)
3. 加入[Telegram开发者社区](https://t.me/nofx_dev_community)

## 📝 常用命令速查

```bash
# 部署
./deploy-remote.sh 服务器IP root

# 查看状态
ssh root@服务器IP 'cd /opt/nofx && docker compose ps'

# 查看日志
ssh root@服务器IP 'cd /opt/nofx && docker compose logs -f'

# 重启服务
ssh root@服务器IP 'cd /opt/nofx && docker compose restart'

# 停止服务
ssh root@服务器IP 'cd /opt/nofx && docker compose down'

# 更新服务
ssh root@服务器IP 'cd /opt/nofx && git pull && docker compose up -d --build'
```

---

🎉 恭喜！你已经成功部署了NOFX AI交易竞赛系统到远程服务器！
