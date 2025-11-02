# 远程部署配置文件示例
# 复制此文件为 deploy-config.sh 并填入你的实际值
# 注意：deploy-config.sh 已被添加到 .gitignore，不会被提交到Git

# 服务器配置
export DEPLOY_SERVER_IP="你的服务器IP"        # 例如：47.108.148.251
export DEPLOY_SSH_USER="root"                  # SSH登录用户名
export DEPLOY_SSH_PORT="22"                    # SSH端口
export DEPLOY_REMOTE_DIR="/opt/nofx"           # 服务器上的部署目录

# 可选：如果不使用SSH密钥，可以设置密码（不推荐）
# export DEPLOY_SSH_PASSWORD="你的密码"
# 强烈建议使用SSH密钥认证而不是密码

# 应用配置
export DEPLOY_BACKEND_PORT="8080"              # 后端API端口
export DEPLOY_FRONTEND_PORT="3000"             # 前端Web端口
export DEPLOY_TIMEZONE="Asia/Shanghai"         # 时区设置
