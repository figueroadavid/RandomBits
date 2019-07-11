function Get-TypeAcceleratorList
{
  ([PSObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')::get).Keys | sort-object | foreach-object { "[$_]" }
}

