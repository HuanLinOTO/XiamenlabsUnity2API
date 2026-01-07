# XiamenLabs OpenAI Proxy

🚀 将 XiamenLabs API 转换为 OpenAI 兼容格式的高性能代理服务器

[![Rust](https://img.shields.io/badge/rust-1.70%2B-orange.svg)](https://www.rust-lang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## ✨ 功能特性

- ✅ **完全兼容 OpenAI API** - 支持所有 OpenAI SDK 和客户端
- ✅ **流式响应** - Server-Sent Events (SSE) 实时输出
- ✅ **非流式响应** - 传统的完整响应模式
- ✅ **Reasoning 支持** - 显示 AI 模型的推理过程（思考链）
- ✅ **Web UI** - 内置现代化聊天界面，无需额外部署
- ✅ **Prompt 注入** - 自动从 `prompt.md` 读取并注入到 system prompt
- ✅ **高性能** - 基于 Actix-web 异步框架
- ✅ **CORS 支持** - 跨域访问无障碍
- ✅ **详细日志** - 完整的请求追踪

## 📋 支持的端点

| 端点                   | 方法 | 说明                       |
| ---------------------- | ---- | -------------------------- |
| `/`                    | GET  | 自动重定向到 Web UI        |
| `/web/`                | GET  | Web UI 首页                |
| `/web/chat.html`       | GET  | 聊天界面（支持 Reasoning） |
| `/v1/models`           | GET  | 列出可用模型               |
| `/v1/chat/completions` | POST | 聊天补全（流式/非流式）    |

## 🚀 快速开始

### 方式一：使用脚本（推荐）

Windows PowerShell:

```powershell
# 交互式菜单
.\.agent\menu.ps1

# 或直接启动
.\.agent\do.bat
```

### 方式二：使用 Cargo

```bash
# 开发模式
cargo run

# 生产模式（推荐）
cargo run --release
```

服务器将在 `http://localhost:8080` 启动 🎉

### 访问 Web UI

启动服务器后，打开浏览器访问：

- **首页**: `http://localhost:8080/` （自动跳转到 Web UI）
- **聊天界面**: `http://localhost:8080/web/chat.html`

**Web UI 特性：**

- 🎨 现代化响应式设计
- 💬 实时流式对话
- 🧠 **Reasoning 显示** - 可视化 AI 的思考过程
- 📝 Markdown 支持
- 🔄 对话历史管理
- ⚡ 流式/非流式切换

**Reasoning 功能说明：**

当 API 返回包含 `reasoning` 字段的响应时，Web UI 会以特殊样式显示：

- 顶部显示淡紫色背景的"🧠 思考过程"区域
- 实时流式更新推理内容
- 下方显示正常的回复内容

详见 [Reasoning 支持文档](.agent/docs/Stage1/reasoning-support.md)

### 📦 容器镜像

GitHub Actions 会将镜像推送到 GitHub Container Registry（GHCR）：

```bash
docker pull ghcr.io/huanlinoto/XiamenlabsUnity2API:latest
```

### 环境变量配置

```bash
# Windows PowerShell
$env:RUST_LOG="info"; cargo run --release

# Linux/macOS
RUST_LOG=info cargo run --release
```

## 🎯 Prompt 注入功能

服务器支持从 `prompt.md` 文件读取内容并自动注入到所有请求的 system prompt 中。

**快速使用：**

1. 在项目根目录创建 `prompt.md` 文件
2. 写入你想要注入的 prompt 内容
3. 重启服务器

**示例：**

```markdown
# prompt.md

你是一个专业的编程助手，请提供准确、详细的技术解答。
```

所有请求会自动在 system 消息前添加这段内容。详见 [Prompt 注入文档](.agent/docs/Stage1-Initial/prompt_injection_feature.md)

## 💡 使用示例

### cURL 测试

```bash
# 列出模型
curl http://localhost:8080/v1/models

# 聊天补全（非流式）
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"x","messages":[{"role":"user","content":"你好"}],"stream":false}'

# 聊天补全（流式）
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"x","messages":[{"role":"user","content":"你好"}],"stream":true}' \
  -N
```

### Python (openai-python)

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:8080/v1",
    api_key="dummy"  # 任意值
)

# 聊天
response = client.chat.completions.create(
    model="x",
    messages=[{"role": "user", "content": "你好"}]
)
print(response.choices[0].message.content)

# 流式聊天
stream = client.chat.completions.create(
    model="x",
    messages=[{"role": "user", "content": "你好"}],
    stream=True
)
for chunk in stream:
    print(chunk.choices[0].delta.content or "", end="")
```

### Node.js (openai-node)

```javascript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "http://localhost:8080/v1",
  apiKey: "dummy",
});

const response = await client.chat.completions.create({
  model: "x",
  messages: [{ role: "user", content: "你好" }],
});
console.log(response.choices[0].message.content);
```

### 在 AI 工具中使用

#### CherryStudio / Continue.dev / Cursor

配置自定义 OpenAI 端点：

- **Base URL**: `http://localhost:8080/v1`
- **Model**: `x`
- **API Key**: 任意值或留空

详细配置说明请查看 [USAGE.md](USAGE.md)

## 项目结构

```
src/
├── main.rs       # 主服务器入口
├── models.rs     # 数据模型定义
├── handlers.rs   # HTTP 请求处理器
└── proxy.rs      # 代理逻辑（流式/非流式）
```

## 🏗️ 技术栈

| 组件        | 技术          | 说明                   |
| ----------- | ------------- | ---------------------- |
| Web 框架    | Actix-web 4.x | 高性能异步 HTTP 服务器 |
| HTTP 客户端 | Reqwest 0.12  | 异步 HTTP 请求         |
| 序列化      | Serde 1.0     | JSON 处理              |
| 异步运行时  | Tokio 1.x     | 异步任务调度           |
| 日志        | env_logger    | 结构化日志             |

## 📁 项目结构

```
src/
├── main.rs       # 服务器入口和路由配置
├── models.rs     # OpenAI/XiamenLabs 数据模型
├── handlers.rs   # HTTP 请求处理器
└── proxy.rs      # API 转发和格式转换逻辑
```

## 🔧 开发说明

### 构建

```bash
# Debug 构建
cargo build

# Release 构建（生产环境）
cargo build --release
```

### 测试

```bash
# 运行测试脚本
.\.agent\test_quick.ps1

# 或使用完整测试套件
.\.agent\tests\Stage1-Initial\test_api.ps1
```

### 日志级别

通过 `RUST_LOG` 环境变量控制：

- `trace` - 最详细
- `debug` - 调试信息
- `info` - 常规信息（默认）
- `warn` - 警告
- `error` - 仅错误

示例：

```powershell
$env:RUST_LOG="debug"; cargo run
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

## 🔗 相关链接

- [详细使用文档](USAGE.md)
- [实现笔记](.agent/docs/Stage1-Initial/implementation_notes.md)
- [项目总结](.agent/docs/Stage1-Initial/project_summary.md)

---

**Made with ❤️ using Rust**
