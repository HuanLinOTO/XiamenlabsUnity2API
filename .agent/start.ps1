#!/usr/bin/env pwsh

Write-Host "==================================" -ForegroundColor Green
Write-Host "XiamenLabs OpenAI Proxy" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

# 检查 prompt.md 是否存在
if (-not (Test-Path "prompt.md")) {
    Write-Host "⚠️  prompt.md 不存在，从示例文件复制..." -ForegroundColor Yellow
    if (Test-Path "prompt.md.example") {
        Copy-Item "prompt.md.example" "prompt.md"
        Write-Host "✓ 已创建 prompt.md" -ForegroundColor Green
    }
}

Write-Host "正在启动服务器..." -ForegroundColor Cyan
Write-Host ""
Write-Host "服务将运行在:" -ForegroundColor White
Write-Host "  🌐 Web UI:  http://localhost:8080/" -ForegroundColor Cyan
Write-Host "  💬 Chat:    http://localhost:8080/web/chat.html" -ForegroundColor Cyan
Write-Host "  🔌 API:     http://localhost:8080/v1/" -ForegroundColor Cyan
Write-Host ""
Write-Host "🧠 新功能: Reasoning 支持" -ForegroundColor Yellow
Write-Host "  Web UI 现在可以显示 AI 的思考过程" -ForegroundColor White
Write-Host "  详见: .agent\docs\Stage1\reasoning-support.md" -ForegroundColor Gray
Write-Host ""
Write-Host "按 Ctrl+C 停止服务器" -ForegroundColor Yellow
Write-Host ""

$env:RUST_LOG = "info"
cargo run --release
