#!/usr/bin/env pwsh

# 测试 Reasoning 功能

Write-Host "==================================" -ForegroundColor Green
Write-Host "测试 Reasoning 功能" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

Write-Host "📝 说明:" -ForegroundColor Cyan
Write-Host "   此脚本将测试前端对 reasoning 字段的支持" -ForegroundColor White
Write-Host "   如果 API 返回包含 reasoning 的响应，前端将以特殊样式显示" -ForegroundColor White
Write-Host ""

Write-Host "📋 测试步骤:" -ForegroundColor Cyan
Write-Host "   1. 确保服务器正在运行 (http://localhost:8080)" -ForegroundColor White
Write-Host "   2. 打开浏览器访问聊天界面" -ForegroundColor White
Write-Host "   3. 发送任意消息" -ForegroundColor White
Write-Host "   4. 观察响应中的'思考过程'区域" -ForegroundColor White
Write-Host ""

Write-Host "🎨 预期效果:" -ForegroundColor Cyan
Write-Host "   - 如果有 reasoning: 显示淡紫色背景的'🧠 思考过程'区域" -ForegroundColor White
Write-Host "   - 推理内容会实时流式更新" -ForegroundColor White
Write-Host "   - 回复内容显示在推理内容下方" -ForegroundColor White
Write-Host ""

$choice = Read-Host "是否检查服务器状态? (Y/n)"
if ($choice -ne "n" -and $choice -ne "N") {
    Write-Host "`n检查服务器..." -ForegroundColor Cyan
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/models" -Method Get -ErrorAction Stop
        Write-Host "✅ 服务器运行正常" -ForegroundColor Green
        Write-Host "   模型: $($response.data[0].id)" -ForegroundColor Gray
    } catch {
        Write-Host "❌ 服务器未运行或无法连接" -ForegroundColor Red
        Write-Host "   请先运行: .\.agent\start.ps1" -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
}

Write-Host ""
$openBrowser = Read-Host "是否打开聊天界面? (Y/n)"
if ($openBrowser -ne "n" -and $openBrowser -ne "N") {
    Write-Host "`n正在打开浏览器..." -ForegroundColor Cyan
    Start-Process "http://localhost:8080/"
    Write-Host "✅ 已打开: http://localhost:8080/" -ForegroundColor Green
}

Write-Host ""
Write-Host "📚 查看详细文档:" -ForegroundColor Cyan
Write-Host "   .agent\docs\Stage1\reasoning-support.md" -ForegroundColor White
Write-Host ""
Write-Host "完成!" -ForegroundColor Green
