function Test-AdministratorRole
{
  if (([security.principal.windowsprincipal][security.principal.windowsidentity]::GetCurrent()).IsInRole([security.principal.windowsbuiltinrole]"Administrator"))
  {
    return $True
  }
  else
  {
    return $false
  }
}
