<#
.Synopsis
   Creates a new WorkLogItem
.DESCRIPTION
   Creates a new WorkLogItem
.EXAMPLE
    New-IncidentWorklog -credential $cred -Incident_Number INC000016048372 -Work_Info_Notes 'new note' -whatif
.EXAMPLE
    New-IncidentWorklog -credential $cred -Incident_Number INC000016048372 -Work_Info_Notes 'sent customer email' -Work_Info_Type CustomerCommunication
.EXAMPLE
   "INC000016048372", "INC000016048373" |New-IncidentWorklog -credential $cred -Work_Info_Notes 'new note' -whatif

#>
Function New-IncidentWorklog{
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param(
[Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromPipeline=$true,
            Position=0)]
[string[]]$Incident_Number,
[Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            Position=1)]
$Work_Info_Notes,
$Work_Info_Summary="Added note",
[validateset('ActionPlanDate', 'ClosureFollowUp', 'CustomerCommunication', 'CustomerFollowup', 'CustomerInbound', 'CustomerOutbound', 'CustomerStatusUpdate', 'DetailClarification', 'EmailSystem', 'General', 'GeneralInformation', 'IncidentTaskAction', 'ModuleName', 'PagingSystem', 'ProblemScript', 'ResolutionCommunications', 'RootCauseDate', 'SatisfactionSurvey', 'StatusUpdate', 'VendorComments', 'VendorMetrics', 'WorkingLog')]
$Work_Info_Type="GeneralInformation",
[validateset('Email','Fax','Phone','VoiceMail','WalkIn','Pager','SystemAssignment','Web','Other','QuickTick')]
$Work_Info_Source='SystemAssignment',
[Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true)]
[pscredential]$Credential,
$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/Ford_Worklog_update'
)
begin{
    #Ford_Worklog_update 

    #HPD_update
    $proxy = New-AuthenticatedWebServiceProxy -credential $Credential -URI $URI -Maxtries 2

    $worklog = Get-ProxyMethodFields -proxy $proxy -Method OpSet
}
process{
    foreach ($item in $Incident_Number){
        $worklog.Incident_Number = $item
        $worklog.Work_Info_Type=$Work_Info_Type
        $worklog.Work_Info_Date="$(get-date -f u)"
        $worklog.Work_Info_Source=$Work_Info_Source
        $worklog.Work_Info_Locked="No"
        $worklog.Work_Info_View_Access="Public"
        $worklog.Work_Info_Summary=$Work_Info_Summary
        $worklog.Work_Info_Notes=$Work_Info_Notes

        if ($pscmdlet.ShouldProcess("$item", "Added Worklog")){
            $proxy.OpSet(
            $worklog.Incident_Number,       
            $worklog.Work_Info_Summary,     
            $worklog.Work_Info_Notes,       
            $worklog.Work_Info_Type,        
            $worklog.Work_Info_Date,        
            $worklog.Work_Info_Source,      
            $worklog.Work_Info_Locked,      
            $worklog.Work_Info_View_Access 
            )
           
        }  
        write-output $worklog  
    }
}
end{}





}
