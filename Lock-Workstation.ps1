Function Lock-WorkStation
{
   $signature = '[DllImport("user32.dll",SetLastError=true)]
   public static extern bool LockWorkStation();'
   $t = Add-Type  -memberDefinition $signature -name api -namespace stuff -passthru
   $null = $t::LockWorkStation()
}
