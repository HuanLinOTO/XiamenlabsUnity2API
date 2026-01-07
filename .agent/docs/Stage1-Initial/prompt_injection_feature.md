# Prompt 注入功能说明

## 功能概述

服务器会自动读取项目根目录下的 `prompt.md` 文件，并将其内容注入到每个请求的 system prompt 中。

## 工作原理

1. **自动加载**: 服务器启动时会读取 `prompt.md` 文件内容并缓存
2. **智能注入**:
   - 如果请求中已有 system 消息，prompt 内容会添加到该消息的**开头**
   - 如果请求中没有 system 消息，会自动创建一个新的 system 消息
3. **性能优化**: 使用 `OnceLock` 缓存文件内容，只读取一次

## 使用方法

### 1. 编辑 prompt.md

在项目根目录创建或编辑 `prompt.md` 文件：

```markdown
# 自定义 System Prompt

你是一个专业的 AI 助手，请遵循以下规范：

- 回答要准确、专业
- 使用友好的语气
- 提供详细的解释
```

### 2. 重启服务器

修改 `prompt.md` 后需要重启服务器才能生效（因为内容被缓存）。

```powershell
# 停止服务器 (Ctrl+C)
# 重新启动
cargo run --release
```

### 3. 测试效果

发送请求时，prompt 会自动注入：

```powershell
$body = @{
    model = "x"
    messages = @(
        @{ role = "user"; content = "你好" }
    )
    stream = $false
} | ConvertTo-Json

Invoke-RestMethod http://localhost:8080/v1/chat/completions -Method Post -Body $body -ContentType "application/json"
```

实际发送给 XiamenLabs API 的消息会是：

```json
{
  "messages": [
    {
      "role": "system",
      "content": "# 自定义 System Prompt\n\n你是一个专业的 AI 助手..."
    },
    {
      "role": "user",
      "content": "你好"
    }
  ]
}
```

## 示例场景

### 场景 1: 添加知识库

```markdown
# 知识库增强

以下是公司的产品信息：

- 产品 A: 企业级解决方案
- 产品 B: 个人版工具

回答用户问题时请参考以上信息。
```

### 场景 2: 设定角色

```markdown
# 角色设定

你是一个 Python 编程专家，拥有 10 年以上的开发经验。
请用专业但易懂的方式回答编程相关问题。
```

### 场景 3: 输出格式控制

```markdown
# 输出格式要求

请始终按以下格式回答：

1. 简短总结（1-2 句话）
2. 详细解释
3. 示例代码（如适用）
```

### 场景 4: 保持用户的 system prompt

如果用户请求中已经有 system prompt：

**用户请求:**

```json
{
  "messages": [
    {
      "role": "system",
      "content": "你是一个友好的助手"
    },
    {
      "role": "user",
      "content": "你好"
    }
  ]
}
```

**实际发送（prompt.md 内容会添加在前面）:**

```json
{
  "messages": [
    {
      "role": "system",
      "content": "# 自定义 System Prompt\n\n[prompt.md 的内容]\n\n你是一个友好的助手"
    },
    {
      "role": "user",
      "content": "你好"
    }
  ]
}
```

## 注意事项

1. **文件编码**: 请使用 UTF-8 编码保存 `prompt.md`
2. **重启生效**: 修改后需要重启服务器
3. **文件不存在**: 如果 `prompt.md` 不存在，服务器会记录警告但正常运行
4. **性能影响**: 几乎无性能影响，因为文件内容被缓存
5. **透明性**: 这个注入对客户端是透明的，客户端不知道 prompt 被修改

## 日志

服务器会记录相关日志：

```
[INFO] Loaded prompt from prompt.md: 245 characters
[DEBUG] Enhanced existing system message
```

或

```
[WARN] Failed to load prompt from prompt.md: No such file or directory (os error 2). Using empty prompt.
```

## 禁用功能

如果不想使用此功能，有两种方法：

1. **删除或重命名 prompt.md**: 服务器会自动跳过注入
2. **清空 prompt.md**: 空文件也会被忽略

## 高级用法

### 动态重载（需要修改代码）

如果需要支持不重启服务器就能重新加载 prompt，可以修改代码移除 `OnceLock` 缓存，每次请求都读取文件。但这会有轻微的性能影响。
