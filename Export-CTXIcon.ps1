function Export-CTXIcon
{
  <#
      .SYNOPSIS
      This exports the icons from Citrix XenApp 6.x applications and exports them to a given directory.
      .DESCRIPTION
      The script reads in the icon bytes, and exports them to a file directly.
      It does not check for existing files, it simply overwrites them.
      .PARAMETER BrowserName
      The name of the application to export the icon from.  Multiple applications can be
      specified.
      .PARAMETER ComputerName
      The Citrix server acting as an XML server to communicate with.  If a server does not
      have the XML service installed (worker server) then it cannot be used for this function.
      .PARAMETER ExportPath
      The path to export the icon(s) to.  The names of the icons will be the browsername of
      of the application with .ico tacked onto it.  I.e. notepad.ico
      .EXAMPLE
      PS C:\> Export-CTXIcon -BrowserName Notepad -ComputerName zonedc1 -exportpath c:\Temp
      .EXAMPLE
      PS C:\> Get-xaapplication -folderpath 'Applications' |
        ForEach-Object { Export-CTXIcon -BrowserName $_.BrowserName $_.BrowserName -ExportPath c:\Temp
      .NOTES
      If the Citrix.XenApp.Commands snapin is not loaded the script will try to add it.
  #>
  [cmdletbinding()]
  param
  (
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [String[]]$BrowserName,
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateScript({Test-Connection -ComputerName $_})]
    [string]$ComputerName,
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateScript({Test-Path -Path $_})]
    [System.IO.DirectoryInfo]$ExportPath
  )
  Begin
  {
    Add-PSSnapin -Name Citrix.XenApp.Commands -ErrorAction SilentlyContinue
  }
  Process
  {
    $AppCount = $BrowserName.Count
    if ($AppCount -gt 3)
    {
      $WriteProgress = $true
      $CurrentCount = 0
      Write-Progress -Activity "Exporting icons 0 of $AppCount" -PercentComplete $([int](($CurrentCount/$AppCount) * 100))
    }
    foreach ($App in $BrowserName)
    {
      $CurrentCount += 1
      if ($WriteProgress)
      {
        Write-Progress -Activity "Exporting icons $CurrentCount of $AppCount" -PercentComplete $([int](($CurrentCount/$AppCount) * 100))
      }
      $IconData = (Get-XAApplicationIcon -BrowserName $BrowserName -ComputerName $ComputerName).EncodedIconData
      [System.IO.File]::WriteAllBytes("$ExportPath\$BrowserName.ico", [convert]::FromBase64String($IconData))
    }
  }
  End
  {
    IF ($WriteProgress)
    {
      Write-Progress -Activity "Exporting icons $CurrentCount of $AppCount" -PercentComplete $([int](($CurrentCount/$AppCount) * 100))
    }
  }
}
