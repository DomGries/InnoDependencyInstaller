#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Url
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$temporaryFile = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString('N'))

try {
    Invoke-WebRequest -Uri $Url -OutFile $temporaryFile -UseBasicParsing -MaximumRedirection 10
    (Get-FileHash -LiteralPath $temporaryFile -Algorithm SHA256).Hash.ToLowerInvariant()
} finally {
    if (Test-Path -LiteralPath $temporaryFile) { Remove-Item -LiteralPath $temporaryFile -Force }
}
