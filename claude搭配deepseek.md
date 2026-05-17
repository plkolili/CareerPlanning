---
words:
  2026-05-08: 173
  2026-05-09: 181
---
安装 wsl ubuntu 
```
wsl --install -d Ubuntu-22.04
```
低版本Ubuntu
```
# 安装 Node.js 20.x LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs
# 验证版本
node --version  # 应该显示 v20.x.x
npm --version   # 应该显示 10.x.x
```

install 
```
npm install -g @anthropic-ai/claude-code --registry=https://registry.npmmirror.com
```

装好后，在.claude文件夹下，创建setting.json
setting.json
```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.deepseek.com/anthropic",
    "ANTHROPIC_AUTH_TOKEN": "sk-8ae2a7742c9c4e5ba808ce4bc6209e26",
    "ANTHROPIC_MODEL": "deepseek-v4-pro",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "deepseek-v4-pro",
    "API_TIMEOUT_MS": "60000",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "maxTokens":4000 
}

```

安装 wsl
```
wsl --install -d Ubuntu-22.04
```
打开wsl权限
1. 方法一
```json
wsl.exe -d Ubuntu-26.04 --user root
```
2. 方法二
```
sudo i
sudo -s #当前路径
```

在当前cmd打开ubuntu 
```
wsl.exe -d Ubuntu-22.04
```

卸载
```
wsl --unregister Ubuntu-22.04
```