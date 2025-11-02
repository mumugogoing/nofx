# ⚠️ 重要安全提示 / Important Security Notice

## 🔐 关于服务器凭证安全 / About Server Credentials Security

### ❌ 绝对不要做的事情 / Never Do These:

1. **不要将服务器密码提交到Git仓库**
   - Never commit server passwords to Git repositories

2. **不要在公开场合分享服务器IP和密码**
   - Never share server IP and passwords in public places

3. **不要在Issue、PR或聊天中发送密码**
   - Never send passwords in Issues, PRs, or chats

4. **不要将密码硬编码在代码或脚本中**
   - Never hardcode passwords in code or scripts

5. **不要使用简单或默认密码**
   - Never use simple or default passwords

### ✅ 应该做的事情 / Best Practices:

1. **使用SSH密钥认证**
   ```bash
   ssh-keygen -t rsa -b 4096
   ssh-copy-id user@server
   ```

2. **使用强密码并定期更换**
   - Use strong passwords and change them regularly

3. **使用密码管理器存储凭证**
   - Use password managers to store credentials

4. **使用环境变量或配置文件（不提交到Git）**
   ```bash
   # .gitignore中已包含
   .env
   config.json
   deploy-config.sh
   *.pem
   *.key
   ```

5. **配置防火墙只允许必要的端口**
   ```bash
   # 只开放必要端口
   ufw allow 22/tcp    # SSH
   ufw allow 3000/tcp  # Web
   ufw allow 8080/tcp  # API
   ```

6. **启用SSH密钥认证后禁用密码登录**
   ```bash
   # /etc/ssh/sshd_config
   PasswordAuthentication no
   PubkeyAuthentication yes
   ```

## 🛡️ 如果凭证已经泄露 / If Credentials Are Compromised:

### 立即行动 / Immediate Actions:

1. **更改所有密码**
   ```bash
   ssh root@server
   passwd  # 更改root密码
   ```

2. **检查异常登录**
   ```bash
   # 查看最近的登录记录
   last
   lastlog
   
   # 查看当前登录用户
   who
   w
   ```

3. **检查可疑进程**
   ```bash
   # 查看所有进程
   ps aux
   
   # 查看网络连接
   netstat -tuln
   ```

4. **更新SSH密钥**
   ```bash
   # 删除旧的authorized_keys
   rm ~/.ssh/authorized_keys
   
   # 重新添加可信的公钥
   ssh-copy-id user@server
   ```

5. **检查并清理crontab**
   ```bash
   crontab -l  # 查看定时任务
   crontab -e  # 编辑定时任务
   ```

6. **备份重要数据**
   ```bash
   # 备份配置和日志
   tar -czf backup.tar.gz /opt/nofx/config.json /opt/nofx/decision_logs/
   ```

## 📋 安全检查清单 / Security Checklist:

- [ ] SSH密钥认证已配置
- [ ] 密码登录已禁用
- [ ] 使用非root用户（推荐）
- [ ] SSH端口已更改（可选但推荐）
- [ ] 防火墙已配置
- [ ] fail2ban已安装（防止暴力破解）
- [ ] 定期更新系统
- [ ] 定期备份数据
- [ ] 监控日志文件
- [ ] API密钥定期轮换

## 🔑 推荐的部署流程 / Recommended Deployment Process:

```bash
# 1. 生成SSH密钥（如果没有）
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 2. 复制公钥到服务器（需要输入一次密码）
ssh-copy-id root@YOUR_SERVER_IP

# 3. 测试SSH密钥登录（应该无需密码）
ssh root@YOUR_SERVER_IP

# 4. 准备项目配置
cd nofx
cp config.json.example config.json
nano config.json  # 填入API密钥

# 5. 部署（无需输入密码）
./deploy.sh YOUR_SERVER_IP root

# 6. 登录服务器禁用密码认证
ssh root@YOUR_SERVER_IP
nano /etc/ssh/sshd_config
# 设置: PasswordAuthentication no
systemctl restart sshd
```

## 📚 更多资源 / More Resources:

- [SSH密钥认证指南](https://www.ssh.com/academy/ssh/public-key-authentication)
- [服务器安全加固指南](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-20-04)
- [密码安全最佳实践](https://www.ncsc.gov.uk/collection/passwords)

## 🆘 紧急联系 / Emergency Contact:

如果发现安全问题或需要帮助，请：
- 提交安全相关的[GitHub Issue](https://github.com/mumugogoing/nofx/issues)（不要包含敏感信息）
- 加入[Telegram社区](https://t.me/nofx_dev_community)寻求帮助

---

**记住：安全第一！Never share your credentials!**

