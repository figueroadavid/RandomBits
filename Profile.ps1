<# 
    this is for the main profile.. these bits create global values in every powershell session
    These pieces are all tied together, but my main profile has all of these functions in it
#>

function Get-SIDfromName
{
  [cmdletbinding()]
  param (
    [parameter(Mandatory = $true, ValueFromPipeLineByPropertyName = $true)]
    [Alias('Name', 'SAM', 'AccountName')]
    [string]$SAMAccountName
  )
  $obj = new-object -type System.Security.Principal.NTAccount($SAMAccountName)
  return $obj.Translate([System.Security.Principal.SecurityIdentifier]).value
}

function Get-NameFromSID
{
  [cmdletbinding()]
  param (
    [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [Alias('SID')]
    [string]$SecurityIdentifier
  )
  $obj = New-Object -TypeName System.Security.Principal.SecurityIdentifier($SecurityIdentifier)
  return $obj.Translate([system.Security.Principal.NTAccount]).Value
}

function Get-LDAPObjectFromSID{
  [cmdletbinding()]
  Param(
    [parameter(mandatory=$true)]
    [Alias('SID')]
    [string]$SecurityIdentifier
  )
  $adsi = new-object -type adsisearcher
  $adsi.filter = "(objectSID=$SecurityIdentifier)"
  return $adsi.FindOne()
}


if (Test-ComputerSecureChannel) #by doing the Test-ComputerSecureChannel, we're making sure that we are actually on the domain network; this is based around laptops
{
    $__Me = [system.security.principal.windowsidentity]::GetCurrent()
    $__MySID = $__Me.User.Value
    $__MyGroupsBySID = $__Me.Groups.Value
    $__MyGroupsByName = $__Me.Groups.Translate([System.Security.Principal.NTAccount]).value
    $__MyLDAPPath = (Get-LDAPObjectFromSID -SecurityIdentifier "$($__me.user.value)").path
}
