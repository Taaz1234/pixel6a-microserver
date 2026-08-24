$bytes = [System.Text.Encoding]::ASCII.GetBytes("admin:Paco3421")
$base64 = [System.Convert]::ToBase64String($bytes)
$headers = @{
    Authorization = "Basic $base64"
}

Write-Host "=== CAMBIANDO MODO DE BLOQUEO DE ADGUARD A NXDOMAIN ===" -ForegroundColor Cyan

# Obtener configuración actual
$dnsConfig = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/dns_info" -Headers $headers

# Modificar a NXDOMAIN
$body = @{
    upstream_dns = $dnsConfig.upstream_dns
    upstream_dns_file = $dnsConfig.upstream_dns_file
    bootstrap_dns = $dnsConfig.bootstrap_dns
    fallback_dns = $dnsConfig.fallback_dns
    all_servers = $dnsConfig.all_servers
    fastest_addr = $dnsConfig.fastest_addr
    blocking_mode = "nxdomain"
    ratelimit = $dnsConfig.ratelimit
    blocking_ipv4 = ""
    blocking_ipv6 = ""
    edns_client_subnet = $dnsConfig.edns_client_subnet
    cache_size = $dnsConfig.cache_size
    cache_ttl_min = $dnsConfig.cache_ttl_min
    cache_ttl_max = $dnsConfig.cache_ttl_max
    cache_optimistic = $dnsConfig.cache_optimistic
    upstream_mode = $dnsConfig.upstream_mode
    use_private_ptr_resolvers = $dnsConfig.use_private_ptr_resolvers
    resolve_clients = $dnsConfig.resolve_clients
    local_ptr_upstreams = $dnsConfig.local_ptr_upstreams
} | ConvertTo-Json -Depth 5

$res = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/dns_config" -Headers $headers -Method Post -Body $body -ContentType "application/json"
Write-Host "Resultado del cambio:" ($res | ConvertTo-Json -Compress)

# Comprobar
$updated = Invoke-RestMethod -Uri "http://192.168.1.135:3000/control/dns_info" -Headers $headers
Write-Host "Nuevo Modo de Bloqueo:" $updated.blocking_mode -ForegroundColor Green
