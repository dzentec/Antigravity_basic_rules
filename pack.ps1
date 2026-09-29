<#
.SYNOPSIS
    Pack rules into a single Markdown bundle and extract it (PowerShell).
.EXAMPLE
    .\pack.ps1 pack
    .\pack.ps1 unpack "D:\Projects\TargetProject"
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0, Mandatory = $true)]
    [ValidateSet("pack", "unpack")]
    [string]$Action,

    [Parameter(Position = 1)]
    [string]$Target = "."
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot
$bundle = Join-Path $scriptDir "pack\rules-bundle.md"

if (Test-Path (Join-Path $scriptDir "rules")) {
    $rulesDir = Join-Path $scriptDir "rules"
} elseif (Test-Path (Join-Path $scriptDir "draft")) {
    $rulesDir = Join-Path $scriptDir "draft"
} else {
    $rulesDir = $scriptDir
}
$hooksDir = Join-Path $scriptDir "hooks"

if ($Action -eq "pack") {
    $packDir = Join-Path $scriptDir "pack"
    if (-not (Test-Path $packDir)) { New-Item -ItemType Directory -Path $packDir -Force | Out-Null }
    
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# Rules Bundle`n")
    
    # 1. Rules (.agents/rules/)
    $rules = Get-ChildItem -Path $rulesDir -Filter "0*.md" | Sort-Object Name
    foreach ($r in $rules) {
        [void]$sb.AppendLine("## .agents/rules/$($r.Name)")
        [void]$sb.AppendLine('````markdown')
        $content = Get-Content -Path $r.FullName -Raw -Encoding utf8
        [void]$sb.AppendLine($content.Trim())
        [void]$sb.AppendLine('````')
        [void]$sb.AppendLine("")
    }
    
    # 2. Hooks (.agents/hooks.json)
    $hJson = Join-Path $hooksDir "hooks.json"
    if (Test-Path $hJson) {
        [void]$sb.AppendLine("## .agents/hooks.json")
        [void]$sb.AppendLine('````json')
        [void]$sb.AppendLine((Get-Content -Path $hJson -Raw -Encoding utf8).Trim())
        [void]$sb.AppendLine('````')
        [void]$sb.AppendLine("")
    }
    
    # 3. Router script (scripts/graph-router.sh)
    $gRouter = Join-Path $hooksDir "graph-router.sh"
    if (Test-Path $gRouter) {
        [void]$sb.AppendLine("## scripts/graph-router.sh")
        [void]$sb.AppendLine('````bash')
        [void]$sb.AppendLine((Get-Content -Path $gRouter -Raw -Encoding utf8).Trim())
        [void]$sb.AppendLine('````')
        [void]$sb.AppendLine("")
    }
    
    [System.IO.File]::WriteAllText($bundle, $sb.ToString(), [System.Text.Encoding]::UTF8)
    $bytes = (Get-Item $bundle).Length
    Write-Host "✅ Built: $bundle ($bytes bytes)" -ForegroundColor Green
}
elseif ($Action -eq "unpack") {
    if (-not (Test-Path $bundle)) {
        Write-Host "❌ File $bundle not found. Run: .\pack.ps1 pack first" -ForegroundColor Red
        exit 1
    }
    
    $resolvedTarget = (Resolve-Path $Target -ErrorAction SilentlyContinue)
    if (-not $resolvedTarget) {
        New-Item -ItemType Directory -Path $Target -Force | Out-Null
        $resolvedTarget = (Resolve-Path $Target).Path
    } else {
        $resolvedTarget = $resolvedTarget.Path
    }
    
    $text = [System.IO.File]::ReadAllText($bundle, [System.Text.Encoding]::UTF8)
    
    $pattern = '(?ms)^##\s+((?:\.agents/|scripts/)[^\r\n]+)\r?\n(?:````|```)[a-z]*\r?\n(.*?)\r?\n(?:````|```)'
    $matches = [System.Text.RegularExpressions.Regex]::Matches($text, $pattern)
    
    $created = 0
    $skipped = 0
    
    foreach ($m in $matches) {
        $relPath = $m.Groups[1].Value.Trim()
        $fileContent = $m.Groups[2].Value.Trim() + "`n"
        $destPath = Join-Path $resolvedTarget $relPath
        
        if (Test-Path $destPath) {
            Write-Host "SKIP: $relPath" -ForegroundColor Yellow
            $skipped++
        } else {
            $destDir = Split-Path -Parent $destPath
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            [System.IO.File]::WriteAllText($destPath, $fileContent, [System.Text.Encoding]::UTF8)
            Write-Host "CREATE: $relPath" -ForegroundColor Green
            $created++
        }
    }
    
    Write-Host "`nCreated: $created" -ForegroundColor Cyan
    Write-Host "Skipped: $skipped" -ForegroundColor Cyan
}
