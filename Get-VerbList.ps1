Function Get-VerbList
{
    [cmdletbinding()]
    param
    (
        [parameter(ValueFromPipeLineByPropertyName = $true)]
        [ValidateSet('Common','Data','Lifecycle','Diagnostic','Communications','Security','Other')]
        [string[]]$VerbType
    )

    if ($VerbType)
    {
        $VerbCollection = New-Object -TypeName System.Collections.ArrayList
        foreach ($Type in $VerbType)
        {
            $Verbs = Get-Verb | Where-Object { $_.Group -eq $Type } | Select-Object -ExpandProperty Verb
            if ($verbs.count -gt 1)
            {
                $null = $VerbCollection.AddRange($Verbs)
            }
            else
            {
                $null = $VerbCollection.Add($Verbs)
            }
        }
        $VerbCollection | Sort-Object
    }
    else
    {
        Get-Verb | Select-Object -ExpandProperty verb | Sort-Object
    }
}
