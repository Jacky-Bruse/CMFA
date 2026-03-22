param(
    [Parameter(Mandatory = $false)]
    [string]$InputPath
)

if ($InputPath) {
    $content = Get-Content -Path $InputPath -Raw
}
else {
    $content = [Console]::In.ReadToEnd()
}

$lines = ($content -replace "`r", "") -split "`n"
$items = New-Object System.Collections.Generic.List[string]
$seen = @{}
$inContributors = $false

foreach ($line in $lines) {
    if ($line -match '^##\s+Contributors') {
        $inContributors = $true
        continue
    }

    if ($line -match '^##\s+') {
        $inContributors = $false
    }

    if ($inContributors) {
        continue
    }

    if ($line -match '^[ \t]+[*-]\s+') {
        continue
    }

    if ($line -notmatch '^[*-]\s+(.+)$') {
        continue
    }

    $item = ($Matches[1] -replace '\s+', ' ').Trim()
    if (-not $item) {
        continue
    }

    if ($item -match '^(PR|Pull Request|Issue|Issues):' -or $item -match '^@') {
        continue
    }

    if ($seen.ContainsKey($item)) {
        continue
    }

    $seen[$item] = $true
    $items.Add("- $item")
}

if ($items.Count -eq 0) {
    Write-Output "- See GitHub release notes for details."
    exit 0
}

$limit = [Math]::Min($items.Count, 6)
for ($i = 0; $i -lt $limit; $i++) {
    Write-Output $items[$i]
}

if ($items.Count -gt 6) {
    Write-Output "..."
}
