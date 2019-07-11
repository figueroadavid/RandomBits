{
    <#
        .SYNOPSIS
        Test if a remote TCP port is open or closed

        .DESCRIPTION
        Uses .Net to attempt open a TCP connection to the specified port and return the result if it open ($true) or closed ($false)

        .PARAMETER ComputerName
        The resolvable name or IP address of the computer to test.  The script has only been tested with IP v4.

        .PARAMETER Port
        The numeric port to test between 0 and 65535

        .PARAMETER TimeOutInMS
        The number of milliseconds to wait for the connection to timeout.
        The default is 3000 (3 seconds)

        .PARAMETER Quiet
        Only return the status, do not return the name and port number

        .EXAMPLE
        PS C:\> Test-TCPPort -ComputerName CitrixServer1 -Port 1494
        Name          Port Status
        ----          ---- ------
        CitrixServer1 1494   True

        .EXAMPLE
        PS C:\> Test-TCPPort -ComputerName CitrixServer2 -Port 1494 -Quiet
        True

        .NOTES
        This was an adaptation written based on several articles, and .net documentation
        It was meant as a simplified replacement for Test-NetConnection, since that commmand does not have a timeout parameter.

        .INPUTS
        [system.string]
        [int]

        .OUTPUTS
        [pscustomobject]
        [bool]
    #>

    [cmdletbinding()]
    Param (
        [parameter(Mandatory = $true,HelpMessage='The resolvable name or IP Address of the system to test', ValueFromPipelineByPropertyName = $true)]
        [ValidateScript(
            {
                try
                {
                    $null = [System.Net.Dns]::Resolve($_)
                    Write-Verbose -Message ('Successfully resolved {0}' -f $_)
                    return $true
                }
                catch
                {
                    throw ( 'Hostname: ({0}) is unresolvable' -f $_ )
                }
            }
        )]
        [string]$ComputerName,

        [parameter(Mandatory = $true,HelpMessage='The TCP port to test', ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0,65535)]
        [int]$Port,

        [parameter(ValueFromPipelineByPropertyName = $true)]
        [int]$TimeOutInMS = 3000,

        [parameter(Valuefrompipelinebypropertyname = $true)]
        [switch]$Quiet
    )

    $tcp = [System.Net.Sockets.TcpClient]::new()
    $iAsyncResult = $tcp.BeginConnect($ComputerName, $Port, $Null, $null)
    $Null = $iAsyncResult.AsyncWaitHandle.WaitOne($TimeOutInMs)

    try
    {
        $tcp.EndConnect($iAsyncResult)
        $Status = $true
    }
    catch
    {
        $Status = $false
    }

    $tcp.Close()
    $tcp.Dispose()

    if ($Quiet)
    {
        $Status
    }
    else
    {
        [pscustomobject][ordered]@{
            Name = $ComputerName
            Port = $Port
            Status = $Status
        }
    }
}
