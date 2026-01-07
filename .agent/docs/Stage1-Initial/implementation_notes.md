# Stage 1: 初始项目创建

## 项目概述

创建一个 Rust 编写的 OpenAI 兼容代理服务器，用于中转 XiamenLabs API。

## 完成的工作

### 1. 项目结构

```
XiamenlabsUnity2API/
├── Cargo.toml          # 项目依赖配置
├── README.md           # 项目文档
├── .gitignore          # Git 忽略文件
└── src/
    ├── main.rs         # 主程序入口
    ├── models.rs       # 数据模型
    ├── handlers.rs     # HTTP 处理器
    └── proxy.rs        # 代理逻辑
```

### 2. 核心功能

#### 2.1 支持的端点

- `GET /v1/models` - 列出可用模型
- `POST /v1/chat/completions` - 聊天补全（支持流式和非流式）

#### 2.2 流式响应处理

- 将 XiamenLabs API 的 SSE 格式转换为 OpenAI 兼容格式
- 支持实时流式输出
- 正确处理 `[DONE]` 标记

#### 2.3 非流式响应处理

- 完整响应后返回
- 符合 OpenAI API 格式

### 3. 技术实现细节

#### 3.1 请求转换

XiamenLabs API 格式：

```json
{
  "model": "x",
  "messages": [...],
  "stream": true
}
```

OpenAI API 格式：

```json
{
  "model": "x",
  "messages": [...],
  "stream": true,
  "temperature": 0.7,  // 可选
  "max_tokens": 1000   // 可选
}
```

#### 3.2 响应转换

流式响应块格式：

```json
{
  "id": "chatcmpl-{uuid}",
  "object": "chat.completion.chunk",
  "created": {timestamp},
  "model": "x",
  "choices": [{
    "index": 0,
    "delta": {
      "content": "..."
    },
    "finish_reason": null
  }]
}
```

#### 3.3 请求头设置

完整复制了浏览器请求头，包括：

- User-Agent 相关（sec-ch-ua）
- 安全相关（sec-fetch-\*）
- 缓存控制
- Referer

### 4. 依赖项

- `actix-web` - Web 服务器框架
- `actix-cors` - CORS 支持
- `reqwest` - HTTP 客户端
- `serde` - 序列化/反序列化
- `tokio` - 异步运行时
- `uuid` - UUID 生成
- `env_logger` - 日志记录

## 下一步计划

1. 测试服务器功能
2. 优化错误处理
3. 添加配置文件支持
4. 添加更多模型支持
5. 性能优化

## 已知问题

1. 需要实际测试 XiamenLabs API 的响应格式
2. 可能需要根据实际响应调整解析逻辑
3. Usage 字段当前为占位符（0 值）

## 测试建议

1. 先测试 `/v1/models` 端点
2. 测试非流式聊天补全
3. 测试流式聊天补全
4. 验证错误处理逻辑
