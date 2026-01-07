# 快速测试脚本
Write-Host "Testing /v1/models endpoint..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/models" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
}

Write-Host "`n`nTesting /v1/chat/completions (non-stream)..." -ForegroundColor Cyan

$body = @{
    model = "x"
    messages = @(
        @{
            role = "system"
            content = "Be a helpful assistant"
        },
        @{
            role = "user"
            content = "你好"
        }
    )
    stream = $false
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/v1/chat/completions" -Method Post -Body $body -ContentType "application/json"
    Write-Host "✓ Success!" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 5
} catch {
    Write-Host "✗ Failed: $_" -ForegroundColor Red
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Red
}
