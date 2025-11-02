# 🔐 config.json 安全配置指南

本指南详细说明如何安全地管理和保护 `config.json` 配置文件。

## 📋 当前安全架构

### ✅ 已实现的安全措施

1. **配置文件在Docker外部**
   - `config.json` 通过卷挂载的方式映射到容器内
   - 文件实际存储在宿主机，不包含在Docker镜像中
   - Docker Compose配置：`./config.json:/app/config.json:ro`

2. **只读挂载（:ro）**
   - 容器内部**无法修改**配置文件
   - 防止容器被入侵后修改配置
   - 只能从宿主机更新配置

3. **Git忽略**
   - `.gitignore` 已包含 `config.json`
   - 配置文件永远不会被提交到Git仓库
   - 防止敏感信息泄露到版本控制系统

## 🛡️ 强化安全措施

### 1. 文件权限控制

推荐的文件权限设置：

```bash
# 设置config.json为仅所有者可读写
chmod 600 config.json

# 验证权限
ls -l config.json
# 输出应为: -rw------- 1 user user ... config.json

# 如果使用root用户运行Docker
sudo chown root:root config.json
sudo chmod 600 config.json
```

**权限说明：**
- `600` = 仅所有者可读写
- `400` = 仅所有者可读（更严格，但需要修改时需临时改权限）

### 2. 配置文件加密（可选）

对于极高安全要求的场景，可以加密存储配置文件：

#### 方法A：使用GPG加密

```bash
# 1. 加密配置文件
gpg -c config.json
# 输入密码后生成 config.json.gpg

# 2. 删除原始文件
rm config.json

# 3. 使用时解密
gpg -d config.json.gpg > config.json

# 4. 使用完毕后删除明文
rm config.json
```

#### 方法B：使用git-crypt（适合团队）

```bash
# 1. 安装git-crypt
brew install git-crypt  # macOS
apt-get install git-crypt  # Ubuntu

# 2. 在仓库中初始化
cd /path/to/nofx
git-crypt init

# 3. 配置加密规则（.gitattributes）
echo "config.json filter=git-crypt diff=git-crypt" >> .gitattributes

# 4. 添加团队成员的GPG密钥
git-crypt add-gpg-user USER_GPG_KEY
```

### 3. 使用环境变量（推荐用于敏感字段）

创建 `.env` 文件存储最敏感的信息：

```bash
# .env 文件示例
BINANCE_API_KEY=your_actual_binance_api_key
BINANCE_SECRET_KEY=your_actual_binance_secret_key
DEEPSEEK_API_KEY=your_actual_deepseek_api_key
HYPERLIQUID_PRIVATE_KEY=your_ethereum_private_key
ASTER_PRIVATE_KEY=your_aster_private_key
```

修改 `config.json` 使用占位符：

```json
{
  "traders": [
    {
      "id": "binance_trader",
      "binance_api_key": "${BINANCE_API_KEY}",
      "binance_secret_key": "${BINANCE_SECRET_KEY}",
      "deepseek_key": "${DEEPSEEK_API_KEY}"
    }
  ]
}
```

**注意：** 这需要应用程序支持环境变量替换。如果不支持，继续使用当前方式。

### 4. 配置文件分离（推荐）

将敏感配置和非敏感配置分离：

```bash
# 创建配置目录
mkdir -p /opt/nofx/config

# 非敏感配置（可提交到Git）
config/
├── base.json          # 基础配置
├── trading.json       # 交易策略配置
└── secrets.json       # 敏感信息（gitignore）

# .gitignore 中添加
config/secrets.json
```

### 5. 密钥轮换策略

定期更换API密钥：

```bash
# 1. 备份当前配置
cp config.json config.json.backup.$(date +%Y%m%d)

# 2. 在交易所生成新的API密钥

# 3. 更新config.json

# 4. 重启服务
docker compose restart

# 5. 在交易所禁用旧API密钥

# 6. 安全删除备份（7天后）
# shred -u config.json.backup.*  # Linux
# srm config.json.backup.*       # macOS (需要安装)
```

## 🗂️ 推荐的目录结构

```bash
/opt/nofx/                          # 主目录
├── config.json                     # 主配置文件（600权限）
├── .env                            # 环境变量（600权限）
├── docker-compose.yml              # Docker配置
├── decision_logs/                  # 日志目录（700权限）
│   └── *.log
└── backups/                        # 备份目录（700权限）
    ├── config.json.20250101
    └── config.json.20250102
```

