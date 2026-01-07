# 更新日志 (CHANGELOG)

所有重要的变更都会记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

---

## [1.1.0] - 2026-01-08

### 新增 ✨

- **Reasoning 支持** - Web UI 现在可以显示 AI 模型的推理过程
  - 新增推理内容专属视觉区域（淡紫色背景 + 蓝色边框）
  - 🧠 图标标识和"思考过程"标题
  - 实时流式更新推理内容
  - 支持 `delta.reasoning` 和 `delta.content` 同时显示
  - 保留换行和空格格式
- **文档增强**
  - 新增 `reasoning-support.md` - 完整功能文档
  - 新增 `reasoning-implementation-summary.md` - 实现总结
  - 新增 `feature-checklist.md` - 功能清单
  - 新增 `acceptance-checklist.md` - 验收清单
- **测试工具**
  - 新增 `test-reasoning.ps1` - Reasoning 功能测试脚本

### 改进 🔧

- **Web UI (`web/index.html`)**
  - 优化 `sendStreamingRequest()` 函数
  - 改进 DOM 结构，分离推理和回复内容
  - 增强流式更新逻辑
- **启动脚本 (`start.ps1`)**
  - 添加 Reasoning 功能说明
  - 更新文档链接
- **README.md**
  - 添加 Reasoning 功能介绍
  - 更新端点说明表格
  - 新增 Web UI 特性说明

### 技术细节 📋

- CSS: 新增 3 个样式类
  - `.reasoning-section`
  - `.reasoning-header`
  - `.reasoning-content`
- JavaScript: 修改约 60 行代码
  - 新增 `fullReasoning` 变量
  - 新增 `reasoningSection` 和 `contentSection` 管理
  - 优化 SSE 解析逻辑

### 兼容性 ✅

- 完全向后兼容 - 不影响现有功能
- 支持只有 `content` 的响应（原有行为）
- 支持只有 `reasoning` 的响应
- 支持同时包含两者的响应
- 支持交替出现的流式响应

### 已知限制 ⚠️

- 非流式响应暂不支持 reasoning 显示（待后续版本）
- Reasoning 内容暂不支持 Markdown 渲染（待后续版本）

---

## [1.0.0] - 2026-01-07

### 新增 ✨

- **核心功能**
  - OpenAI 兼容的 API 代理服务器
  - `/v1/models` 端点 - 列出可用模型
  - `/v1/chat/completions` 端点 - 聊天补全
  - 流式响应支持 (SSE)
  - 非流式响应支持
- **Prompt 注入**
  - 从 `prompt.md` 文件读取自定义 prompt
  - 自动注入到 system 消息
  - OnceLock 缓存机制
- **Web UI**
  - 现代化聊天界面
  - 响应式设计
  - 实时流式对话
  - 对话历史管理
  - 流式/非流式切换
  - 快速操作按钮
- **部署支持**
  - GitHub Actions CI/CD
  - 多平台构建 (Linux, Windows, macOS)
  - Docker 镜像支持
  - Dockerfile 配置
- **开发工具**
  - `menu.ps1` - 交互式菜单
  - `start.ps1` - 快速启动脚本
  - `do.bat` - 编译运行脚本

### 技术栈 🛠️

- Rust 1.75+
- Actix-web 4.9
- Actix-files 0.6
- Reqwest 0.12
- Serde 1.0
- Tokio 1.x
- HTML5 / CSS3 / JavaScript

### 文档 📚

- README.md - 主文档
- USAGE.md - 使用说明
- DOCKER.md - Docker 部署指南
- Prompt 注入功能文档

---

## 版本说明

### 版本号格式

`MAJOR.MINOR.PATCH`

- **MAJOR**: 不兼容的 API 变更
- **MINOR**: 向下兼容的新功能
- **PATCH**: 向下兼容的问题修复

### 变更类型

- `新增` - 新功能
- `改进` - 对现有功能的改进
- `修复` - Bug 修复
- `移除` - 移除的功能
- `弃用` - 即将移除的功能
- `安全` - 安全相关的修复

---

## 即将发布

### [1.2.0] - 计划中

- [ ] 非流式响应的 reasoning 支持
- [ ] Reasoning 区域折叠/展开功能
- [ ] Markdown 渲染支持
- [ ] 复制推理内容按钮
- [ ] 代码语法高亮
- [ ] 导出对话功能

### [1.3.0] - 规划中

- [ ] 多模型支持
- [ ] 对话分支管理
- [ ] 高级 Prompt 模板系统
- [ ] 用户自定义主题
- [ ] 对话搜索功能

---

## 链接

- [项目主页](../../README.md)
- [使用文档](../../USAGE.md)
- [Docker 指南](../../DOCKER.md)
- [Reasoning 功能文档](.agent/docs/Stage1/reasoning-support.md)

---

**格式说明**

- [版本号] - 日期 格式: YYYY-MM-DD
- 使用表情符号增强可读性
- 按类型分组变更内容
- 链接到相关文档和 Issue

**维护者**: XiamenLabs OpenAI Proxy Team
**最后更新**: 2026-01-08
