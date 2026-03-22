$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$scriptPath = Join-Path $repoRoot ".github\scripts\telegram-changelog-summary.ps1"

$sampleChangelog = @"
## What's Changed
* Update Dependencies
* Update Dependencies
* Update CA bundle
* Update Dependencies
* Fix release caption
"@

$tempInput = [System.IO.Path]::GetTempFileName()
try {
    Set-Content -Path $tempInput -Value $sampleChangelog -NoNewline
    $output = & powershell -ExecutionPolicy Bypass -File $scriptPath -InputPath $tempInput 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "summary generator failed: $($output -join "`n")"
    }
}
finally {
    Remove-Item -Path $tempInput -ErrorAction SilentlyContinue
}

$actual = ($output -join "`n").Trim()
$expected = @"
- Update Dependencies
- Update CA bundle
- Fix release caption
"@.Trim()

if ($actual -ne $expected) {
    throw "unexpected summary output.`nExpected:`n$expected`n`nActual:`n$actual"
}

Write-Output "PASS"
