# Reasoning 功能支持文档

## 功能概述

Web 前端现已支持显示 AI 模型的推理过程（reasoning）。当模型返回包含 `reasoning` 字段的流式响应时，前端会以特殊样式展示这些思考过程。

## API 响应格式

XiamenLabs API 会返回包含 `reasoning` 字段的流式响应，格式如下：

```json
{
  "id": "chatcmpl-xx-4a66880b0e7e6be405114ff8",
  "object": "chat.completion.chunk",
  "created": 1767804560,
  "model": "x",
  "choices": [
    {
      "index": 0,
      "delta": {
        "reasoning": "**接收指令**\n我刚刚收到了关于我的新指令，让我仔细地阅读和理解它们。这里面包含了很多关于身份、语气和行为准则的信息，需要我好好消化。我正在确保我完全明白所有的细微之处。\n\n"
      },
      "finish_reason": null
    }
  ]
}
```

## 前端展示效果

### 1. 推理内容（Reasoning）

- 显示在消息内容上方
- 使用淡紫色背景和左侧蓝色边框
- 带有 🧠 图标和"思考过程"标题
- 支持 Markdown 格式和换行

### 2. 回复内容（Content）

- 显示在推理内容下方
- 使用正常的消息样式
- 可包含代码块、格式化文本等

### 3. 流式更新

- 推理内容和回复内容都支持实时流式更新
- 自动滚动到最新内容
- 平滑的显示效果

## 实现细节

### CSS 样式

```css
/* 推理内容样式 */
.reasoning-section {
  background: rgba(79, 70, 229, 0.05);
  border-left: 3px solid var(--primary-color);
  padding: 0.75rem 1rem;
  margin: 0.5rem 0;
  border-radius: 0.5rem;
  font-size: 0.9rem;
}

.reasoning-header {
  font-weight: 600;
  color: var(--primary-color);
  margin-bottom: 0.5rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.reasoning-content {
  color: var(--text-secondary);
  white-space: pre-wrap;
  line-height: 1.6;
}
```

### JavaScript 处理逻辑

```javascript
// 在 sendStreamingRequest() 函数中
let fullReasoning = "";
let reasoningSection = null;
let contentSection = null;

// 处理推理内容
if (delta?.reasoning) {
  fullReasoning += delta.reasoning;

  // 创建或更新推理区域
  if (!reasoningSection) {
    reasoningSection = document.createElement("div");
    reasoningSection.className = "reasoning-section";
    reasoningSection.innerHTML = `
            <div class="reasoning-header">
                <span>🧠</span>
                <span>思考过程</span>
            </div>
            <div class="reasoning-content"></div>
        `;
    messageContent.appendChild(reasoningSection);
  }

  const reasoningContent = reasoningSection.querySelector(".reasoning-content");
  reasoningContent.textContent = fullReasoning;
  scrollToBottom();
}

// 处理正常回复内容
if (delta?.content) {
  fullResponse += delta.content;

  if (!contentSection) {
    contentSection = document.createElement("div");
    contentSection.className = "response-content";
    messageContent.appendChild(contentSection);
  }

  contentSection.textContent = fullResponse;
  scrollToBottom();
}
```

## 使用示例

### 测试步骤

1. 启动服务器：

   ```bash
   cargo run --release
   ```

2. 打开浏览器访问：`http://localhost:8080/`

3. 点击"打开聊天界面"

4. 输入任何问题，观察响应

5. 如果 API 返回包含 reasoning 字段的响应，你会看到：
   - 顶部显示带有 🧠 图标的"思考过程"区域（淡紫色背景）
   - 下方显示正常的回复内容

### API 测试

使用 cURL 测试 API：

```bash
curl -N http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "x",
    "messages": [{"role": "user", "content": "你好"}],
    "stream": true
  }'
```

## 兼容性说明

- ✅ 向后兼容：如果 API 不返回 `reasoning` 字段，前端会正常显示回复内容
- ✅ 同时支持：可以在同一个响应中同时包含 `reasoning` 和 `content`
- ✅ 顺序灵活：`reasoning` 和 `content` 可以以任意顺序出现
- ✅ 流式友好：支持 reasoning 和 content 交替出现的流式响应

## 视觉效果

```
┌─────────────────────────────────────┐
│ 🤖 助手                             │
│ ┌───────────────────────────────┐   │
│ │ 🧠 思考过程                    │   │
│ │ ┌─────────────────────────┐   │   │
│ │ │ **接收指令**             │   │   │
│ │ │ 我刚刚收到了新指令...    │   │   │
│ │ └─────────────────────────┘   │   │
│ └───────────────────────────────┘   │
│                                     │
│ 你好！我是 AI 助手，很高兴认识你... │
└─────────────────────────────────────┘
```

## 更新日志

### 2026-01-08

- ✅ 添加 reasoning 字段支持
- ✅ 添加推理内容专属样式
- ✅ 实现流式 reasoning 更新
- ✅ 优化视觉层次结构
- ✅ 添加 🧠 图标标识

## 下一步优化建议

1. **可折叠推理区域**：允许用户折叠/展开思考过程
2. **Markdown 渲染**：对 reasoning 内容应用 Markdown 渲染
3. **语法高亮**：如果 reasoning 包含代码，添加语法高亮
4. **复制功能**：单独复制推理内容或回复内容
5. **导出功能**：导出包含推理过程的完整对话

## 相关文件

- `web/index.html` - 包含 reasoning 支持的前端代码
- `src/proxy.rs` - API 代理逻辑
- `src/handlers.rs` - 请求处理器
- `.agent/docs/Stage1/reasoning-support.md` - 本文档
