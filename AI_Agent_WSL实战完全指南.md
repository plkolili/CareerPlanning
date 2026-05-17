---
words:
  2026-05-07: 5356
---
# 🤖 AI Agent WSL 实战完全指南

## 在 WSL Ubuntu 上构建 Claude + DeepSeek 小型 AI 环境

> 整合当前项目中所有 AI Agent 用法，提供从零搭建 Claude + DeepSeek 联合工作环境的完整方案。
> 适用平台：Windows 11 + WSL2 + Ubuntu 22.04/24.04

---

## 目录

- [一、当前 AI Agent 全景盘点](#一当前-ai-agent-全景盘点)
  - [1.1 Agent 分类总表](#11-agent-分类总表)
  - [1.2 各 Agent 角色与定位](#12-各-agent-角色与定位)
  - [1.3 Agent 协作关系图](#13-agent-协作关系图)
- [二、WSL Ubuntu 构建 Claude + DeepSeek 环境（四种方案）](#二wsl-ubuntu-构建-claude--deepseek-环境四种方案)
  - [2.1 方案一：Cline + Claude API + DeepSeek API](#21-方案一cline--claude-api--deepseek-api)
  - [2.2 方案二：Cherry Studio 桌面端](#22-方案二cherry-studio-桌面端)
  - [2.3 方案三：Ollama 本地部署 DeepSeek](#23-方案三ollama-本地部署-deepseek)
  - [2.4 方案四：Docker 容器化 + API 调用](#24-方案四docker-容器化--api-调用)
- [三、配置速查表与最佳实践](#三配置速查表与最佳实践)
  - [3.1 四方案对比矩阵](#31-四方案对比矩阵)
  - [3.2 API Key 安全管理](#32-api-key-安全管理)
  - [3.3 推荐组合方案](#33-推荐组合方案)
  - [3.4 成本控制策略](#34-成本控制策略)
  - [3.5 常见问题排查](#35-常见问题排查)

---

## 一、当前 AI Agent 全景盘点

### 1.1 Agent 分类总表

| # | AI Agent / 工具 | 类型 | 当前状态 | 核心能力 |
|---|----------------|------|---------|---------|
| 1 | **Cline** | VS Code AI 编程助手 | ✅ 已配置并深度使用 | 代码生成、MCP 工具调用、项目级上下文理解 |
| 2 | **Cherry Studio** | 桌面端多模型客户端 | 📖 有完整文档 | 多模型对话、300+ 助手、MCP 扩展 |
| 3 | **Ollama** | 本地 LLM 运行时 | 📖 文档提及 | 离线运行开源模型、隐私保护 |
| 4 | **Docker (WSL2)** | 容器化 AI 环境 | 📖 有实战教程 | TensorFlow/Jupyter/Flask 一键部署 |
| 5 | **OpenAI API** | 云 API | 📖 作为备选 | GPT-4o / GPT-4o-mini |
| 6 | **Anthropic API** | 云 API（Claude） | ✅ Cline 主力模型 | Claude 3.5 Sonnet / Haiku |
| 7 | **DeepSeek API** | 云 API | 📖 文档提及 | DeepSeek-V3 / DeepSeek-R1 |

### 1.2 各 Agent 角色与定位

#### 1.2.1 Cline — AI 编程主力

```
定位：      VS Code 内的 AI 编程伙伴
配置文件：   .cline/skills/ + .clinerules/
当前模型：   Anthropic Claude 3.5 Sonnet
核心能力：
  ├── 代码生成与重构
  ├── MCP 协议扩展（文件系统、浏览器、数据库）
  ├── Skill 专业化（Python 开发专家）
  ├── Workflow 流程规范（敏捷开发六步法）
  └── Rules 强制约束（代码质量规则）
```

**当前已配置内容：**

| 配置层 | 文件 | 用途 |
|--------|------|------|
| Skill | `.cline/skills/pythondevelopmentexpert/SKILL.md` | Python 开发专家技能 |
| Rules | `.clinerules/CodeQualityRules.md` | 代码质量强制规则 |
| Workflow | `.clinerules/workflows/Agiledevelopmentworkflow.md` | 敏捷开发六步流程 |

**Python 开发 Skill 关键规范：**
- 严格遵循 PEP 8，使用类型注解
- 技术栈：FastAPI / Flask / Django + Pandas / NumPy
- 工具链：Black / Ruff / mypy / pre-commit
- 测试覆盖率 > 80%

**代码质量 Rules（强制）：**
- 所有公共函数必须有文档字符串
- 禁止单字母变量名 (a, b, c)
- 一行代码 ≤ 100 字符
- 提交前：格式化 → 静态检查 → 测试通过
sudo cline 
#### 1.2.2 Cherry Studio — 多模型对话中心

```
定位：      跨平台 AI 桌面客户端
支持模型：  OpenAI / Claude / DeepSeek / Gemini / Ollama 本地模型
核心能力：
  ├── 多模型同时对话对比
  ├── 300+ 预配置助手
  ├── 文件对话（PDF/Word/PPT）
  ├── Mermaid 图表生成
  ├── MCP 服务器扩展
  └── 本地模型接入（Ollama）
```

#### 1.2.3 Ollama — 本地模型运行时

```
定位：      一键运行开源 LLM
优势：      无需网络、隐私安全、免费
限制：      受硬件性能影响
适用模型：  DeepSeek-R1 / Qwen / Llama 3 / Mistral
```

#### 1.2.4 Docker + WSL2 — AI 开发环境基座

```
定位：      容器化 AI/ML 开发环境
当前配置：  Python 3.11 + Jupyter + TensorFlow + PyTorch + Flask
核心能力：
  ├── 一键启动 Jupyter Lab
  ├── 模型训练与评估
  └── Flask API 模型部署
```

### 1.3 Agent 协作关系图

```
┌─────────────────────────────────────────────────────────────────┐
│                     WSL2 Ubuntu 22.04                           │
│                                                                 │
│  ┌─────────────────────┐    ┌──────────────────────┐           │
│  │      Cline          │    │    Cherry Studio      │           │
│  │   (VS Code 插件)     │    │   (桌面端客户端)       │           │
│  │                     │    │                      │           │
│  │  API 调用 ──────────┼────┼── API 调用            │           │
│  │  │                  │    │  │                   │           │
│  └──┼──────────────────┘    └──┼───────────────────┘           │
│     │                          │                                │

```

## 二、WSL Ubuntu 构建 Claude + DeepSeek 环境（四种方案）

### 环境准备

```bash
# 确认 WSL2 运行正常
wsl --list --verbose
# 应显示 Ubuntu-22.04 (或 24.04) 且 Version = 2

# 进入 WSL Ubuntu
wsl

# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装基础工具
sudo apt install -y curl wget git build-essential
```

---

### 2.1 方案一：Cline + Claude API + DeepSeek API

> **最适合**：在 VS Code 中使用 Claude 主力编程，DeepSeek 作为低成本的备选/辅助模型。
> **前置条件**：已安装 VS Code + WSL Remote 插件 + Cline 插件。

#### 2.1.1 Cline 中配置 Claude（主力）

1. 打开 VS Code → 按 `Ctrl+Shift+P` → 搜索 `Cline: Focus on Chat View`
2. 点击右上角 ⚙️ → `Extension Settings`
3. 配置以下项：

| 设置项 | 值 |
|--------|---|
| `Api Provider` | `Anthropic` |
| `Api Key` | `sk-ant-api03-xxxx`（从 console.anthropic.com 获取）|
| `Model Id` | `claude-sonnet-4-20250514` 或 `claude-3-5-sonnet-20241022` |
| `Preferred Language` | `Chinese` |

#### 2.1.2 Cline 中配置 DeepSeek（备选）

在 Cline 中**切换 API Provider** 即可使用 DeepSeek：

| 设置项 | 值 |
|--------|---|
| `Api Provider` | `OpenAI Compatible`（DeepSeek 兼容 OpenAI 格式）|
| `Api Key` | `sk-xxxx`（从 platform.deepseek.com 获取）|
| `Base URL` | `https://api.deepseek.com/v1` |
| `Model Id` | `deepseek-chat`（V3）或 `deepseek-reasoner`（R1）|

> ⚠️ Cline 不支持同时配置两个 Provider。需要通过 VS Code 设置随时切换 `Api Provider`。

#### 2.1.3 获取 API Key

**Claude (Anthropic)：**
```bash
# 1. 浏览器访问 https://console.anthropic.com
# 2. 注册并验证邮箱
# 3. 左侧菜单 → API Keys → Create Key
# 4. 复制以 sk-ant-api03- 开头的密钥
```

**DeepSeek：**
```bash
# 1. 浏览器访问 https://platform.deepseek.com
# 2. 注册/登录
# 3. 左侧菜单 → API Keys → 创建新 Key
# 4. 复制以 sk- 开头的密钥
```

**安全存储 API Key（WSL Ubuntu）：**
```bash
# 写入 ~/.bashrc
echo 'export ANTHROPIC_API_KEY="sk-ant-api03-xxxx"' >> ~/.bashrc
echo 'export DEEPSEEK_API_KEY="sk-xxxx"' >> ~/.bashrc
source ~/.bashrc
```

#### 2.1.4 切换策略：何时用哪个模型

```
复杂推理/代码 → Claude 3.5 Sonnet (Cline 主力)
中文任务/翻译 → DeepSeek-V3 (低成本)
数学/逻辑推理 → DeepSeek-R1 (reasoner 模式)
简单代码片段 → DeepSeek-V3 (足够且便宜)
```

---

### 2.2 方案二：Cherry Studio 桌面端

> **最适合**：同时对比 Claude 和 DeepSeek 回答，使用 300+ 预配置 AI 助手。
> **优势**：可同时配置多个模型，一键对比回答。

#### 2.2.1 WSL Ubuntu 中安装 Cherry Studio

```bash
# 下载 AppImage（推荐方式）
cd ~/Downloads
wget https://github.com/CherryHQ/cherry-studio/releases/latest/download/Cherry-Studio-*.AppImage
chmod +x Cherry-Studio-*.AppImage

# WSL2 中运行（需要 WSLg，Windows 11 默认支持）
./Cherry-Studio-*.AppImage
```

> 💡 WSL2 运行 GUI 需要 Windows 11 + WSLg。若无法启动，可在 Windows 侧直接安装 Cherry Studio 的 .exe 版本。

#### 2.2.2 配置 Claude 提供商

1. 启动 Cherry Studio → 设置 → 模型设置 → 添加提供商
2. 选择 **Anthropic Claude**

| 配置项 | 值 |
|--------|---|
| 名称 | `Claude (个人)` |
| Base URL | `https://api.anthropic.com` |
| API Key | 粘贴 Anthropic API Key |
| 模型 | `claude-sonnet-4-20250514` / `claude-3-5-sonnet-20241022` |

3. 点击「检查连接」→ 保存

#### 2.2.3 配置 DeepSeek 提供商

| 配置项 | 值 |
|--------|---|
| 名称 | `DeepSeek (个人)` |
| Base URL | `https://api.deepseek.com/v1` |
| API Key | 粘贴 DeepSeek API Key |
| 模型 | `deepseek-chat`（V3）+ `deepseek-reasoner`（R1）|

#### 2.2.4 多模型对比对话（核心功能）

```
操作步骤：
1. 新建对话 → 勾选多个模型（Claude + DeepSeek-V3 + DeepSeek-R1）
2. 输入问题 → 同时查看多个模型回答
3. 选择最佳答案加入对话

典型场景：
• 代码问题 → 对比 Claude 和 DeepSeek 代码质量
• 中文文稿 → 对比翻译/润色效果
• 逻辑问题 → 对比推理能力
```


---

### 2.3 方案三：Ollama 本地部署 DeepSeek

> **最适合**：完全离线环境、隐私敏感任务、零 API 费用。
> **限制**：需较好硬件（建议 16GB+ 内存，独立显卡更佳）。

#### 2.3.1 安装与拉取模型

```bash
# 一键安装 Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 拉取 DeepSeek 模型（按硬件选择）
ollama pull deepseek-r1:7b    # 7B，~4.7GB，适合 16GB 内存
ollama pull deepseek-r1:14b   # 14B，~9GB，需要 24GB+ 内存
ollama pull deepseek-r1:32b   # 32B，~19GB，需要 32GB+ 内存

# 验证
ollama list
```

#### 2.3.2 命令行直接使用

```bash
# 交互式对话
ollama run deepseek-r1:7b

# 单次问答
ollama run deepseek-r1:7b "用 Python 写一个快速排序"

# 查看是否启用 GPU 加速
ollama run deepseek-r1:7b --verbose
```

#### 2.3.3 通过 Cline 连接 Ollama

Cline 设置中切换 Provider：

| 设置项 | 值 |
|--------|---|
| `Api Provider` | `Ollama` |
| `Base URL` | `http://localhost:11434` |
| `Model Id` | `deepseek-r1:7b` |

#### 2.3.4 通过 Python API 调用

```bash
pip install ollama
```

```python
"""通过 Python 调用 Ollama 本地 DeepSeek 模型"""
import ollama

def ask_deepseek(prompt: str, model: str = "deepseek-r1:7b") -> str:
    """向本地 DeepSeek 模型发送请求。

---

### 2.4 方案四：Docker 容器化 + API 调用

> **最适合**：AI/ML 开发环境隔离，通过 Python 脚本统一调用 Claude + DeepSeek API。
> **前置条件**：已安装 Docker Desktop + WSL2 集成。

#### 2.4.1 项目目录结构

```bash
mkdir -p ~/ai-agent-lab/{notebooks,scripts,data,models}
cd ~/ai-agent-lab
```

#### 2.4.2 创建 Dockerfile

```dockerfile
FROM python:3.11-slim
WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y gcc g++ \
    && rm -rf /var/lib/apt/lists/*

# Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 8888 5000
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]
```

#### 2.4.3 创建 requirements.txt

```txt
jupyterlab==4.2.0
pandas==2.1.4
numpy==1.25.2
openai>=1.0.0
anthropic>=0.30.0
ollama>=0.1.0
python-dotenv==1.0.0
flask==2.3.3
```

#### 2.4.4 环境变量配置 (.env)

```bash
# .env 文件（不要提交到 Git！）
ANTHROPIC_API_KEY=sk-ant-api03-xxxx
DEEPSEEK_API_KEY=sk-xxxx
DEEPSEEK_BASE_URL=https://api.deepseek.com/v1
```

```bash
# .gitignore 中添加
echo ".env" >> .gitignore
```

#### 2.4.5 统一 AI 调用脚本

创建 `scripts/ai_client.py`：

```python
"""统一 AI 客户端：同时支持 Claude 和 DeepSeek"""

import os
from dataclasses import dataclass
from typing import Literal

import anthropic
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

ProviderType = Literal["claude", "deepseek"]


@dataclass
class AIClient:
    """统一 AI 调用客户端，支持 Claude 和 DeepSeek。

    Attributes:
        provider: 模型提供商，"claude" 或 "deepseek"
        claude_model: Claude 模型 ID
        deepseek_model: DeepSeek 模型 ID
    """

    provider: ProviderType = "claude"
    claude_model: str = "claude-sonnet-4-20250514"
    deepseek_model: str = "deepseek-chat"

    def __post_init__(self):
        """初始化对应的 API 客户端。"""
        if self.provider == "claude":
            self._client = anthropic.Anthropic(
                api_key=os.getenv("ANTHROPIC_API_KEY")
            )
        elif self.provider == "deepseek":
            self._client = OpenAI(
                api_key=os.getenv("DEEPSEEK_API_KEY"),
                base_url=os.getenv("DEEPSEEK_BASE_URL"),
            )

    def ask(self, prompt: str, system: str = "") -> str:
        """发送请求并返回回复。

        Args:
            prompt: 用户输入
            system: 系统提示词，默认为空

        Returns:
            模型的回复文本
        """
        if self.provider == "claude":
            return self._ask_claude(prompt, system)
        else:
            return self._ask_deepseek(prompt, system)

    def _ask_claude(self, prompt: str, system: str) -> str:
        """调用 Claude API。"""
        response = self._client.messages.create(
            model=self.claude_model,
            max_tokens=4096,
            system=system or "你是一位编程助手。",
            messages=[{"role": "user", "content": prompt}],
        )
        return response.content[0].text

    def _ask_deepseek(self, prompt: str, system: str) -> str:
        """调用 DeepSeek API（兼容 OpenAI 格式）。"""
        messages = []
        if system:
            messages.append({"role": "system", "content": system})
        messages.append({"role": "user", "content": prompt})

        response = self._client.chat.completions.create(
            model=self.deepseek_model,
            messages=messages,
            max_tokens=4096,
        )
        return response.choices[0].message.content


# 便捷函数
def ask_claude(prompt: str, system: str = "") -> str:
    """快速向 Claude 提问。"""
    return AIClient(provider="claude").ask(prompt, system)


def ask_deepseek(prompt: str, system: str = "") -> str:
    """快速向 DeepSeek 提问。"""
    return AIClient(provider="deepseek").ask(prompt, system)


# 示例
if __name__ == "__main__":
    # Claude 解答复杂问题
    code = ask_claude("用 Python 写一个带缓存装饰器的实现")
    print(f"[Claude]\n{code}\n")

    # DeepSeek 解答中文问题
    trans = ask_deepseek("把下面的英文翻译成中文：Hello, world!")
    print(f"[DeepSeek]\n{trans}")
```

#### 2.4.6 构建与运行

```bash
# 构建镜像
docker build -t ai-agent-lab .

# 启动容器
docker run -it --rm \
    -p 8888:8888 \
    -v $(pwd):/app \
    --env-file .env \
    ai-agent-lab

# 进入容器执行脚本
docker exec -it <container_id> bash
python scripts/ai_client.py
```

#### 2.4.7 Docker Compose 编排（含 Ollama）

```yaml
# docker-compose.yml
version: '3.8'
services:
  ai-lab:
    build: .

---

## 三、配置速查表与最佳实践

### 3.1 四方案对比矩阵

| 维度 | 方案一 Cline | 方案二 Cherry Studio | 方案三 Ollama 本地 | 方案四 Docker |
|------|------------|---------------------|--------------------|--------------|
| **部署难度** | ⭐ 简单（VS Code 设置）| ⭐ 简单（下载即用）| ⭐⭐ 中等（需下载模型）| ⭐⭐⭐ 较复杂 |
| **Claude 支持** | ✅ 原生 | ✅ 原生 | ❌（Claude 无开源版）| ✅ 通过 API |
| **DeepSeek 支持** | ✅ 切换 Provider | ✅ 原生 | ✅ 本地开源版 | ✅ 通过 API |
| **多模型对比** | ❌ 单模型 | ✅ 多模型同时 | ❌ | ✅ 脚本实现 |
| **离线能力** | ❌ 需网络 | ❌ 需网络（API 部分）| ✅ 完全离线 | ❌ 需网络 |
| **代码能力** | ⭐⭐⭐⭐⭐（最强）| ⭐⭐⭐ | ⭐⭐（受限于本地模型大小）| ⭐⭐⭐ |
| **成本** | API 按量付费 | API 按量付费 | 免费（硬件成本）| API 按量付费 |
| **隐私性** | 数据发送到云端 | 数据发送到云端 | ✅ 完全本地 | 数据发送到云端 |
| **GPU 加速** | N/A（云端）| N/A（云端）| ✅ WSL2 GPU 透传 | ✅ NVIDIA Docker |
| **适合场景** | 日常编程主力 | 模型选型对比 | 离线/隐私任务 | ML 训练 + API 混合 |

### 3.2 API Key 安全管理

```bash
# 方法一：环境变量（推荐）
# ~/.bashrc 或 ~/.zshrc
export ANTHROPIC_API_KEY="sk-ant-api03-xxxx"
export DEEPSEEK_API_KEY="sk-xxxx"

# 方法二：专用密钥文件（适合多项目）
mkdir -p ~/.config/ai-keys
echo "sk-ant-api03-xxxx" > ~/.config/ai-keys/anthropic
echo "sk-xxxx" > ~/.config/ai-keys/deepseek
chmod 600 ~/.config/ai-keys/*

# 方法三：.env 文件（项目级，必须加入 .gitignore）
cat > .env << 'EOF'
ANTHROPIC_API_KEY=sk-ant-api03-xxxx
DEEPSEEK_API_KEY=sk-xxxx
EOF
echo ".env" >> .gitignore
```

> ⚠️ **切记**：API Key 绝不能提交到 Git 仓库！已提交的 Key 必须立即在平台上吊销。

### 3.3 推荐组合方案

```
┌─────────────────────────────────────────────────────┐
│                🏆 推荐三层架构                        │
│                                                     │
│  第 1 层：Cline（主力编程）                           │
│  ├── 模型：Claude 3.5 Sonnet                       │
│  ├── 场景：复杂代码、架构设计、Bug 调试              │
│  └── 配置：Anthropic API Provider                   │
│                                                     │
│  第 2 层：Cherry Studio（辅助 + 对比）               │
│  ├── 模型：Claude + DeepSeek-V3 + DeepSeek-R1       │
│  ├── 场景：多模型对比、中文任务、文档处理            │
│  └── 配置：同时添加 Anthropic + DeepSeek Provider   │
│                                                     │
│  第 3 层：Ollama 本地（离线备份）                     │
│  ├── 模型：deepseek-r1:7b / qwen:7b                 │
│  ├── 场景：无网络时应急、隐私敏感数据               │
│  └── 配置：Cline 或 Cherry Studio 连接 Ollama       │
│                                                     │
│  可选层：Docker 环境（AI 开发）                      │
│  ├── 容器：Jupyter + Python 统一 ai_client.py      │
│  └── 场景：ML 训练、API 批量调用、模型部署           │
└─────────────────────────────────────────────────────┘
```

### 3.4 成本控制策略

| 策略 | 方法 |
|------|------|
| **任务分级** | 复杂任务 → Claude；简单任务 → DeepSeek-V3 |
| **本地优先** | 非紧急/隐私任务 → Ollama 本地模型 |
| **设置限额** | Anthropic Console → Workspace → Usage Limits |
| **模型选择** | 日常用 `claude-3-5-haiku`（更快更便宜）替代 Sonnet |
| **缓存利用** | Claude 支持 prompt caching，减少重复输入成本 |
| **批量处理** | 使用 Docker 脚本批量调用 DeepSeek（成本极低）|

```
估算成本（2025年参考）：

Claude 3.5 Sonnet:  ~$3/百万输入 token + $15/百万输出 token
DeepSeek-V3:        ~$0.27/百万输入 token + $1.10/百万输出 token
Ollama 本地:        免费（仅电费）

对比：处理相同任务，DeepSeek 成本约为 Claude 的 1/10
建议：日均 $1-3 即可覆盖个人开发者的 Claude + DeepSeek 需求
```

### 3.5 常见问题排查

#### Q1：Cline 无法连接 Anthropic API

```bash
# 排查步骤
# 1. 检查 API Key 是否正确
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-3-5-sonnet-20241022","max_tokens":10,"messages":[{"role":"user","content":"Hi"}]}'

# 2. 检查网络（大陆用户）
# 可能需要代理或使用 API 中转服务
```

#### Q2：Ollama 在 WSL 中无法使用 GPU

```bash
# 检查 WSL2 GPU 支持
nvidia-smi

# 若未安装 NVIDIA 驱动
# Windows 侧：安装 NVIDIA WSL2 驱动
# https://developer.nvidia.com/cuda/wsl

# 重启 WSL
wsl --shutdown
wsl
```

#### Q3：Docker 容器无法访问宿主机 Ollama

```yaml
# docker-compose.yml 中设置网络
services:
  app:
    extra_hosts:
      - "host.docker.internal:host-gateway"
    environment:
      - OLLAMA_HOST=http://host.docker.internal:11434
```

#### Q4：Cherry Studio WSL 无法启动 GUI

```bash
# 检查 WSLg 是否安装
ls /mnt/wslg/

# 如不存在，确保 Windows 11 且 WSL 已更新
wsl --update

# 备选：Windows 侧直接安装 Cherry Studio .exe
```

---

## 附录：现有配置文件速查

### 当前 Cline 配置

**Skill 文件**：`.cline/skills/pythondevelopmentexpert/SKILL.md`
- 角色：Python 开发专家
- 技术栈：FastAPI / Flask / Django / Pandas / NumPy
- 规范：PEP 8 + Type Hints + docstring + Black 格式化

**Rules 文件**：`.clinerules/CodeQualityRules.md`
- 公共函数必须有文档字符串
- 禁止单字母变量名
- 每行 ≤ 100 字符
- 提交前必须格式化 + 静态检查 + 测试通过

**Workflow 文件**：`.clinerules/workflows/Agiledevelopmentworkflow.md`
- 需求理解 → 技术方案 → 任务拆解 → 编码实现 → 代码审查 → 交付总结

### 相关文档索引

| 文档 | 内容 |
|------|------|
| `Cline配置完全指南.md` | Cline 五大配置体系（Settings/MCP/Skill/Workflow/Rules）|
| `CherryStudio_使用方法学习要点.md` | Cherry Studio 桌面端完整使用指南 |
| `docker_wsl_ai_tutorial.md` | Docker Desktop + WSL2 AI 环境实战 |
| `Linux配置与问题解决指南.md` | WSL Ubuntu 常见环境问题 |

---

> 📝 **最后更新**：2026年5月
> 🎯 **核心思路**：Claude 做主力、DeepSeek 降成本、Ollama 做备份、Docker 做环境隔离

    ports:
      - "8888:8888"
      - "5000:5000"
    volumes:
      - .:/app
      - ./data:/app/data
      - ./models:/app/models
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - DEEPSEEK_API_KEY=${DEEPSEEK_API_KEY}
    command: jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root

  ollama:
    image: ollama/ollama:latest
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

volumes:
  ollama_data:
```

    Args:
        prompt: 用户输入的提示词
        model: Ollama 模型名称

    Returns:
        模型的回复文本
    """
    response = ollama.chat(
        model=model,
        messages=[{"role": "user", "content": prompt}],
    )
    return response["message"]["content"]

# 测试
if __name__ == "__main__":
    print(ask_deepseek("用一句话解释什么是机器学习"))
```

#### 2.3.5 性能优化

```bash
# 设置并发请求数
ollama serve OLLAMA_NUM_PARALLEL=4

# 释放显存
ollama stop deepseek-r1:7b
```
#### 2.2.5 在 Cherry Studio 中连接本地 Ollama

```bash
# 先安装 Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama pull deepseek-r1:7b
```

Cherry Studio 中添加：
| 配置项 | 值 |
|--------|---|
| 提供商 | `Ollama` |
| Base URL | `http://localhost:11434` |
| API Key | 留空 |
| 模型 | `deepseek-r1:7b` |
│     │    ┌─────────────────────┼──────────────┐                 │
│     │    │                     │              │                 │
│     ▼    ▼                     ▼              ▼                 │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────┐          │
│  │ Claude   │    │  DeepSeek    │    │   Ollama     │          │
│  │ API      │    │  API         │    │ (本地模型)    │          │
│  │ (云端)   │    │  (云端)      │    │              │          │
│  └──────────┘    └──────────────┘    └──────┬───────┘          │
│                                             │                   │
│                                    ┌────────▼───────┐          │
│                                    │  DeepSeek-R1   │          │
│                                    │  Qwen / Llama  │          │
│                                    │  (本地离线)    │          │
│                                    └────────────────┘          │
│                                                                 │
│  ┌──────────────────────────────────────────────────┐          │
│  │              Docker 容器环境                       │          │
│  │  ┌───────────┐  ┌──────────┐  ┌──────────────┐  │          │
│  │  │ Jupyter   │  │TensorFlow│  │  Flask API   │  │          │
│  │  │ Lab       │  │ PyTorch  │  │  (模型服务)   │  │          │
│  │  └───────────┘  └──────────┘  └──────────────┘  │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                 │
│  策略：                                                         │
│  • 复杂推理/代码 → Claude API (Cline)                          │
│  • 中文任务/批量 → DeepSeek API (Cherry Studio)               │
│  • 离线/隐私    → Ollama 本地模型                              │
│  • ML 训练      → Docker 容器环境                              │
└─────────────────────────────────────────────────────────────────┘
```

---

> 📝 **文档完成**。参见上方「目录」快速导航各章节。
