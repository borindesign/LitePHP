[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$appRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$launcher = Join-Path $appRoot 'LitePHP.bat'
$icon = Join-Path $appRoot 'assets\LitePHP.ico'
foreach ($path in @($launcher, $icon)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "File non trovato: $path" }
}

$shortcutPath = Join-Path $appRoot 'LitePHP.lnk'
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
try {
    $shortcut.TargetPath = $launcher
    $shortcut.WorkingDirectory = $appRoot
    $shortcut.IconLocation = "$icon,0"
    $shortcut.Description = 'LitePHP - PHP and MySQL portable development launcher'
    $shortcut.WindowStyle = 1
    $shortcut.Save()
} finally {
    [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($shortcut)
    [void][Runtime.InteropServices.Marshal]::FinalReleaseComObject($shell)
}
Write-Output "Collegamento creato: $shortcutPath"
