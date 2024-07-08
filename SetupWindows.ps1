mkdir C:\Scripts
$env:Path += ';C:\Scripts'

# Sign.ps1
@'
# https://qiita.com/Morichan/items/f8b4bcdcde8e188058c9
Param(
  [parameter(mandatory=$true)][String]$Description,
  [parameter(mandatory=$true)][String]$ScriptFile
)
$ScriptFilePath = Convert-Path $ScriptFile
if ( $ScriptFilePath -ne $null )
{
  $ScriptFileFullPath = Get-Command $ScriptFilePath | select $_.FullName
  $Cert = New-SelfSignedCertificate `
    -Subject "CN=$Description, OU=Self-signed RootCA" `
    -KeyAlgorithm RSA `
    -KeyLength 4096 `
    -Type CodeSigningCert `
    -CertStoreLocation Cert:\CurrentUser\My\ `
    -NotAfter ([datetime]"2099/01/01")
  Move-Item "Cert:\CurrentUser\My\$($Cert.Thumbprint)" Cert:\CurrentUser\Root
  $RootCert = @(Get-ChildItem cert:\CurrentUser\Root -CodeSigningCert)[0]
  Set-AuthenticodeSignature $ScriptFileFullPath.Source $RootCert
}
'@ | Out-File -FilePath C:\Scripts\Sign.ps1
$ScriptFileFullPath = Get-Command Sign.ps1 | select $_.FullName
$Cert = New-SelfSignedCertificate `
  -Subject "CN=PowerShell Script for authenticate-to-script.ps1, OU=Self-signed RootCA" `
  -KeyAlgorithm RSA `
  -KeyLength 4096 `
  -Type CodeSigningCert `
  -CertStoreLocation Cert:\CurrentUser\My\ `
  -NotAfter ([datetime]"2099/01/01")
Move-Item "Cert:\CurrentUser\My\$($Cert.Thumbprint)" Cert:\CurrentUser\Root
$RootCert = @(Get-ChildItem cert:\CurrentUser\Root -CodeSigningCert)[0]
Set-AuthenticodeSignature $ScriptFileFullPath.Source $RootCert

# nano-win
mkdir -Path nano-win,~\nano,~\nanorc
pushd nano-win
$targetHost = "https://files.lhmouse.com/nano-win/"
$content = (Invoke-WebRequest $targetHost).Content.Split([Environment]::NewLine) | Select-String 'nano-win' -List -SimpleMatch |  Select-Object -First 1
$targetUrl = $content.ToString() | ForEach-Object { $targetHost + $_.split('"')[3] }
Invoke-WebRequest $targetUrl -OutFile nano-win.7z
tar.exe -xf .\nano-win.7z -v
mv .\pkg_x86_64-w64-mingw32\bin\nano.exe ~\nano
mv .\pkg_x86_64-w64-mingw32\share\nano\*.nanorc ~\nanorc
@'
include "~/nanorc/*.nanorc"

set autoindent
set constantshow
set linenumbers
set tabsize 4

# Color
set titlecolor white,red
set numbercolor white,blue
set selectedcolor white,green
set statuscolor white,green
'@ | Out-File -FilePath ~\.nanorc
popd
rm -r nano-win

# set profile
Copy-Item -Path Microsoft.PowerShell_profile.ps1 -Destination $PROFILE -Force

# install powershell modules
Install-Module PSReadLine -Force -AllowClobber -SkipPublisherCheck
Install-Module PSColors -Force -AllowClobber -SkipPublisherCheck

# load winget packages
winget import -i winget-packages.json

# load profile
. $PROFILE
