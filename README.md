# My Windows Environment

A setup script for Windows

## Run

```ps1
Set-AuthenticodeSignature $ScriptFileFullPath.Source $RootCert
Invoke-WebRequest "https://raw.githubusercontent.com/eggplants/setup-windows.ps1/master/setup-windows.ps1" -OutFile setup-windows.ps1
setup-windows.ps1
```
