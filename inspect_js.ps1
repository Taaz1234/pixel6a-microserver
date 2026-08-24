$js = (Invoke-WebRequest -Uri "https://adblock.turtlecute.org/js/index.js").Content
Write-Host "JS Length:" $js.Length

# Buscar funciones que prueben los dominios
$matches = [regex]::Matches($js, '.{0,100}(?:createElement|Image|fetch|XMLHttpRequest|script|onerror|onload).{0,100}')
foreach ($m in ($matches | Select-Object -First 10)) {
    Write-Host "MATCH: $($m.Value)"
}
