$hash = [hashtable]::Synchronized(@{})
$hash.value = 1
$hash.Flag = $True
$hash.Host = $host
Write-host ('Value of $Hash.value before background runspace is {0}' -f $hash.value) -ForegroundColor Green -BackgroundColor Black
$runspace = [runspacefactory]::CreateRunspace()
$runspace.Open()
$runspace.SessionStateProxy.SetVariable('Hash',$hash)
$powershell = [powershell]::Create()
$powershell.Runspace = $runspace
$powershell.AddScript({
    While ($hash.Flag) {
        $hash.value++
        $hash.Services = Get-Service
        $hash.host.ui.WriteVerboseLine($hash.value)
        Start-Sleep -Seconds 5
    }
}) | Out-Null
$handle = $powershell.BeginInvoke()