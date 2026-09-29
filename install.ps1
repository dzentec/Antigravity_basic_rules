<#
.SYNOPSIS
    Установка пакета правил Antigravity в целевой проект (PowerShell).
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

Write-Host "Целевой проект: $resolvedTarget" -ForegroundColor Cyan
Write-Host "Режим работы:   $Mode`n" -ForegroundColor Cyan

switch ($Mode) {
    "Dry" {
        Write-Host "=== ПРОВЕРКА ПРИМЕНИМОСТИ PATCH ===" -ForegroundColor Yellow
        Push-Location $resolvedTarget
        try {
            git apply --check (Join-Path $scriptDir "diff\install.patch")
            Write-Host "✅ install.patch успешно применим к проекту!" -ForegroundColor Green
        } finally {
            Pop-Location
        }
    }
    "Revert" {
        Write-Host "=== ОТКАТ ПРАВИЛ ===" -ForegroundColor Yellow
        Push-Location $resolvedTarget
        try {
            $uninstallPatch = Join-Path $scriptDir "diff\uninstall.patch"
            if (Test-Path $uninstallPatch) {
                git apply $uninstallPatch
            } else {
                git apply -R (Join-Path $scriptDir "diff\install.patch")
            }
            Write-Host "✅ Пакет правил успешно откачен!" -ForegroundColor Green
        } finally {
            Pop-Location
        }
    }
    "Copy" {
        Write-Host "=== ПРЯМОЕ КОПИРОВАНИЕ ФАЙЛОВ ===" -ForegroundColor Yellow
        $rulesDst = Join-Path $resolvedTarget ".agents\rules"
        $scriptsDst = Join-Path $resolvedTarget "scripts"
        
        New-Item -ItemType Directory -Force -Path $rulesDst, $scriptsDst | Out-Null
        Copy-Item (Join-Path $scriptDir "rules\*.md") $rulesDst -Force
        Copy-Item (Join-Path $scriptDir "hooks\hooks.json") (Join-Path $resolvedTarget ".agents\hooks.json") -Force -ErrorAction SilentlyContinue
        Copy-Item (Join-Path $scriptDir "hooks\graph-router.sh") $scriptsDst -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Файлы успешно скопированы в $resolvedTarget" -ForegroundColor Green
    }
    "Patch" {
        Write-Host "=== ПРИМЕНЕНИЕ INSTALL.PATCH ===" -ForegroundColor Yellow
        Push-Location $resolvedTarget
        try {
            git apply (Join-Path $scriptDir "diff\install.patch")
            Write-Host "✅ install.patch успешно применён в проекте!" -ForegroundColor Green
        } finally {
            Pop-Location
        }
    }
}
