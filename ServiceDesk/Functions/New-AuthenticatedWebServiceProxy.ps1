<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   New-AuthenticatedWebServiceProxy -credential $cred -URI 'C:\Users\$abaker9\documents\WindowsPowerShell\modules\ServiceDesk\files\blah.xml' -verbose
#>
Function New-AuthenticatedWebServiceProxy{
[cmdletbinding()]
param(
$URI,
[pscredential]$Credential,
[int]$Maxtries=1

)
    $proxy = $null
    for ($i = 1; $i -le $Maxtries; $i++) { 
      write-verbose -message "Connecting to $URI"
        $proxy = New-WebServiceProxy -URI $URI -Credential $Credential
        if ($proxy | Get-Member -Name AuthenticationInfoValue) {
            $authHeader = new-object (($proxy | get-member -name "AuthenticationInfoValue").definition).split(" ")[0]
            $authHeader.userName = $credential.GetNetworkCredential().UserName
            $authHeader.password = $credential.GetNetworkCredential().Password
            $proxy.AuthenticationInfoValue = $authHeader
        } else {
           write-error "Can't find AuthenticationInfoValue in WSDL" -ErrorAction stop 
        }

        if ($proxy -eq $null) {
            Write-Verbose -message "Failed creating WebService Object $i times. Hold and retrying after 10 seconds." 
            Start-Sleep -Seconds 10
        }   else {
             write-output $proxy
            break
        }
    }

    if ($proxy -eq $null) {write-error "Failed to create web service object. Retry count: $i" }
   
}