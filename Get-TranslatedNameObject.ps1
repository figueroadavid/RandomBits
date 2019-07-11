function Get-TranslatedObjectName {

    <#
    .SYNOPSIS
        Retrieves various names of a presented object name
    .DESCRIPTION
        Creates a COM NameTranslate object, and based on the requested types, it will return the values that can be retrieved
    .PARAMETER ObjectName
        The name of the object to be retrieved.  There are 3 acceptable formats for the name:
        NT style    = domain\name
        UPN style   = name@dnsdomain.tld
        LDAP style  = 'CN=name,DC=domain,DC=tld'
        Multiple names can be supplied, and they do not have to be the same format
    .PARAMETER ReturnType
        This is the types of names that will be returned
        LDAP                - LDAP style, 'CN=name,DC=domain,DC=tld'
        NT                  - NT Style, domain\name
        DISPLAY_NAME        - The value stored in the DISPLAYNAME property of the object
        DOMAIN_SIMPLE       - UPN format name@domain.tld
        ENTERPRISE_SIMPLE   - UPN format name@domain.tld
        GUID                - The value stored in the GUID property of the object
        UPN                 - The value stored in the Universal Principal Name property of the object
        CANONICAL           - The object path in domain.tld/ou/ou/name format
        CANONICAL_EX        - The object path in domain.tld/ou/ou/name format

        If a name format selected is not available (does not exist, no permissions, etc.) for a particular object,
        the return value for that type is 'UNAVAILABLE'
        If the user does not have access to the object, the names will be returned as NOT_TRANSLATABLE

        The default return type is LDAP format
    .EXAMPLE
        PS C:\> Get-TranslatedObjectName -ObjectName domain1\user1,domain2\user2,user3@domain3.tld,domain4\computerobject$ -ReturnType DISPLAYNAME,upn,CANONICAL |ft -AutoSize
        Name                      DISPLAYNAME         upn                    CANONICAL
        ----                      -----------         ---                    ---------
        domain1\user1             Jefferson, Richard  user1@domain.tld       domain.tld/People/Users/user1
        domain2\user2             Todd Johnson        user2@domain2.tld      domain2.tld/admins/users/user2
        user3@domain3.tld         John Smith          user3@sub.domain3.tld  na.corp.mckesson.com/SuperUsers/stl8z0f
        domain4\computerobject$   ComputerObject$     UNAVAILABLE            domain4.tld/servers/location/COMPUTEROBJECT
    .INPUTS
        [system.string]
    .OUTPUTS
        [system.string]
    .NOTES
        Thanks to Chris Dent (https://www.indented.co.uk/) for inspiring this and showing me the basics of the NameTranslate object
    #>

    [cmdletbinding()]
    param(
        [parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage = 'The name of the object(s) to retrieve names for')]
        [string[]]$ObjectName,

        [parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('LDAP', 'NT', 'DISPLAY_NAME', 'DOMAIN_SIMPLE', 'ENTERPRISE_SIMPLE', 'GUID', 'UPN', 'CANONICAL', 'CANONICAL_EX')]
        [string[]]$ReturnType = 'LDAP'
    )


    $PSVersion = $PSVersionTable.PSVersion.Major
    if ($PSVersion -ge 5) {
        enum  ADS_NAME_INITTYPE {
            DOMAIN  = 1
            SERVER  = 2
            GC      = 3
        }

        enum ADS_NAME_TYPE {
            LDAP                = 1
            CANONICAL           = 2
            NT                  = 3
            DISPLAYNAME         = 4
            DOMAIN_SIMPLE       = 5
            ENTERPRISE_SIMPLE   = 6
            GUID                = 7
            UNKNOWN             = 8
            UPN                 = 9
            CANONICAL_EX        = 10
            SPN                 = 11
            SID_SIDHISTORY      = 12
        }
    }
    else {
        $ADS_NAME_INITTYPE = @'
        public enum ADS_NAME_INITTYPE
        {
            DOMAIN  = 1
            SERVER  = 2
            GC      = 3
        }
'@
        $ADS_NAME_TYPE = @'
        public enum ADS_NAME_TYPE
        {
            LDAP                = 1
            CANONICAL           = 2
            NT                  = 3
            DISPLAYNAME         = 4
            DOMAIN_SIMPLE       = 5
            ENTERPRISE_SIMPLE   = 6
            GUID                = 7
            UNKNOWN             = 8
            UPN                 = 9
            CANONICAL_EX        = 10
            SPN                 = 11
            SID_SIDHISTORY      = 12
        }
'@
        Add-Type -TypeDefinition $ADS_NAME_INITTYPE
        Add-Type -TypeDefinition $ADS_NAME_TYPE
    }

    $tab = "`t"

    $NameTranslate = New-Object -ComObject NameTranslate
    $NameTranslate.Init([ADS_NAME_INITTYPE]::GC, '')

    foreach ($Name in $ObjectName) {
        Write-Verbose -Message ('Name to process is {0}' -f $Name)
        if ($Name -match 'CN=') {
            $NameType = [ADS_NAME_TYPE]::LDAP
            Write-Verbose -Message ('{0}Name type is LDAP/1779' -f $tab)
        }
        elseif ($Name -match '.+\\.+') {
            $NameType = [ADS_NAME_TYPE]::NT
            Write-Verbose -Message ('{0}Name type is NT' -f $tab)
        }
        elseif ($Name -match '.+@.+') {
            $NameType = [ADS_NAME_TYPE]::UPN
            Write-Verbose -Message ('{0}Name type is Universal Principal Name (UPN)' -f $tab)
        }
        else {
            $NameType = 'DO_NOT_PROCESS'
            Write-Verbose -Message ('{0}Name is not a recognized type, no translation will be done')
        }

        if ($NameType -ne 'DO_NOT_PROCESS') {
            try {
                $NameTranslate.Set($NameType, $Name)
            }
            catch {
                Write-Verbose -Message ('Cannot access Name ({0})' -f $Name)
                $NameType = 'DO_NOT_PROCESS'
            }
        }

        $PropertyList = [ordered]@{
            Name = $Name
        }

        foreach ($Type in $ReturnType) {

            switch ($Type ) {
                'LDAP'              { $thisType = [ADS_NAME_TYPE]::LDAP; break }
                'NT'                { $thisType = [ADS_NAME_TYPE]::NT; break }
                'DISPLAY_NAME'      { $thisType = [ADS_NAME_TYPE]::DISPLAY_NAME; break }
                'DOMAIN_SIMPLE'     { $thisType = [ADS_NAME_TYPE]::ENTERPRISE_SIMPLE; break; }
                'ENTERPRISE_SIMPLE' { $thisType = [ADS_NAME_TYPE]::ENTERPRISE_SIMPLE; break }
                'GUID'              { $thisType = [ADS_NAME_TYPE]::GUID; break }
                'UPN'               { $thisType = [ADS_NAME_TYPE]::UPN; break }
                'CANONICAL'         { $thisType = [ADS_NAME_TYPE]::CANONICAL; break }
                'CANONICAL_EX'      { $thisType = [ADS_NAME_TYPE]::CANONICAL_EX }
            }
            try {
                if ($NameType -eq 'DO_NOT_PROCESS') {
                    $ReturnValue = 'NOT_TRANSLATABLE'
                    Write-Verbose -Message ('{0}Name ({1}) is not translatable to type {2}' -f $tab, $Name, $Type)
                }
                else {
                    $ReturnValue = $NameTranslate.Get($thisType)
                    Write-Verbose -Message ('{0}Translated Name of type {1} is {2}' -f $tab, $Type, $ReturnValue)
                }
            }
            catch {
                $ReturnValue = 'UNAVAILABLE'
                Write-Verbose -Message ('{0}Requested value of type {1} is not available' -f $tab, $Type)
            }
            $PropertyList.$Type = $ReturnValue
        }
        New-Object -TypeName pscustomobject -Property $PropertyList
    }
    $null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject($NameTranslate)
}
