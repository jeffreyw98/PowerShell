<#
.Synopsis
   Assigns a ticket to another group/person
.DESCRIPTION
   Assigns a ticket to another group/person
.EXAMPLE
   Set-IncidentAssignment -credential $cred -Incident_Number INC000016131210 -Assignee "Aeron L. Baker" -verbose -whatif
.EXAMPLE
   Set-IncidentAssignment -credential $cred -Incident_Number 'INC000016048372' -Assignee "William J. Coyle" -whatif
.EXAMPLE
 'INC000016048372','INC000016048372'| Set-IncidentAssignment -credential $cred  -Assignee "William J. Coyle" -whatif
#>
Function Set-IncidentAssignment{
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param(
[Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromPipeline=$true,
            Position=0)]
[string[]]$Incident_Number,
[Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_update',
[Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
$Assigned_Group_ID = 'SGP000000000075',
[Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
$Assigned_Group = 'The Americas Windows Server Operations',
[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
$Assignee,
[Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
$Assigned_Support_Company = 'Ford Motor Company',
[Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
$Assigned_Support_Organization = 'Global Service Desk',
[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
[pscredential]$credential,
[Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
[ValidateSet("L1 - Lack of adequate Knowledge Article", "L1 - Article Instructs to escalate to L2", "GeneralInformation")]
$Work_Info_Type = "GeneralInformation"
)
begin{
    #HPD_update

    $proxy = New-AuthenticatedWebServiceProxy -credential $credential -URI $URI -Maxtries 2
}
process{
    foreach ($item in $Incident_Number){
        $Incident = Get-ProxyMethodFields -proxy $proxy -Method OpSet

        $Incident.Incident_Number = $item
        $Incident.Work_Info_Type=$Work_Info_Type
        $Incident.Work_Info_Date="$(get-date -f u)"
        $Incident.Work_Info_Source="Web"
        $Incident.Work_Info_Locked="No"
        $Incident.Work_Info_View_Access="Public"
        #$Incident.Work_Info_Summary="sum1"
        #$Incident.Work_Info_Notes="notes1"
        $Incident.Assigned_Group=$Assigned_Group
        $Incident.Assignee = $Assignee
        $Incident.Assigned_Support_Company = $Assigned_Support_Company
        $Incident.Assigned_Support_Organization=$Assigned_Support_Organization
        $Incident.Assigned_Group_ID = $Assigned_Group_ID
        # abaker9 ID PPL000000440164

        if ($pscmdlet.ShouldProcess("$item", "Assigment Change")){
            write-verbose "Changing Assignement for $item"
            $proxy.OpSet(
                $Incident.Assigned_Group,                
                $Incident.Assigned_Support_Company,      
                $Incident.Assigned_Support_Organization, 
                $Incident.Assignee,                      
                $Incident.Incident_Number,               
                $Incident.Assigned_Group_ID,             
                $Incident.Work_Info_Summary,             
                $Incident.Work_Info_Notes,               
                $Incident.Work_Info_Type,                
                $Incident.Work_Info_Date,                
                $Incident.Work_Info_Source,              
                $Incident.Work_Info_Locked,              
                $Incident.Work_Info_View_Access,         
                $Incident.Assignee_Login_ID             
            )

        } else {
            write-output $Incident
        }



    }




}
end{}

}
