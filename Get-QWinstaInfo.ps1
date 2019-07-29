function Get-QWinstaInfo {
    <#
    .SYNOPSIS
        Retrieves the qwinsta.exe output and provides is as objects
    .DESCRIPTION
        Parses the output of qwinsta.exe and converts it to PSObjects (PS2) or PSCustomObjects (PS3+)
    .PARAMETER ComputerName
        The name(s) of the computer(s) to retrieve information from
    .EXAMPLE
        #
        PS C:\> Get-QWinstaInfo -ComputerName Server1,Server99 | Select-Object -Property ComputerName,IsInteractive,SessionName,UserName,ID,State,Type,Device | ft

        ComputerName            IsInteractive SessionName    UserName           ID                 State              Type               Device
        ------------            ------------- -----------    --------           --                 -----              ----               ------
        Server1                     False services                              0                  Disc
        Server1                     False console                               1                  Conn
        Server1                     False ica-tcp#1          user1              5                  Active             wdica
        Server1                     False                    user2              6                  Disc
        Server1                     False ica-tcp#2          user3              7                  Active             wdica
        Server1                     False ica-tcp#4          user4              8                  Active             wdica
        Server1                     False ica-tcp#0          user5              9                  Active             wdica
        Server1                     False ica-tcp#5          user6              10                 Active             wdica
        Server1                     False                    user7              11                 Disc
        Server1                     False ica-tcp                               65536              Listen
        Server1                     False rdp-tcp                               65537              Listen
        Server99            NOT_AVAILABLE NOT_AVAILABLE      NOT_AVAILABLE      NOT_AVAILABLE      NOT_AVAILABLE      NOT_AVAILABLE      NOT_AVAILABLE

        This is an example of output from an existing server (Server1) and a non-existent server (Server99)
    .INPUTS
        [system.string]
    .OUTPUTS
        [PSObject] (Powershell 2) or [PSCustomObject] (Powershell 3+)
    .NOTES
        Parses the output of qwinsta /server:<servername> unless it is the local machine, where it uses qwinsta (no switches).
        This is done to allow it to pick up if the current session is the interactive session.
    #>

    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName = $true, HelpMessage = 'The name(s) of the server(s) to query for Winstation information')]
        [string[]]$ComputerName = $env:COMPUTERNAME
    )

    $pattern = '^(?<Interactive>[ >])(?<SessionName>\S*)\s+(?<UserName>\S*)\s+(?<ID>\d+)\s+(?<State>\S*)\s*(?:(?<Type>\S*)\s+(?<Device>\S*))?'
    $PSVersion = $PSVersionTable.PSVersion.Major

    foreach ($Computer in $ComputerName) {
        if ($Computer -eq $env:COMPUTERNAME) {
            $Result = qwinsta.exe 2>$null
        }
        else {
            $Result = qwinsta.exe /server:$Computer 2>$null
        }

        if ($?) {
            $Result | Where-Object { $_ -match $pattern } |
            ForEach-Object {
                $Properties = @{
                    ComputerName  = $Computer
                    IsInteractive = $matches.Interactive -as [bool]
                    SessionName   = $matches.SessionName
                    UserName      = $matches.UserName
                    ID            = $matches.ID
                    State         = $matches.State
                    Type          = $matches.Type
                    Device        = $matches.Device
                }
                if ($PSVersion -eq 2) {
                    New-Object -TypeName PSObject -Property $Properties
                }
                else {
                    [PSCustomObject]$Properties
                }
            }
        }
        else {
            $Properties = @{
                ComputerName  = $Computer
                IsInteractive = 'NOT_AVAILABLE'
                SessionName   = 'NOT_AVAILABLE'
                UserName      = 'NOT_AVAILABLE'
                ID            = 'NOT_AVAILABLE'
                State         = 'NOT_AVAILABLE'
                Type          = 'NOT_AVAILABLE'
                Device        = 'NOT_AVAILABLE'
            }

            if ($PSVersion -eq 2) {
                New-Object -TypeName PSObject -Property $Properties
            }
            else {
                [pscustomobject]$Properties
            }
        }
    }
}
