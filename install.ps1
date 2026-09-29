#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Automated installer script for m-vis (Memory Visualizer) CLI on Windows, macOS, and Linux.
.DESCRIPTION
    This PowerShell script downloads the latest release of m-vis CLI from GitHub,
    extracts/copies it, installs the `mvis` binary into a directory in your system's PATH
    (defaulting to `C:\Program Files\mvis` or user profile `~\.local\bin`),
    and adds it to your PATH if needed.
.EXAMPLE
    iex (iwr -useb https://raw.githubusercontent.com/SickleFire/m-vis/main/install.ps1)
#>

[CmdletBinding()]
param(
    [string]$InstallDir = ""
)

$ErrorActionPreference = "Stop"

function Write-Color {
    param([string]$Text, [ConsoleColor]$Color = [ConsoleColor]::White)
    $oldColor = [Console]::ForegroundColor
    [Console]::ForegroundColor = $Color
    [Console]::WriteLine($Text)
    [Console]::ForegroundColor = $oldColor
}

Write-Color "=== m-vis CLI Installer ===" ([ConsoleColor]::Cyan)

$Repo = "SickleFire/m-vis"
$BinaryName = "mvis.exe"

# Determine architecture
$arch = if ([Environment]::Is64BitOperatingSystem) { "x86_64" } else { "x86" }
if ($arch -ne "x86_64") {
    Write-Color "[ERROR] Unsupported architecture: $arch. 64-bit Windows is required." ([ConsoleColor]::Red)
    exit 1
}

$Target = "x86_64-pc-windows-msvc"
$AssetName = "mvis-windows-x86_64.exe"
$DownloadUrl = "https://github.com/$Repo/releases/latest/download/$AssetName"

# Default install directory
if ([string]::IsNullOrEmpty($InstallDir)) {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        $InstallDir = "C:\Program Files\mvis"
    } else {
        $InstallDir = "$HOME\.local\bin"
    }
}

Write-Color "Downloading m-vis binary..." ([ConsoleColor]::Blue)
$tmpDir = Join-Path $env:TEMP ("mvis-install-" + [Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $tmpDir | Out-Null

try {
    $exePath = Join-Path $tmpDir $BinaryName
    
    # Download with TLS 1.2+
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12, [Net.SecurityProtocolType]::Tls13
    
    try {
        $headers = @{ "User-Agent" = "m-vis-Installer" }
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $exePath -UseBasicParsing -Headers $headers
    } catch {
        Write-Color "[ERROR] Failed to download from $DownloadUrl" ([ConsoleColor]::Red)
        Write-Color $_.Exception.Message ([ConsoleColor]::Red)
        exit 1
    }

    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    Write-Color "Installing mvis to $InstallDir..." ([ConsoleColor]::Blue)
    
    $destExe = Join-Path $InstallDir $BinaryName
    Copy-Item -Path $exePath -Destination $destExe -Force

    # Add to User PATH if not already present
    $userPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)
    if ($userPath -notlike "*$InstallDir*") {
        Write-Color "Adding $InstallDir to user PATH..." ([ConsoleColor]::Yellow)
        $newPath = if ([string]::IsNullOrEmpty($userPath)) { $InstallDir } else { "$userPath;$InstallDir" }
        [Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::User)
        # Also update current session PATH
        $env:PATH = "$env:PATH;$InstallDir"
        Write-Color "[OK] Added to PATH." ([ConsoleColor]::Green)
    }

    Write-Color "`n=== Successfully installed m-vis CLI! ===" ([ConsoleColor]::Green)
    Write-Color "Installation Path: $destExe" ([ConsoleColor]::White)
    Write-Color "You can now run 'mvis --help' or 'mvis tui'." ([ConsoleColor]::Cyan)

} finally {
    if (Test-Path $tmpDir) {
        Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
