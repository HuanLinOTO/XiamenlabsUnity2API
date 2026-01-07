#!/usr/bin/env pwsh

# 编译并运行服务器
Write-Host "Building and running XiamenLabs OpenAI Proxy..." -ForegroundColor Green

# 检查 prompt.md
if (-not (Test-Path "prompt.md")) {
    Write-Host "`n⚠️  prompt.md 不存在，从示例文件复制..." -ForegroundColor Yellow
    if (Test-Path "prompt.md.example") {
        Copy-Item "prompt.md.example" "prompt.md"
        Write-Host "✓ 已创建 prompt.md" -ForegroundColor Green
    }
}

# 设置环境变量
$env:RUST_LOG = "info"

# 构建项目
Write-Host "`nBuilding project..." -ForegroundColor Cyan
cargo build --release

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBuild successful!" -ForegroundColor Green
    Write-Host "`n==================================" -ForegroundColor Green
    Write-Host "服务器启动信息" -ForegroundColor Green
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "🌐 Web UI:  http://localhost:8080/" -ForegroundColor Cyan
    Write-Host "💬 Chat:    http://localhost:8080/web/chat.html" -ForegroundColor Cyan
    Write-Host "🔌 API:     http://localhost:8080/v1/" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Green
    Write-Host "`nPress Ctrl+C to stop the server" -ForegroundColor Yellow
    Write-Host ""
    
    # 运行服务器
    cargo run --release
} else {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    exit 1
}
