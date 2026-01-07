# XiamenLabs OpenAI Proxy - 使用指南

## 快速开始

### 1. 启动服务器

```powershell
# 方式一：直接运行
cargo run --release

# 方式二：使用脚本
.\.agent\do.bat
```

服务器将在 `http://localhost:8080` 启动

### 2. (可选) 配置 Prompt 注入

在项目根目录创建 `prompt.md` 文件，添加你想要自动注入到所有请求的内容：

```markdown
# 示例 prompt.md

你是一个专业的技术助手，请提供准确、详细的解答。
```

**注意**: 修改 prompt.md 后需要重启服务器才能生效。详见下方 "Prompt 注入功能" 章节。

### 3. 测试 API

#### 使用 PowerShell 测试

##### 获取模型列表

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/v1/models" -Method Get | ConvertTo-Json
```

##### 非流式聊天

```powershell
$body = @{
    model = "x"
    messages = @(
        @{ role = "system"; content = "Be a helpful assistant" },
        @{ role = "user"; content = "你好" }
    )
    stream = $false
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "http://localhost:8080/v1/chat/completions" `
    -Method Post `
    -Body $body `
    -ContentType "application/json" | ConvertTo-Json
```

##### 流式聊天（使用 curl）

```powershell
$body = '{"model":"x","messages":[{"role":"user","content":"数到5"}],"stream":true}'
curl -X POST http://localhost:8080/v1/chat/completions `
    -H "Content-Type: application/json" `
    -d $body `
    -N
```

#### 使用 Python 测试

```python
from openai import OpenAI

# 配置客户端
client = OpenAI(
    base_url="http://localhost:8080/v1",
    api_key="dummy"  # XiamenLabs API 不需要 key，但 OpenAI SDK 需要
)

# 非流式
response = client.chat.completions.create(
    model="x",
    messages=[
        {"role": "system", "content": "Be a helpful assistant"},
        {"role": "user", "content": "你好"}
    ]
)
print(response.choices[0].message.content)

# 流式
stream = client.chat.completions.create(
    model="x",
    messages=[{"role": "user", "content": "数到5"}],
    stream=True
)
for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end="")
```

#### 使用 Node.js 测试

```javascript
import OpenAI from "openai";

const client = new OpenAI({
  baseURL: "http://localhost:8080/v1",
  apiKey: "dummy",
});

// 非流式
const response = await client.chat.completions.create({
  model: "x",
  messages: [{ role: "user", content: "你好" }],
});
console.log(response.choices[0].message.content);

// 流式
const stream = await client.chat.completions.create({
  model: "x",
  messages: [{ role: "user", content: "数到5" }],
  stream: true,
});

for await (const chunk of stream) {
  process.stdout.write(chunk.choices[0]?.delta?.content || "");
}
```

## 在应用中使用

### CherryStudio

1. 打开 CherryStudio 设置
2. 添加新的 API 提供商
3. 配置：
   - API URL: `http://localhost:8080/v1`
   - 模型: `x`
   - API Key: 留空或任意值

### Continue.dev

在 `.continue/config.json` 中添加：

```json
{
  "models": [
    {
      "title": "XiamenLabs",
      "provider": "openai",
      "model": "x",
      "apiBase": "http://localhost:8080/v1",
      "apiKey": "dummy"
    }
  ]
}
```

### Cursor

在设置中添加自定义 OpenAI 兼容端点：

- Base URL: `http://localhost:8080/v1`
- Model: `x`

## API 端点

### GET /v1/models

返回可用模型列表

**响应示例：**

```json
{
  "object": "list",
  "data": [
    {
      "id": "x",
      "object": "model",
      "created": 1700000000,
      "owned_by": "xiamenlabs"
    }
  ]
}
```

### POST /v1/chat/completions

创建聊天补全

**请求体：**

```json
{
  "model": "x",
  "messages": [
    { "role": "system", "content": "..." },
    { "role": "user", "content": "..." }
  ],
  "stream": false
}
```

**参数：**

- `model` (string, required): 模型 ID，固定为 "x"
- `messages` (array, required): 消息数组
- `stream` (boolean, optional): 是否使用流式响应，默认 false
- `temperature` (float, optional): 采样温度（暂未实现）
- `max_tokens` (integer, optional): 最大 token 数（暂未实现）

**非流式响应：**

```json
{
  "id": "chatcmpl-xxx",
  "object": "chat.completion",
  "created": 1234567890,
  "model": "x",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 0,
    "completion_tokens": 0,
    "total_tokens": 0
  }
}
```

**流式响应（SSE）：**

```
data: {"id":"chatcmpl-xxx","object":"chat.completion.chunk","created":1234567890,"model":"x","choices":[{"index":0,"delta":{"content":"你"},"finish_reason":null}]}

data: {"id":"chatcmpl-xxx","object":"chat.completion.chunk","created":1234567890,"model":"x","choices":[{"index":0,"delta":{"content":"好"},"finish_reason":null}]}

data: [DONE]
```

## 环境变量

- `RUST_LOG`: 日志级别 (trace, debug, info, warn, error)
  - 示例: `RUST_LOG=debug cargo run`

## Prompt 注入功能

### 功能说明

服务器支持从项目根目录的 `prompt.md` 文件读取内容，并自动注入到所有请求的 system prompt 中。

### 使用方法

**1. 创建 prompt.md 文件**

在项目根目录创建 `prompt.md`：

```markdown
# 自定义 System Prompt

你是一个专业的 AI 助手，请遵循以下规范：

- 回答要准确、专业
- 使用友好的语气
- 提供详细的解释
```

**2. 重启服务器**

修改 `prompt.md` 后需要重启服务器才能生效（内容会被缓存）。

**3. 自动注入**

- 如果请求中**没有** system 消息，会自动创建一个包含 prompt.md 内容的 system 消息
- 如果请求中**已有** system 消息，prompt.md 内容会添加到该消息的**开头**

### 示例

**原始请求：**

```json
{
  "messages": [{ "role": "user", "content": "你好" }]
}
```

**实际发送（自动添加 system 消息）：**

```json
{
  "messages": [
    { "role": "system", "content": "[prompt.md 的内容]" },
    { "role": "user", "content": "你好" }
  ]
}
```

**如果请求已有 system 消息：**

```json
{
  "messages": [{ "role": "system", "content": "你是友好的助手" }]
}
```

**会变成：**

```json
{
  "messages": [
    { "role": "system", "content": "[prompt.md 内容]\n\n你是友好的助手" }
  ]
}
```

### 测试

运行测试脚本：

```powershell
.\.agent\tests\Stage1-Initial\test_prompt_injection.ps1
```

### 详细文档

查看完整文档：[Prompt 注入功能说明](.agent/docs/Stage1-Initial/prompt_injection_feature.md)

## 故障排除

### 端口被占用

如果 8080 端口被占用，修改 `src/main.rs` 中的端口号：

```rust
.bind(("0.0.0.0", 8080))? // 改为其他端口
```

### 连接 XiamenLabs API 失败

- 检查网络连接
- 确认 XiamenLabs API 是否可用
- 查看服务器日志获取详细错误信息

### CORS 错误

服务器已配置宽松的 CORS 策略。如果仍有问题，检查浏览器控制台的具体错误。

## 性能调优

### 发布构建

使用 release 模式获得最佳性能：

```bash
cargo build --release
./target/release/xiamenlabs-openai-proxy
```

### 调整工作线程数

在 `src/main.rs` 中：

```rust
HttpServer::new(|| {
    // ...
})
.workers(4) // 设置工作线程数
.bind(("0.0.0.0", 8080))?
```

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License
