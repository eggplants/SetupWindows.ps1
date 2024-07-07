mkdir C:\Scripts
$env:Path += ';C:\Scripts'
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

Copy-Item -Path Microsoft.PowerShell_profile.ps1 -Destination $PROFILE -Force

Install-Module PSReadLine -Force -AllowClobber -SkipPublisherCheck
Install-Module PSColors -Force -AllowClobber -SkipPublisherCheck

winget import -i winget-packages.json

. $PROFILE
