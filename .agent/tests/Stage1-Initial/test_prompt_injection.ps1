# 测试 Prompt 注入功能

Write-Host "==================================" -ForegroundColor Green
Write-Host "测试 Prompt 注入功能" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green

# 检查 prompt.md 是否存在
if (Test-Path "prompt.md") {
    Write-Host "`n✓ prompt.md 文件存在" -ForegroundColor Green
    Write-Host "内容预览:" -ForegroundColor Cyan
    Get-Content "prompt.md" -Head 5
    Write-Host "..." -ForegroundColor Gray
} else {
    Write-Host "`n✗ prompt.md 文件不存在，将使用默认配置" -ForegroundColor Yellow
}

Write-Host "`n测试 1: 发送不带 system 消息的请求" -ForegroundColor Cyan
Write-Host "预期: prompt.md 内容会作为 system 消息添加" -ForegroundColor Gray

$body1 = @{
    model = "x"
    messages = @(
        @{
            role = "user"
            content = "请简单介绍一下你自己"
        }
    )
    stream = $false
} | ConvertTo-Json -Depth 10

try {
    Write-Host "发送请求..." -ForegroundColor Gray
    $response1 = Invoke-RestMethod -Uri "http://localhost:8080/v1/chat/completions" -Method Post -Body $body1 -ContentType "application/json"
    Write-Host "✓ 请求成功" -ForegroundColor Green
    Write-Host "`n回复内容:" -ForegroundColor Cyan
    Write-Host $response1.choices[0].message.content -ForegroundColor White
} catch {
    Write-Host "✗ 请求失败: $_" -ForegroundColor Red
}

Write-Host "`n`n测试 2: 发送带 system 消息的请求" -ForegroundColor Cyan
Write-Host "预期: prompt.md 内容会添加到原有 system 消息前面" -ForegroundColor Gray

$body2 = @{
    model = "x"
    messages = @(
        @{
            role = "system"
            content = "你是一个友好的助手"
        },
        @{
            role = "user"
            content = "你好，你的身份是什么？"
        }
    )
    stream = $false
} | ConvertTo-Json -Depth 10

try {
    Write-Host "发送请求..." -ForegroundColor Gray
    $response2 = Invoke-RestMethod -Uri "http://localhost:8080/v1/chat/completions" -Method Post -Body $body2 -ContentType "application/json"
    Write-Host "✓ 请求成功" -ForegroundColor Green
    Write-Host "`n回复内容:" -ForegroundColor Cyan
    Write-Host $response2.choices[0].message.content -ForegroundColor White
} catch {
    Write-Host "✗ 请求失败: $_" -ForegroundColor Red
}

Write-Host "`n`n测试 3: 流式请求" -ForegroundColor Cyan
Write-Host "预期: 流式请求也会注入 prompt" -ForegroundColor Gray

$body3 = @{
    model = "x"
    messages = @(
        @{
            role = "user"
            content = "数到3"
        }
    )
    stream = $true
} | ConvertTo-Json -Depth 10 -Compress

try {
    Write-Host "发送流式请求..." -ForegroundColor Gray
    $curlCommand = "curl -X POST http://localhost:8080/v1/chat/completions -H 'Content-Type: application/json' -d '$($body3 -replace "'", "''")' -N --no-buffer"
    Invoke-Expression $curlCommand
    Write-Host "`n✓ 流式请求完成" -ForegroundColor Green
} catch {
    Write-Host "✗ 流式请求失败: $_" -ForegroundColor Red
}

Write-Host "`n==================================" -ForegroundColor Green
Write-Host "测试完成" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host "`n提示: 修改 prompt.md 后需要重启服务器才能生效" -ForegroundColor Yellow
