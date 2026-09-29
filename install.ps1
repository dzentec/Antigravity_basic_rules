<#
.SYNOPSIS
    Install Antigravity rules package into a target project (PowerShell).
.EXAMPLE
    .\install.ps1 -Target "D:\Projects\MyProject"
    .\install.ps1 -Target "D:\Projects\MyProject" -Mode Dry
    .\install.ps1 -Target "D:\Projects\MyProject" -Mode Copy
    .\install.ps1 -Target "D:\Projects\MyProject" -Mode Revert
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Target = ".",

    [Parameter(Position = 1)]
    [ValidateSet("Patch", "Dry", "Copy", "Revert")]
    [string]$Mode = "Patch"
)

$ErrorActionPreference = "Stop"
$scriptDir = $PSScriptRoot
$resolvedTarget = Resolve-Path $Target

Write-Host "Target Project: $resolvedTarget" -ForegroundColor Cyan
Write-Host "Mode:           $Mode`n" -ForegroundColor Cyan

switch ($Mode) {
    "Dry" {
        Write-Host "=== CHECKING PATCH APPLICABILITY ===" -ForegroundColor Yellow
        Push-Location $resolvedTarget
        try {
            git apply --check (Join-Path $scriptDir "diff\install.patch")
            Write-Host "✅ install.patch is cleanly applicable!" -ForegroundColor Green
        } finally {
            Pop-Location
        }
    }
    "Revert" {
        Write-Host "=== ROLLING BACK RULES ===" -ForegroundColor Yellow
        Push-Location $resolvedTarget
        try {
            $uninstallPatch = Join-Path $scriptDir "diff\uninstall.patch"
            if (Test-Path $uninstallPatch) {
                git apply $uninstallPatch
            } else {
                git apply -R (Join-Path $scriptDir "diff\install.patch")
            }
            Write-Host "✅ Rules package successfully rolled back!" -ForegroundColor Green
        } finally {
            Pop-Location
        }
    }
    "Copy" {
        Write-Host "=== DIRECT FILE COPY ===" -ForegroundColor Yellow
        $rulesDst = Join-Path $resolvedTarget ".agents\rules"
        $scriptsDst = Join-Path $resolvedTarget "scripts"
        
        New-Item -ItemType Directory -Force -Path $rulesDst, $scriptsDst | Out-Null
        Copy-Item (Join-Path $scriptDir "rules\*.md") $rulesDst -Force
        Copy-Item (Join-Path $scriptDir "hooks\hooks.json") (Join-Path $resolvedTarget ".agents\hooks.json") -Force -ErrorAction SilentlyContinue
        Copy-Item (Join-Path $scriptDir "hooks\graph-router.sh") $scriptsDst -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Files successfully copied to $resolvedTarget" -ForegroundColor Green
    }
    "Patch" {
        Write-Host "=== APPLYING INSTALL.PATCH ===" -ForegroundColor Yellow
        Push-Location $resolvedTarget
        try {
            git apply (Join-Path $scriptDir "diff\install.patch")
            Write-Host "✅ install.patch successfully applied to project!" -ForegroundColor Green
        } finally {
            Pop-Location
        }
    }
}