## 🔒 服务器级安全

### 1. 配置防火墙

```bash
# 只允许必要的端口
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 3000/tcp  # Web界面
sudo ufw allow 8080/tcp  # API服务
sudo ufw enable

# 限制SSH访问（可选）
sudo ufw limit 22/tcp    # 限制SSH连接频率
```

### 2. 使用专用用户运行

```bash
# 创建专用用户
sudo useradd -m -s /bin/bash nofx
sudo usermod -aG docker nofx

# 设置配置文件所有权
sudo chown nofx:nofx /opt/nofx/config.json
sudo chmod 600 /opt/nofx/config.json

# 切换到专用用户运行
sudo -u nofx docker compose up -d
```

### 3. 启用审计日志

```bash
# 监控config.json的访问
sudo auditctl -w /opt/nofx/config.json -p rwa -k nofx_config

# 查看审计日志
sudo ausearch -k nofx_config
```

### 4. 配置文件完整性监控

```bash
# 使用AIDE监控文件变化
sudo apt-get install aide

# 初始化数据库
sudo aideinit

# 添加监控规则 /etc/aide/aide.conf
/opt/nofx/config.json R+b+sha256

# 检查文件变化
sudo aide --check
```

## 📦 Docker特定安全

### 1. 使用Docker Secrets（Docker Swarm）

如果使用Docker Swarm，可以使用Docker Secrets：

```bash
# 创建secret
echo "your_api_key" | docker secret create binance_api_key -

# docker-compose.yml中使用
services:
  nofx:
    secrets:
      - binance_api_key

secrets:
  binance_api_key:
    external: true
```

### 2. 限制容器权限

在 `docker-compose.yml` 中添加安全选项：

```yaml
services:
  nofx:
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

## 🔍 安全检查清单

使用前请确保：

- [ ] `config.json` 权限设置为 600 或 400
- [ ] `config.json` 已添加到 `.gitignore`
- [ ] Docker挂载使用 `:ro` 只读标志
- [ ] 配置文件所有者是运行Docker的用户
- [ ] 服务器防火墙已正确配置
- [ ] 使用SSH密钥认证而非密码
- [ ] 定期备份配置文件
- [ ] API密钥定期轮换（建议3-6个月）
- [ ] 禁用不使用的trader（`"enabled": false`）
- [ ] 限制API密钥权限（仅启用必要的交易权限）

## 🚨 应急响应

### 如果怀疑配置文件泄露：

1. **立即更换所有API密钥**
   ```bash
   # 在各个交易所立即生成新密钥并禁用旧密钥
   ```

2. **检查异常活动**
   ```bash
   # 查看交易所账户的登录日志和交易历史
   ```

3. **审查服务器访问日志**
   ```bash
   # 检查SSH登录
   sudo last
   sudo lastlog
   
   # 检查文件访问
   sudo ausearch -k nofx_config
   ```

4. **更新配置文件**
   ```bash
   nano config.json  # 更新所有密钥
   docker compose restart
   ```

5. **加强安全措施**
   - 更改SSH端口
   - 启用双因素认证
   - 实施IP白名单

## 📚 最佳实践总结

### ✅ 推荐做法

1. **文件权限**：设置 `chmod 600 config.json`
2. **位置**：放在Docker外部（当前已实现）
3. **只读挂载**：使用 `:ro` 标志（当前已实现）
4. **备份**：定期加密备份配置文件
5. **最小权限**：API密钥只启用必要权限
6. **监控**：监控配置文件访问和修改

### ❌ 避免做法

1. ❌ 不要将配置文件提交到Git
2. ❌ 不要使用777或666权限
3. ❌ 不要在多个地方保存明文配置
4. ❌ 不要通过聊天工具发送配置文件
5. ❌ 不要使用同一组API密钥在多个服务器
6. ❌ 不要长期不更换API密钥

## 🆘 获取帮助

如果有安全相关问题：

- 查看 [SECURITY_NOTICE.md](SECURITY_NOTICE.md)
- 提交 [GitHub Issue](https://github.com/mumugogoing/nofx/issues)（不要包含敏感信息）
- 加入 [Telegram社区](https://t.me/nofx_dev_community)

---

**记住：配置文件安全是系统安全的基础！**

定期审查和更新您的安全措施。
