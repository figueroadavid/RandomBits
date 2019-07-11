Function Get-LAPSPassword
{
    <#
      .SYNOPSIS
        Retrieves the Microsoft LAPS password from the computer object in Active Directory
      .DESCRIPTION
        The script finds the computer in Active Directory, and it pulls the attribute that contains the LAPS password.
        No specific security checking is done.  If there are no permissions to the attribute, the script will fail.
        The script will accept a number of computer objects, but it only processes a single domain at a time.
      .EXAMPLE
        PS C:\> Get-LAPSPassword -ComputerName USODPWVXAX001, USODPWVXAX002, USODPWVXAX003,USODPWVXAX004 -Domain USON -Verbose
        name          LAPSPassword
            ----          ------------
            SERVERNAME01  NOTREALLY001
            SERVERNAME02  NOTREALLY002
            SERVERNAME03  NOTREALLY003
            SERVERNAME04  NOTREALLY004

      .EXAMPLE
        PS C:\> Get-LAPSPassword -ComputerName SERVERNAME01, SERVERNAME02, SERVERNAME03,SERVERNAME04 -DomainDN 'DC=domain,DC=tld' -Verbose
        name          LAPSPassword
            ----          ------------
            SERVERNAME01  NOTREALLY001
            SERVERNAME02  NOTREALLY002
            SERVERNAME03  NOTREALLY003
            SERVERNAME04  NOTREALLY004

      .PARAMETER ComputerName
        This is the list of computer objects in the domain to retrieve the LAPS passwords from

      .PARAMETER DomainDN
        This is the LDAP formatted distinguishedName of the domain.  By default, it is configured for the existing uson.usoncology.int domain by default.

      .PARAMETER Domain
        This is the 'name' of a domain to process.  The script has a built in lookup table for USON and NAMCK that retrieves the DomainDN for those domains.
        The script can be modified to add domains, remove them, etc.

      .INPUTS
        [system.string]
      .OUTPUTS
        [pscustomobject]
      .NOTES
        This script should be Powershell 2.0 compatible, and is based on ADSI calls to the domain.

    #>
    [cmdletbinding(DefaultParameterSetName = 'byDN')]
    param(
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]$ComputerName,

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'byDN')]
        [string]$DomainDN = 'DC=domain,DC=tld',

        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'byLookup')]
        [ValidateSet('domain1','domain2')]
        [string]$Domain = 'domain'
    )

    switch ($PSCmdlet.ParameterSetName)
    {
        'byDN' { $LDAPPath = 'LDAP://{0}' -f $DomainDN; break }
        'byLookup'
        {
            switch ($Domain)
            {
                'domain1'  { $DN = 'DC=domain,DC=tld'; break }
                'domain2'  { $DN = 'DC=domain2,DC=tld'; break}
            }
            $LDAPPath = 'LDAP://{0}' -f $DN
        }
    }

    $DirectorySearcher = [System.DirectoryServices.DirectorySearcher]::new()
    $DirectorySearcher.SearchRoot = [System.DirectoryServices.DirectoryEntry]$LDAPPath

    foreach ($Computer in $ComputerName)
    {
        $DirectorySearcher.Filter = ('(&(objectClass=computer)(name={0}))' -f $Computer)
        $thisComputer = $DirectorySearcher.FindOne()
        [pscustomobject]@{
            name = $Computer
            LAPSPassword = $( ($thisComputer.Properties).item('ms-mcs-admpwd') )
        }
    }
    $DirectorySearcher.Dispose()
}
