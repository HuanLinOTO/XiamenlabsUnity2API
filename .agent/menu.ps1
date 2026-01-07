#!/usr/bin/env pwsh

# 使用说明和快速启动脚本

Write-Host "==================================" -ForegroundColor Green
Write-Host "XiamenLabs OpenAI Proxy" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "选择操作:" -ForegroundColor Cyan
Write-Host "1. 启动服务器" -ForegroundColor White
Write-Host "2. 打开 Web UI (浏览器)" -ForegroundColor White
Write-Host "3. 测试 /v1/models" -ForegroundColor White
Write-Host "4. 测试聊天（非流式）" -ForegroundColor White
Write-Host "5. 构建 Release 版本" -ForegroundColor White
Write-Host "6. 查看使用文档" -ForegroundColor White
Write-Host "0. 退出" -ForegroundColor White
Write-Host ""

$choice = Read-Host "请输入选项 (0-6)"

switch ($choice) {
    "1" {
        Write-Host "`n正在启动服务器..." -ForegroundColor Cyan
        Write-Host "服务器将在 http://localhost:8080 启动" -ForegroundColor Yellow
        Write-Host "Web UI: http://localhost:8080/" -ForegroundColor Cyan
        Write-Host "Chat:   http://localhost:8080/web/chat.html" -ForegroundColor Cyan
        Write-Host "按 Ctrl+C 停止服务器`n" -ForegroundColor Yellow
        
        # 检查 prompt.md
        if (-not (Test-Path "prompt.md")) {
            Write-Host "⚠️  prompt.md 不存在，从示例文件复制..." -ForegroundColor Yellow
            if (Test-Path "prompt.md.example") {
                Copy-Item "prompt.md.example" "prompt.md"
                Write-Host "✓ 已创建 prompt.md`n" -ForegroundColor Green
            }
        }
        
        $env:RUST_LOG = "info"
        cargo run --release
    }
    "2" {
        Write-Host "`n正在打开 Web UI..." -ForegroundColor Cyan
        Start-Process "http://localhost:8080/"
        Write-Host "✓ 已在浏览器中打开" -ForegroundColor Green
        Write-Host "如果服务器未运行，请先选择选项 1" -ForegroundColor Yellow
    }
    "3" {
        Write-Host "`n测试 /v1/models 端点..." -ForegroundColor Cyan
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/models" -Method Get
            Write-Host "✓ 成功!" -ForegroundColor Green
            $response | ConvertTo-Json -Depth 5
        } catch {
            Write-Host "✗ 失败: $_" -ForegroundColor Red
            Write-Host "提示: 请先启动服务器 (选项 1)" -ForegroundColor Yellow
        }
    }
    "4" {
        Write-Host "`n测试聊天补全..." -ForegroundColor Cyan
        $body = @{
            model = "x"
            messages = @(
                @{ role = "system"; content = "Be a helpful assistant" },
                @{ role = "user"; content = "你好，请简单介绍一下你自己" }
            )
            stream = $false
        } | ConvertTo-Json -Depth 10
        
        try {
            Write-Host "发送请求..." -ForegroundColor Gray
            $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/chat/completions" -Method Post -Body $body -ContentType "application/json"
            Write-Host "✓ 成功!" -ForegroundColor Green
            Write-Host "`n回复:" -ForegroundColor Cyan
            Write-Host $response.choices[0].message.content -ForegroundColor White
        } catch {
            Write-Host "✗ 失败: $_" -ForegroundColor Red
            Write-Host "提示: 请先启动服务器 (选项 1)" -ForegroundColor Yellow
        }
    }
    "5" {
        Write-Host "`n构建 Release 版本..." -ForegroundColor Cyan
        cargo build --release
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✓ 构建成功!" -ForegroundColor Green
            Write-Host "可执行文件位置: target\release\xiamenlabs-openai-proxy.exe" -ForegroundColor Yellow
        }
    }
    "6" {
        Write-Host "`n打开使用文档..." -ForegroundColor Cyan
        if (Test-Path "USAGE.md") {
            code USAGE.md
        } else {
            Write-Host "✗ 文档文件不存在" -ForegroundColor Red
        }
    }
    "0" {
        Write-Host "`n再见!" -ForegroundColor Green
        exit 0
    }
    default {
        Write-Host "`n无效选项" -ForegroundColor Red
    }
}
