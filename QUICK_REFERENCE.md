# 🚀 部署快速参考卡

## 一分钟快速部署

```bash
# 1. 克隆项目
git clone https://github.com/mumugogoing/nofx.git && cd nofx

# 2. 配置API
cp config.json.example config.json && nano config.json

# 3. 部署到服务器
./deploy.sh YOUR_SERVER_IP root
```

## 三种部署方式

| 方式 | 命令 | 适用场景 |
|------|------|---------|
| **本地Docker** | `docker compose up -d --build` | 本地开发测试 |
| **远程服务器** | `./deploy.sh SERVER_IP root` | 云服务器部署 |
| **手动部署** | 参考 [PM2_DEPLOYMENT.md](PM2_DEPLOYMENT.md) | 定制化需求 |

## 常用命令

```bash
# 部署
./deploy.sh SERVER_IP root

# 查看状态
ssh root@SERVER_IP 'cd /opt/nofx && docker compose ps'

# 查看日志
ssh root@SERVER_IP 'cd /opt/nofx && docker compose logs -f'

# 重启
ssh root@SERVER_IP 'cd /opt/nofx && docker compose restart'

# 停止
ssh root@SERVER_IP 'cd /opt/nofx && docker compose down'

# 更新
ssh root@SERVER_IP 'cd /opt/nofx && git pull && docker compose up -d --build'
```

## 访问地址

- **Web界面**: http://SERVER_IP:3000
- **API服务**: http://SERVER_IP:8080
- **健康检查**: http://SERVER_IP:8080/health

## 详细文档

| 文档 | 用途 |
|------|------|
| [DEPLOY_QUICK_START.md](DEPLOY_QUICK_START.md) | 快速开始指南 |
| [DEPLOYMENT_TUTORIAL.md](DEPLOYMENT_TUTORIAL.md) | 完整部署教程 |
| [REMOTE_DEPLOY.md](REMOTE_DEPLOY.md) | 远程部署详解 |
| [DOCKER_DEPLOY.md](DOCKER_DEPLOY.md) | Docker本地部署 |
| [SECURITY_NOTICE.md](SECURITY_NOTICE.md) | 安全注意事项 |
| [阿里云部署指南.md](阿里云部署指南.md) | 阿里云专用 |

## 故障排查

| 问题 | 解决方案 |
|------|---------|
| SSH连接失败 | `ssh -v root@SERVER_IP` 查看详细错误 |
| 端口无法访问 | 检查防火墙和安全组配置 |
| 容器启动失败 | `docker compose logs` 查看日志 |
| 配置文件错误 | `cat config.json \| jq .` 验证JSON |

## 安全检查清单

- [ ] 使用SSH密钥认证
- [ ] 配置防火墙规则
- [ ] API密钥已正确配置
- [ ] 不将密码提交到Git
- [ ] 定期更新系统和Docker

## 获取帮助

- 📖 [完整文档](README.md)
- 💬 [Telegram社区](https://t.me/nofx_dev_community)
- 🐛 [提交Issue](https://github.com/mumugogoing/nofx/issues)

---

**提示**: 首次部署建议先阅读 [DEPLOYMENT_TUTORIAL.md](DEPLOYMENT_TUTORIAL.md)
