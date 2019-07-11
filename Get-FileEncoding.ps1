function Get-FileEncoding
{
  <#
      .SYNOPSIS
      Gets file encoding.
      .DESCRIPTION
      The Get-FileEncoding function determines encoding by looking at Byte Order Mark (BOM).
      Based on port of C# code from https://urldefense.proofpoint.com/v2/url?u=http-3A__www.west-2Dwind.com_Weblog_posts_197245.aspx&d=DwIGAg&c=xJd-VCU0OAsGbmHLtZyKKw&r=IJVPs0YTn1yJ80qH_VkKg2mTRfgu13KUHoc3LplZFCw&m=lzgshJ7bzTAC8C7_G0lgxEJPI4gDvVe5ANsXp27yzBI&s=yTpmXTiHNek9ga2QgCNJ5K-4so8WT70SXlxXDpYstFE&e=
      .EXAMPLE
      Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'}
      This command gets ps1 files in current directory where encoding is not ASCII
      .EXAMPLE
      Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'} | foreach {(get-content $_.FullName) | set-content $_.FullName -Encoding ASCII}
      Same as previous example but fixes encoding using set-content
  #>
    [CmdletBinding()] Param (
     [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)] [string]$Path
    )

    [byte[]]$byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path

    if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )
    { $Output = 'UTF8'; break }
    elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
    { $Output = 'Unicode'; break }
    elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
    { $Output = 'UTF32'; break }
    elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76)
    { $Output = 'UTF7'; break}
    else
    { $Output = 'ASCII'; break }
    $Output
}
