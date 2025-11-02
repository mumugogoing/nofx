# 🚀 部署到远程服务器（阿里云/腾讯云/AWS等）

快速将NOFX部署到你的远程服务器Docker环境。

## ⚠️ 安全第一

**重要：永远不要将服务器密码提交到Git！**

本项目提供安全的部署方案：
- ✅ 支持SSH密钥认证（推荐）
- ✅ 配置文件不会被提交到Git
- ✅ 支持命令行传参和配置文件两种方式

## 📦 三种部署方式

### 方式一：自动部署（最简单）

```bash
# 1. 准备配置
cp config.json.example config.json
nano config.json  # 填入API密钥

# 2. 一键部署（需要输入服务器密码）
./deploy.sh 你的服务器IP root

# 示例：
./deploy.sh 47.108.148.251 root
```

### 方式二：使用配置文件（推荐）

```bash
# 1. 创建部署配置
cp deploy-config.example.sh deploy-config.sh
nano deploy-config.sh  # 填入服务器信息

# 2. 准备项目配置
cp config.json.example config.json
nano config.json  # 填入API密钥

# 3. 一键部署
./deploy.sh
```

### 方式三：SSH密钥认证（最安全）

```bash
# 1. 生成SSH密钥（如果没有）
ssh-keygen -t rsa -b 4096

# 2. 复制公钥到服务器（需要输入一次密码）
ssh-copy-id root@你的服务器IP

# 3. 无密码部署
./deploy.sh 你的服务器IP root
```

## 🎯 部署后访问

- **Web界面**: http://你的服务器IP:3000
- **API服务**: http://你的服务器IP:8080

## 📋 常用管理命令

```bash
# 查看状态
ssh root@你的IP 'cd /opt/nofx && docker compose ps'

# 查看日志
ssh root@你的IP 'cd /opt/nofx && docker compose logs -f'

# 重启服务
ssh root@你的IP 'cd /opt/nofx && docker compose restart'

# 停止服务
ssh root@你的IP 'cd /opt/nofx && docker compose down'
```

## 📚 详细文档

- [完整部署指南](REMOTE_DEPLOY.md) - 包含故障排查、安全加固等
- [阿里云专用指南](阿里云部署指南.md) - 阿里云特定配置
- [Docker部署文档](DOCKER_DEPLOY.md) - 本地Docker部署

## 🔒 安全建议

1. **使用SSH密钥**而不是密码登录
2. **配置防火墙**只开放必要端口
3. **定期更新**系统和Docker
4. **备份数据**定期备份配置和日志

## 🆘 遇到问题？

查看[故障排查指南](REMOTE_DEPLOY.md#-故障排查)或加入[Telegram社区](https://t.me/nofx_dev_community)

---

**提示：** 部署脚本会自动检查并安装Docker，无需手动配置！
