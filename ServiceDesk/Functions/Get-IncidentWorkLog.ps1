<#
.Synopsis
   Gets worklog
.DESCRIPTION
   Gets worklog
.EXAMPLE
   Get-IncidentWorkLog -credential $cred -Incident_Number INC000016048372
#>
Function Get-IncidentWorkLog{
param(
$Incident_Number,
[pscredential]$credential,
[string]$URI  ="file://$modulepath\files\FORD_HPD_WorkInfo.wsdl"#'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/FORD_HPD_WorkInfo'
)

$proxy = New-AuthenticatedWebServiceProxy -credential $credential -URI $URI -Maxtries 2
$proxy.OpGet($Incident_Number)
#$proxy.OpGet(
#$proxy.OpGetlist
#Get-ProxyMethodFields -proxy $proxy -Method optget
#$filter = @"
#'Assignee'="Aeron L. Baker" AND 'Status'="Closed"
#"@
#$proxy.OpGet($Incident_Number)
#$proxy.OpGetlist($filter,0,10)
#$proxy.OpGetlist($Incident_Number,0,10)
}