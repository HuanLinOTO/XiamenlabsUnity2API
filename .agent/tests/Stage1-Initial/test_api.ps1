# 测试脚本 - 测试 XiamenLabs OpenAI Proxy

Write-Host "Testing XiamenLabs OpenAI Proxy" -ForegroundColor Green
Write-Host "================================`n" -ForegroundColor Green

$baseUrl = "http://localhost:8080"

# 测试 1: 列出模型
Write-Host "Test 1: GET /v1/models" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$baseUrl/v1/models" -Method Get
    Write-Host "✓ Models endpoint works!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
    Write-Host ""
} catch {
    Write-Host "✗ Models endpoint failed: $_" -ForegroundColor Red
}

# 测试 2: 非流式聊天补全
Write-Host "`nTest 2: POST /v1/chat/completions (non-streaming)" -ForegroundColor Cyan
$body = @{
    model = "x"
    messages = @(
        @{
            role = "system"
            content = "Be a helpful assistant"
        },
        @{
            role = "user"
            content = "你好，请简单介绍一下你自己"
        }
    )
    stream = $false
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/v1/chat/completions" -Method Post -Body $body -ContentType "application/json"
    Write-Host "✓ Non-streaming chat works!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10
    Write-Host ""
} catch {
    Write-Host "✗ Non-streaming chat failed: $_" -ForegroundColor Red
}

# 测试 3: 流式聊天补全（使用 curl）
Write-Host "`nTest 3: POST /v1/chat/completions (streaming)" -ForegroundColor Cyan
Write-Host "Note: This requires curl to be installed" -ForegroundColor Yellow

$streamBody = @{
    model = "x"
    messages = @(
        @{
            role = "system"
            content = "Be a helpful assistant"
        },
        @{
            role = "user"
            content = "数到5"
        }
    )
    stream = $true
} | ConvertTo-Json -Depth 10 -Compress

try {
    $curlCommand = "curl -X POST $baseUrl/v1/chat/completions -H 'Content-Type: application/json' -d '$($streamBody -replace "'", "''")' -N"
    Write-Host "Running: $curlCommand" -ForegroundColor Gray
    Invoke-Expression $curlCommand
    Write-Host "`n✓ Streaming chat works!" -ForegroundColor Green
} catch {
    Write-Host "✗ Streaming chat failed: $_" -ForegroundColor Red
}

Write-Host "`n================================" -ForegroundColor Green
Write-Host "Testing complete!" -ForegroundColor Green
