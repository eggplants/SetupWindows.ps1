############
# add path #
#          #
$env:Path += ';C:\Scripts'
#          #
# end path #
############

###############
# add aliases #
#             #
function CustomListChildItems { 
    Get-ChildItem $args[0] -force |
    Sort-Object -Property @{ Expression = 'LastWriteTime'; Descending = $true }, 
                          @{ Expression = 'Name'; Ascending = $true } |
    Format-Table -AutoSize -Property Mode, Length, LastWriteTime, Name
}
Set-Alias -Name ll -Value CustomListChildItems

function CustomHosts {start notepad C:\Windows\System32\drivers\etc\hosts -verb runas}
Set-Alias -Name hosts -Value CustomHosts

function CustomUpdate {
    explorer ms-settings:windowsupdate
    winget upgrade --all --silent
}
sal update CustomUpdate
Set-Alias -Name ll -Value CustomUpdate

function CustomHome {cd \\wsl$\Ubuntu\home\eggplants}
Set-Alias -Name wslh -Value CustomHome

Set-PSReadLineKeyHandler -Key "alt+r" -BriefDescription "reloadPROFILE" -LongDescription "reloadPROFILE" -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('<#SKIPHISTORY#> . $PROFILE')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}

function LaunchNano {
    "Microsoft.PowerShell.Core\FileSystem::C:\Users\${env:USERNAME}\nano\nano.exe ${args}" | invoke-expression
}
Set-Alias -Name nano -Value LaunchNano
#             #
# end aliases #
###############

# zshlike complation
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# fishlike complation
Set-PSReadLineOption -PredictionSource History
Set-PSReadlineOption -Colors @{ InlinePrediction = 'DarkGreen' }

# PSColor
Import-Module PSColors
$global:PSColors = @{
    File = @{
        Default    = @{ Color = 'White' }
        Directory  = @{ Color = 'Cyan'}
        Hidden     = @{ Color = 'DarkGray'; Pattern = '^\.' } 
        Code       = @{ Color = 'Magenta'; Pattern = '\.(java|c|cpp|cs|js|css|html)$' }
        Executable = @{ Color = 'Red'; Pattern = '\.(exe|bat|cmd|py|pl|ps1|psm1|vbs|rb|reg)$' }
        Text       = @{ Color = 'Yellow'; Pattern = '\.(txt|cfg|conf|ini|csv|log|config|xml|yml|md|markdown)$' }
        Compressed = @{ Color = 'Green'; Pattern = '\.(zip|tar|gz|rar|jar|war)$' }
    }
    Service = @{
        Default = @{ Color = 'White' }
        Running = @{ Color = 'DarkGreen' }
        Stopped = @{ Color = 'DarkRed' }     
    }
    Match = @{
        Default    = @{ Color = 'White' }
        Path       = @{ Color = 'Cyan'}
        LineNumber = @{ Color = 'Yellow' }
        Line       = @{ Color = 'White' }
    }
	NoMatch = @{
        Default    = @{ Color = 'White' }
        Path       = @{ Color = 'Cyan'}
        LineNumber = @{ Color = 'Yellow' }
        Line       = @{ Color = 'White' }
    }
}

# Make prompt more funnier 
oh-my-posh init pwsh --config $env:POSH_THEMES_PATH/montys.omp.json | Invoke-Expression
