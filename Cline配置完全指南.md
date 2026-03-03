# Cline 配置完全指南 🤖 + ⚙️

> Cline 是 VS Code 中的一款强大 AI 编程助手插件。通过合理配置 MCP、Skill、Workflow 和 Rules，你可以打造一个完全定制化的 AI 编程伙伴，让它更好地理解你的需求、遵循你的规范、甚至调用外部工具。

---

## 一、认识 Cline 的五大配置体系

在开始配置之前，让我们先理解 Cline 中各个配置模块的作用：

```
┌─────────────────────────────────────────────────────────────┐
│                    Cline 配置体系架构                          │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │   Settings   │  │     MCP      │  │   Skills     │       │
│  │  Cline本身设置 │  │ 外部工具连接  │  │   技能配置    │       │
│  │              │  │              │  │              │       │
│  │ • API设置    │  │ • API连接    │  │ • 代码规范    │       │
│  │ • 模型选择   │  │ • 数据库     │  │ • 开发模板    │       │
│  │ • 界面偏好   │  │ • 文件系统   │  │ • 最佳实践    │       │
│  └──────────────┘  └──────────────┘  └──────────────┘       │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐                         │
│  │  Workflows   │  │    Rules     │                         │
│  │   工作流      │  │    规则      │                         │
│  │              │  │              │                         │
│  │ • 开发流程   │  │ • 代码风格   │                         │
│  │ • 自动化步骤 │  │ • 约束限制   │                         │
│  │ • 协作模式   │  │ • 强制要求   │                         │
│  └──────────────┘  └──────────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

| 配置类型 | 作用 | 配置文件位置 |
|----------|------|--------------|
| **Settings** | Cline 本身的行为设置 | VS Code 设置面板 |
| **MCP** | 连接外部工具和服务 | `cline_mcp_settings.json` |
| **Skills** | 定义 AI 的专业技能 | `.cline/skills/` 目录 |
| **Workflows** | 规范开发流程 | `.clinerules` 文件 |
| **Rules** | 强制遵守的代码规范 | `.clinerules` 文件 |

---

## 二、Cline 本身设置（Settings）

### 2.1 打开 Cline 设置

**方法一：通过 VS Code 设置面板**
1. 按 `Ctrl + ,` 打开 VS Code 设置
2. 在搜索框输入 `Cline`
3. 找到所有以 `Cline` 开头的设置项

**方法二：通过 Cline 侧边栏**
1. 点击左侧 Cline 图标（或按 `Ctrl+Shift+P` 搜索 `Cline: Focus on Chat View`）
2. 点击右上角的 ⚙️ 设置图标
3. 选择 `Extension Settings`

### 2.2 API 配置（最重要！）

#### 2.2.1 选择 API 提供商

| 提供商 | 特点 | 适用场景 |
|--------|------|----------|
| **Anthropic** | Claude 官方 API | 最稳定，功能最全 |
| **OpenAI** | GPT-4/GPT-3.5 | 速度快，价格适中 |
| **OpenRouter** | 聚合多种模型 | 灵活切换模型 |
| **AWS Bedrock** | 企业级服务 | 已有 AWS 账户 |
| **Google** | Gemini 模型 | 免费额度多 |

#### 2.2.2 获取 API 密钥

**Anthropic (推荐新手使用)：**
1. 访问 [console.anthropic.com](https://console.anthropic.com)
2. 注册账号
3. 点击左侧 "API Keys"
4. 点击 "Create Key"
5. 复制生成的密钥（以 `sk-ant-` 开头）

**OpenAI：**
1. 访问 [platform.openai.com](https://platform.openai.com)
2. 注册并登录
3. 点击右上角头像 → "View API Keys"
4. 点击 "Create new secret key"
5. 复制密钥（以 `sk-` 开头）

> ⚠️ **重要提示**：API Key 是你的"钥匙"，不要分享给他人，也不要上传到 GitHub！

### 2.3 模型选择

| 模型 | 特点 | 费用 | 推荐度 |
|------|------|------|--------|
| **Claude 3.5 Sonnet** | 最聪明，代码能力最强 | 中等 | ⭐⭐⭐⭐⭐ |
| **Claude 3 Haiku** | 速度快，成本低 | 低 | ⭐⭐⭐⭐ |
| **GPT-4o** | 综合能力好 | 高 | ⭐⭐⭐⭐ |
| **GPT-4o-mini** | 性价比高 | 低 | ⭐⭐⭐⭐ |

**配置方法：**
- 设置项：`Cline: Model Id`
- 填入模型 ID，例如：`claude-3-5-sonnet-20241022`

### 2.4 常用设置项详解

| 设置项 | 作用 | 建议值 |
|--------|------|--------|
| `Cline: Preferred Language` | AI 回复的语言 | `中文` 或 `Chinese` |
| `Cline: Custom Instructions` | 全局自定义指令 | 见下文 Skill 章节 |
| `Cline: Auto Approve` | 自动批准某些操作 | 谨慎开启 |
| `Cline: Browser Tool Enabled` | 启用浏览器工具 | 根据需要 |
| `Cline: Checkpoints Enabled` | 启用代码检查点 | `true`（推荐）|

---

## 三、MCP (Model Context Protocol) 配置

### 3.1 什么是 MCP？

**MCP (Model Context Protocol)** 是一个开放协议，允许 AI 助手安全地连接到：
- 🌐 **外部 API**（天气、股票、翻译等）
- 🗄️ **数据库**（SQLite、PostgreSQL 等）
- 📁 **文件系统**（读取、搜索、修改文件）
- 🌐 **浏览器**（网页抓取、自动化测试）
- 🛠️ **开发工具**（Git、Docker、AWS 等）

### 3.2 配置文件位置

MCP 配置文件位于：
```
~/.vscode-server/data/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json
```

### 3.3 MCP 配置文件结构

```json
{
  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["/path/to/server/build/index.js"],
      "env": {
        "API_KEY": "your-api-key"
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

### 3.4 常用 MCP Server 推荐

#### 3.4.1 浏览器自动化 (playwright-mcp)

```json
{
  "mcpServers": {
    "github.com/microsoft/playwright-mcp": {
      "type": "stdio",
      "command": "npx",
      "timeout": 60,
      "args": ["-y", "@playwright/mcp@latest", "--browser", "chromium"],
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

**功能**：网页抓取、自动化操作、页面截图、网页测试、数据采集

#### 3.4.2 文件系统工具 (filesystem)

```json
{
  "mcpServers": {
    "github.com/modelcontextprotocol/servers/tree/main/src/filesystem": {
      "command": "node",
      "args": ["/home/lgy/Cline/MCP/filesystem-server/src/filesystem/dist/index.js", "/mnt/c/Users/gyli_/Desktop", "/home/lgy"],
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

**功能**：读取文件、列出目录、搜索文件、创建/修改文件、删除文件

#### 3.4.3 代码文档查询 (context7-mcp)

```json
{
  "mcpServers": {
    "github.com/upstash/context7-mcp": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"],
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

**功能**：最新文档查询、代码示例获取、减少幻觉

#### 3.4.4 文件格式转换 (markdownify-mcp)

```json
{
  "mcpServers": {
    "github.com/zcaceres/markdownify-mcp": {
      "command": "node",
      "args": ["/home/lgy/Cline/MCP/markdownify-mcp/dist/index.js"],
      "env": {
        "UV_PATH": "/home/lgy/.local/bin/uv"
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

**功能**：PDF/DOCX/XLSX/PPTX 转 Markdown、图片转 Markdown、网页转 Markdown、YouTube 视频转 Markdown

### 3.5 MCP 最佳实践

| 建议 | 说明 |
|------|------|
| 🔒 **保护密钥** | 不要将 API Key 硬编码，使用环境变量 |
| 🧪 **先禁用再测试** | 新添加的 MCP Server 先设为 `disabled: true` |
| ⚡ **按需加载** | 只启用你需要的 MCP Server，避免启动过慢 |

---

## 四、Skill（技能）配置

Skills 让 Cline 在特定领域表现得更加专业。

### 4.1 什么是 Skill？

Skill 是对 AI 的"专业培训"，告诉它角色定位、知识范围、代码风格和开发习惯。

### 4.2 Skill 目录结构

```
.cline/
└── skills/
    └── 技能名称/
        ├── SKILL.md          # 技能定义文件
        └── (可选) 其他资源文件
```

### 4.3 Skill 配置示例

#### 4.3.1 Python 开发专家

```markdown
---
name: python-development-expert
description: Python 后端开发专家，精通 FastAPI、Django 等框架
---

# Python 开发专家

## 角色定位
你是一位经验丰富的 Python 开发工程师，精通 Python 3.13+ 和现代 Python 生态。

## 技术栈
- **Web 框架**: FastAPI, Flask, Django
- **数据处理**: Pandas, NumPy, Polars
- **异步编程**: asyncio, aiohttp
- **数据库**: SQLAlchemy, PostgreSQL, Redis
- **测试**: pytest, unittest
- **工具**: Black, Ruff, mypy, pre-commit

## 编码规范
- 严格遵循 PEP 8
- 使用类型注解（Type Hints）
- 函数和类必须有 docstring
- 优先使用 pathlib 处理路径
- 异步代码使用 async/await
```

### 4.4 在项目中使用 Skill

在 `.clinerules` 中引用 Skill：

```markdown
# 技能引用
使用技能: python-development-expert
```

---

## 五、Workflow（工作流）配置

Workflow 定义了 Cline 与你协作的方式和流程。

### 5.1 什么是 Workflow？

Workflow 是 AI 助手的"行为模式"，规范了需求分析、设计阶段、编码阶段、测试阶段和文档阶段。

### 5.2 常用 Workflow 模式

#### 5.2.1 敏捷开发工作流

```markdown
# 敏捷开发工作流

## 1. 需求理解
- 复述用户需求的理解
- 询问不明确的地方
- 确认验收标准

## 2. 技术方案
- 提供 2-3 个可行方案
- 分析各方案的优缺点
- 推荐最优方案并说明理由

## 3. 任务拆解
- 将需求拆分为小任务
- 估算每个任务的复杂度
- 按优先级排序

## 4. 编码实现
- 先写伪代码/流程图
- 实现核心逻辑
- 添加边界情况处理

## 5. 代码审查
- 自我检查代码质量
- 优化性能和可读性

## 6. 交付总结
- 总结实现的功能
- 说明关键设计决策
```

### 5.3 在项目中使用 Workflow

将 Workflow 写入 `.clinerules` 文件：

```markdown
# 项目工作流

## 开发流程
1. 需求分析：复述需求，确认数据模型
2. 技术方案：提供可行方案并推荐最优
3. 编码实现：实现核心逻辑，添加测试
4. 代码审查：自我检查，优化质量
5. 交付总结：总结功能，说明决策
```

---

## 六、Rules（规则）配置

Rules 是强制 AI 遵守的"红线"，具有最高优先级。

### 6.1 什么是 Rules？

与 Skill 和 Workflow 不同，Rules 是**强制性**的：
- ❌ **禁止行为**：AI 绝对不能做的事情
- ✅ **必须行为**：AI 每次都必须做的事情
- 📋 **检查清单**：响应前必须完成的检查项

### 6.2 Rules 配置位置

Rules 主要配置在 `.clinerules` 文件中：

```
项目根目录/
├── .clinerules      ← 规则文件
├── src/
└── ...
```

### 6.3 Rules 配置示例

#### 6.3.1 安全规则

```markdown
# 安全规则（必须遵守）

## 🚫 绝对禁止
- 不要输出真实的 API 密钥、密码、Token
- 不要在代码中硬编码敏感信息
- 不要执行可能损害系统的命令

## ⚠️ 必须检查
每次生成代码前，检查：
- [ ] 是否有 SQL 注入风险
- [ ] 是否有 XSS 漏洞
- [ ] 是否正确处理用户输入
```

#### 6.3.2 代码质量规则

```markdown
# 代码质量规则（必须遵守）

## 编码规范
- 所有公共函数必须有文档字符串
- 复杂逻辑必须添加注释
- 变量名必须有意义（禁止 a, b, c）
- 一行代码不超过 100 个字符

## 提交前检查清单
- [ ] 代码已格式化
- [ ] 静态检查通过
- [ ] 所有测试通过
```

### 6.4 Rules 的优先级

```
1. 项目级 .clinerules（最高）
2. 全局 Custom Instructions
3. Cline 默认行为（最低）
```

---

## 七、综合实战：从零搭建 Hexo/Hugo 静态博客

现在让我们通过一个完整的案例，把前面的知识串联起来。本次实战将开发一个 **Hexo/Hugo 静态博客**。

### 7.1 场景设定

假设你要开始一个 **静态博客项目**，需要配置：
1. Cline 基础设置
2. 文件系统 MCP Server
3. 静态博客开发 Skill
4. 博客开发 Workflow
5. 内容规范 Rules

### 7.2 第一步：Cline 基础设置

1. **打开 VS Code 设置** (`Ctrl + ,`)
2. **搜索 "Cline"**
3. **配置以下项：**
   - `Api Provider`: `Anthropic`
   - `Api Key`: 填入你的 Claude API Key
   - `Model Id`: `claude-3-5-sonnet-20241022`
   - `Preferred Language`: `Chinese`
   - `Checkpoints Enabled`: ✅ 勾选

### 7.3 第二步：创建项目 Skill

在项目根目录创建 `.cline/skills/` 目录和技能文件：

```bash
mkdir -p ~/.cline/skills/staticblogexpert
```

**创建技能文件** `~/.cline/skills/staticblogexpert/SKILL.md`：

```markdown
---
name: static-blog-expert
description: 静态博客开发专家，精通 Hexo 和 Hugo
---

# 静态博客开发专家

## 角色定位
你是一位资深的静态博客开发专家，精通 Hexo 和 Hugo 博客框架。
## 技术栈
- **静态博客框架**: Hexo, Hugo, Jekyll
- **主题开发**: EJS, PUG, Go Templates
- **样式**: SCSS, Tailwind CSS
- **部署**: GitHub Pages, Vercel, Netlify
- **Markdown**: CommonMark, GFM
- **工具**: Node.js, npm/yarn/pnpm

## 编码规范
- Markdown 文件使用 UTF-8 编码
- 文章 Front Matter 必须包含 title、date、tags
- 图片放在 /images/ 目录
- 代码块必须标注语言类型

## 博客结构规范
### Hexo 结构
```
blog/
├── source/
│   ├── _posts/        # 文章目录
│   ├── pages/         # 页面目录
│   └── images/        # 图片目录
├── themes/            # 主题目录
├── _config.yml        # 站点配置
└── package.json
```

### Hugo 结构
```
blog/
├── content/
│   ├── posts/         # 文章目录
│   └── pages/         # 页面目录
├── static/           # 静态资源
├── layouts/          # 模板目录
├── config.toml       # 站点配置
└── hugo.toml
```

## 开发习惯
- 使用 `hexo new post` 或 `hugo new` 创建新文章
- 本地预览: `hexo server` 或 `hugo server`
- 部署前本地测试
- 使用 Git 进行版本管理

## 响应格式
- 代码块标注语言类型
- 提供完整的命令示例
- 解释关键配置项
```

### 7.4 第三步：创建项目 Rules

在博客项目根目录创建 `.clinerules` 文件：

```bash
mkdir -p ~/my-blog
cd ~/my-blog
touch .clinerules
```

**内容如下**：

```markdown
# My Blog 项目规则

## 项目简介
这是一个基于 Hexo/Hugo 的个人静态博客项目。

## 技术栈
- Hexo 7.x 或 Hugo 0.120+
- Node.js 18+ (Hexo)
- GitHub Pages 部署

## 内容规范

### Front Matter 格式
```yaml
---
title: 文章标题
date: 2024-01-01 12:00:00
categories:
  - 分类1
  - 分类2
tags:
  - 标签1
  - 标签2
---
```

### 文章要求
- 文章标题使用中文，准确概括内容
- 关键词标签帮助 SEO
- 代码块必须标注语言
- 图片使用相对路径

### 目录结构
```
source/
├── _posts/
│   └── 2024/
│       └── hello-world.md
├── images/
│   └── posts/
└── about/
    └── index.md
```

## 开发流程

### 创建新文章
1. 使用命令创建: `hexo new post "文章标题"`
2. 编写 Front Matter
3. 撰写正文内容
4. 本地预览: `hexo server`
5. 部署: `hexo deploy`

### 本地预览
- Hexo: `npm run server` 或 `hexo s`
- Hugo: `hugo server -D`

### 部署流程
1. 确保本地测试通过
2. 构建静态文件: `hexo generate` 或 `hugo`
3. 部署到 GitHub: `hexo deploy` 或 Git 自动部署

## 响应格式
- 使用中文回复
- 代码块必须标注语言
- 提供完整的命令示例
- 复杂操作分步骤说明
```

### 7.5 第四步：开始开发

现在你可以对 Cline 说：

> "帮我创建一个 Hexo 博客项目，主题使用 Butterfly"

Cline 会：
1. 读取 `.clinerules` 了解项目规范
2. 按照定义的 Workflow 执行
3. 使用已配置的 MCP 工具读写文件
4. 遵守 Rules 中的内容规范
5. 生成符合 Skill 定义的代码风格

或者：

> "帮我写一篇关于 Python 虚拟环境的博客文章"

Cline 会：
1. 按照博客格式创建 Markdown 文件
2. 添加正确的 Front Matter
3. 遵循内容规范

### 7.6 第五步：验证配置

**验证 Skill：**
> "如何部署博客到 GitHub Pages？"

Cline 应该生成详细的部署步骤。

**验证 Rules：**
> "创建一篇新文章"

Cline 应该生成带有正确 Front Matter 的 Markdown 文件。

---

## 八、常见问题与解决方案

### 8.1 MCP Server 无法连接

**排查步骤：**
1. 检查配置文件路径是否正确
2. 检查 `command` 和 `args` 路径是否正确
3. 查看 VS Code 输出面板的错误信息

### 8.2 Cline 不遵守规则

**解决方案：**
1. 检查 `.clinerules` 是否是有效的 Markdown
2. 使用更具体的指令
3. 简化规则

### 8.3 响应太慢

**优化方法：**
1. 减少启用的 MCP Server 数量
2. 使用更快的模型
3. 简化 `.clinerules` 文件

---

## 九、高级技巧

### 9.1 多环境配置

```bash
~/.cline/
├── work/
│   └── skills/
└── personal/
    └── skills/
```

### 9.2 团队共享配置

将 `.clinerules` 提交到 Git 仓库：

```bash
git add .clinerules
git commit -m "Add Cline configuration"
git push
```

---

## 参考资源

### 官方文档
- [Cline GitHub](https://github.com/cline/cline)
- [MCP 协议文档](https://modelcontextprotocol.io)

### 静态博客
- [Hexo 文档](https://hexo.io/zh-cn/docs/)
- [Hugo 文档](https://gohugo.io/documentation/)

---

## 结语

通过合理配置 Cline，你可以打造一个完全定制化的 AI 编程伙伴：

🎯 **MCP** 让它连接无限可能的外部工具  
🎓 **Skill** 让它成为特定领域的专家  
📋 **Workflow** 让它遵循你的开发流程  
📏 **Rules** 让它严格遵守你的规范

记住：
- 从简单开始，逐步添加配置
- 定期回顾和优化你的配置
- 与团队成员分享最佳实践

祝你使用 Cline 愉快！🚀

---

*最后更新：2025年2月*
