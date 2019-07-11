function Get-DisplayName
{
  [cmdletbinding()]
  Param(
    [parameter(mandatory=$true, ValueFromPipeline=$true)]
    [string[]]$UserName
  )

    $ADSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
    [void]$ADSearcher.PropertiesToLoad.Add('name')
    [void]$ADSearcher.PropertiesToLoad.Add('displayName')

    foreach ($User in $UserName)
    {
        $ADSearcher.Filter = "(&(anr=$User)(objectCategory=person))"
        $Names += $ADSearcher.FindAll()
        $Results = @()
        foreach ($name in $Names)
        {
            $Results += [PSCustomObject]@{'Name'=$Name.properties.name[0]; 'DisplayName' = $name.properties.displayname[0] }

        }
    }
    Write-Output $Results | Select-Object -Property Name,DisplayName
}
