$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

$log = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/querylog?limit=20" -Headers $headers
Write-Host "=== ÚLTIMAS PETICIONES DNS EN ADGUARD ===" -ForegroundColor Cyan
foreach ($item in $log.data) {
    Write-Host "$($item.client) -> $($item.question.name) [$($item.reason)] (IP: $($item.answer.value))"
}
