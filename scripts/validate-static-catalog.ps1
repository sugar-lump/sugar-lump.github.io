$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$catalogPath = Join-Path $root 'catalog.json'

function Read-JsonFile([string] $path) {
    try { return Get-Content -Raw -LiteralPath $path | ConvertFrom-Json }
    catch { throw "Invalid JSON in ${path}: $($_.Exception.Message)" }
}

$catalog = Read-JsonFile $catalogPath
if ($catalog.format -ne 'sugarlump.catalog' -or $catalog.format_version -ne '1.0') { throw 'catalog.json must use sugarlump.catalog format 1.0.' }
if ($catalog.catalog_type -ne 'static_snapshot') { throw 'catalog.json must declare static_snapshot.' }
if (@($catalog.items).Count -eq 0) { throw 'catalog.json must contain at least one item.' }

$ids = @{}
foreach ($item in $catalog.items) {
    if ([string]::IsNullOrWhiteSpace($item.id) -or $ids.ContainsKey($item.id)) { throw "Item IDs must be present and unique: $($item.id)" }
    $ids[$item.id] = $true
    if ($item.price.amount -ne 100 -or $item.price.currency -ne 'GBP' -or $item.price.display -ne '£1.00') { throw "Item $($item.id) must be priced at £1.00 GBP." }
    if ([string]::IsNullOrWhiteSpace($item.purchase_url) -or -not $item.purchase_url.StartsWith('https://buy.stripe.com/')) { throw "Item $($item.id) needs a Stripe purchase URL." }
    $prefix = 'https://sugar-lump.github.io/assets/'
    if (-not $item.metadata_url.StartsWith($prefix)) { throw "Item $($item.id) has an invalid metadata URL." }
    $metadataPath = Join-Path (Join-Path $root 'assets') ($item.metadata_url.Substring($prefix.Length).Replace('/', '\\'))
    if (-not (Test-Path -LiteralPath $metadataPath -PathType Leaf)) { throw "Metadata file not found for $($item.id): $metadataPath" }
    $metadata = Read-JsonFile $metadataPath
    if ($metadata.format -ne 'sugarlump.asset' -or $metadata.format_version -ne '1.0' -or $metadata.id -ne $item.id) { throw "Metadata record does not match item $($item.id)." }
    if ($metadata.title -ne $item.title -or $metadata.purchase_url -ne $item.purchase_url) { throw "Metadata title or purchase URL does not match item $($item.id)." }
    if ($metadata.price.amount -ne 100 -or $metadata.price.currency -ne 'GBP' -or $metadata.price.display -ne '£1.00') { throw "Metadata record for $($item.id) must be priced at £1.00 GBP." }
}

if (Test-Path -LiteralPath (Join-Path $root '.well-known/ucp')) { throw 'Static site must not advertise a UCP endpoint.' }
Write-Host "Validated $($catalog.items.Count) Sugarlump catalogue entries."
