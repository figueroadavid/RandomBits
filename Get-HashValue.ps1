function Get-HashValue
{
    <#
      .SYNOPSIS
      Computes the hash values (SHA-1, SHA-256, SHA-384, SHA-512, MD5, ALL) for a string or a file

      .DESCRIPTION
      Computes the specified hash values for a given string or file.  If the input string or file is larger than 2GB,
      it will be skipped.

      .PARAMETER HashType
      This is the list of hash types to compute (one or more can be selected at once):
      MD5
      SHA1
      SHA256
      SHA384
            SHA512
            ALL

      .PARAMETER String
      A simple text string; it must be less than 2GB in size

      .PARAMETER FileName
      The name of a file to use.  All of the bytes of the file are read in to compute the hash values; it must be less than 2GB in size

      .EXAMPLE
      PS C:\> Get-HashValue -String 'super simple'

      String       MD5
      ------       ---
      super simple 37db9c15c61d9595289ae9dc9efc2dfe

      .EXAMPLE
      PS C:\> Get-HashValue -String 'super simple' -HashTypes SHA1,SHA256,MD5

      SHA256                                                           MD5                              SHA1                                     String
      ------                                                           ---                              ----                                     ------
      3ea0100a11a0e118e2e8eabe2e5d723b6836151b39843347f84ea361a3757fa4 37db9c15c61d9595289ae9dc9efc2dfe eb617de338cb5cf625cb260710becc5591c86147 super simple

      .EXAMPLE
      PS C:\> Get-HashValue -String 'super simple'  -HashTypes SHA1,SHA256,MD5 | format-list


      SHA256 : 3ea0100a11a0e118e2e8eabe2e5d723b6836151b39843347f84ea361a3757fa4
      MD5    : 37db9c15c61d9595289ae9dc9efc2dfe
      SHA1   : eb617de338cb5cf625cb260710becc5591c86147
      String : super simple

      .EXAMPLE
      PS C:\WINDOWS\System32> Get-HashValue -FileName .\cipher.exe -HashTypes md5,sha1 | format-list


      MD5  : 8c97e8fd7c8f058b2ee626d3824212aa
      File : .\cipher.exe
      SHA1 : 8a618957e5df2f22a93b5f75f673c043619710dc

      .INPUTS
      system.text.string
      system.io.fileinfo

      .OUTPUTS
      System.Management.Automation.PSCustomObject
  #>

    [cmdletbinding(DefaultParameterSetName = 'ByString')]
    param
    (
        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'ByString')]
        [ValidateScript( { $_.length -lt 2GB })]
        [string]$String,

        [parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'ByFile')]
        [ValidateScript( {
                return ((Test-Path -Path $_) -and ($_.length -lt 2GB ))
            })]
        [Alias('FN')]
        [System.IO.FileInfo]$FileName,

        [parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('SHA1', 'SHA256', 'SHA384', 'SHA512', 'MD5', 'ALL')]
        [string[]]$HashTypes = 'MD5'
    )


    $Properties = @{}
    switch ($PSCmdlet.ParameterSetName)
    {
        'ByString'
        {
            $Encoder = [System.Text.Encoding]::UTF8
            $AllBytes = $Encoder.GetBytes($String)
            $Properties.Add('String', $String)
        }

        'ByFile'
        {
            $AllBytes = [System.IO.File]::ReadAllBytes($FileName)
            $Properties.Add('File', $FileName)
        }
    }

    foreach ($Hash in $HashTypes)
    {
        switch ($Hash)
        {
            'MD5'
            {
                $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                $MD5HashBytes = $MD5.ComputeHash($AllBytes)
                $MD5HASH = ($MD5HashBytes | ForEach-Object { "{0:x2}" -f $_ }) -join ''
                $Properties.Add('MD5', $MD5HASH)
            }

            'SHA1'
            {
                $SHA1	= New-Object -TypeName System.Security.Cryptography.SHA1Managed
                $SHA1HashBytes = $SHA1.ComputeHash($AllBytes)
                $SHA1HASH = ($SHA1HashBytes | ForEach-Object { "{0:x2}" -f $_ }) -join ''
                $Properties.Add('SHA1', $SHA1HASH)
            }

            'SHA256'
            {
                $SHA256 = New-Object -TypeName System.Security.Cryptography.SHA256Managed
                $SHA256HashBytes = $SHA256.ComputeHash($AllBytes)
                $SHA256HASH = ($SHA256HashBytes | ForEach-Object { "{0:x2}" -f $_ }) -join ''
                $Properties.Add('SHA256', $SHA256HASH)
            }

            'SHA384'
            {
                $SHA384 = New-Object -TypeName System.Security.Cryptography.SHA384Managed
                $SHA384HashBytes = $SHA384.ComputeHash($AllBytes)
                $SHA384HASH = ($SHA384HashBytes | ForEach-Object { "{0:x2}" -f $_ }) -join ''
                $Properties.Add('SHA384', $SHA384HASH)
            }
            'SHA512'
            {
                $SHA512 = New-Object -TypeName System.Security.Cryptography.SHA512Managed
                $SHA512HashBytes = $SHA512.ComputeHash($AllBytes)
                $SHA512HASH = ($SHA512HashBytes | ForEach-Object { "{0:x2}" -f $_ }) -join ''
                $Properties.Add('SHA512', $SHA512HASH)
            }
            'ALL'
            {
        $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $MD5HashBytes = $MD5.ComputeHash($AllBytes)
                $MD5HASH = ($MD5HashBytes | ForEach-Object { "{0:x2}" -f $_ }) -join ''
                $Properties.Add('MD5', $MD5HASH)

                $SHA1	= New-Object -TypeName System.Security.Cryptography.SHA1Managed
                $SHA1HashBytes = $SHA1.ComputeHash($AllBytes)
                $SHA1HASH = ($SHA1HashBytes | ForEach-Object { "{0:x2}" -f $_ }) -join ''
                $Properties.Add('SHA1', $SHA1HASH)

                $SHA256 = New-Object -TypeName System.Security.Cryptography.SHA256Managed
                $SHA256HashBytes = $SHA256.ComputeHash($AllBytes)
                $SHA256HASH = ($SHA256HashBytes | ForEach-Object { "{0:x2}" -f $_ }) -join ''
                $Properties.Add('SHA256', $SHA256HASH)

                $SHA384 = New-Object -TypeName System.Security.Cryptography.SHA384Managed
                $SHA384HashBytes = $SHA384.ComputeHash($AllBytes)
                $SHA384HASH = ($SHA384HashBytes | ForEach-Object { "{0:x2}" -f $_ }) -join ''
                $Properties.Add('SHA384', $SHA384HASH)

                $SHA512 = New-Object -TypeName System.Security.Cryptography.SHA512Managed
                $SHA512HashBytes = $SHA512.ComputeHash($AllBytes)
                $SHA512HASH = ($SHA512HashBytes | ForEach-Object { "{0:x2}" -f $_ }) -join ''
                $Properties.Add('SHA512', $SHA512HASH)
            }
        }
    }
    return (New-Object -TypeName PSCustomObject -Property $Properties)
}
