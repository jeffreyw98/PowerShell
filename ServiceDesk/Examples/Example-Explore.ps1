
#Cannot find an overload for "HelpDesk_Submit_Service" and the argument count: "47".

$cred = get-credential
$URL = 'http://www.itsms.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_Create_WS'
$proxy = New-AuthenticatedWebServiceProxy -credential $cred -URI $URL -Maxtries 2

$proxy|Get-Member|Where-Object membertype -eq Method

Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Submit_Service
$a = $proxy.HelpDesk_Submit_Service
$a -split ", "

[enum]::getvalues(
[Microsoft.PowerShell.Commands.NewWebserviceProxy.AutogeneratedTypes.WebServiceProxy17PD_IncidentInterface_Create_WS.ImpactType]
)

