<#
.Synopsis
   Updates BMC Incident with SOAP
.DESCRIPTION
   Updates BMC Incident with SOAP
.EXAMPLE
    Set-Incident -credential $cred -Incident_Number INC000016048372 -whatif
.EXAMPLE
    Set-Incident -credential $cred -Incident_Number INC000016048372
.EXAMPLE
    'INC000016048372','INC000016048372'| Set-Incident -credential $cred -Status Resolved -Resolution 'Rebooted server' -Resolution_Category Application_Software_Defect -WhatIf|select Incident_number'INC000016048372','INC000016048372'| Set-Incident -credential $cred -whatif
.EXAMPLE
    'INC000016048372','INC000016048372'| Set-Incident -credential $cred -Status Resolved -Resolution 'Rebooted server' -Resolution_Category Application_Software_Defect -WhatIf|select Incident_number
#>
Function Set-Incident{
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
param(
[Parameter(Mandatory=$true,
            ValueFromPipelineByPropertyName=$true,
            ValueFromPipeline=$true,
            Position=0)]
[string[]]$Incident_Number,
[Parameter(Mandatory=$false)]
[string]$Resolution,
[Parameter(Mandatory=$false)]
[ValidateSet('Application_Software_Defect','Business_Usage','Change_Failure','Configuration_Attribute_Error','End_of_life','External_Cause_-_non_Ford','Hardware_Failure','Implementation_error','Insufficient_Capacity','Middleware/Infrastructure_SW_Defect','External_Cause_-_non_Ford','Operational_Error','Requirements/Design_Error')]
[string]$Resolution_Category,
[Parameter(Mandatory=$true)]
[PSCredential]$Credential,
[string]$URI  ="file://$modulepath\files\HPD_IncidentInterface_WS.wsdl" ,#'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_WS'
[Parameter(Mandatory=$false)]    
[ValidateSet('Assigned','InProgress','Pending','Resolved','Closed','Cancelled')]   
[System.String]$Status,
[ValidateSet('ExtensiveWidespread','SignificantLarge','ModerateLimited','MinorLocalized')]
[System.String]$Impact='ModerateLimited',
[ValidateSet('Critical','High','Medium','Low')]
[String]$Urgency = 'Low',
[String]$Categorization_Tier_1,
[String]$Categorization_Tier_2,
[String]$Categorization_Tier_3,
[String]$Product_Categorization_Tier_1,
[String]$Product_Categorization_Tier_2,
[String]$Product_Categorization_Tier_3
)

begin{
    
    $proxy = New-AuthenticatedWebServiceProxy -credential $credential -URI $URI -Maxtries 2

    # [enum]::getvalues([ITSM.UrgencyType])
    $UrgencyType = New-Object PSObject
    $UrgencyType | Add-Member Noteproperty Critical -Value 0
    $UrgencyType | Add-Member Noteproperty High -Value 1
    $UrgencyType | Add-Member Noteproperty Medium -Value 2
    $UrgencyType | Add-Member Noteproperty Low -Value 3

    # [enum]::getvalues([ITSM.ImpactType])
    $ImpactType = New-Object PSObject
    $ImpactType | Add-Member Noteproperty ExtensiveWidespread -Value 0
    $ImpactType | Add-Member Noteproperty SignificantLarge -Value 1
    $ImpactType | Add-Member Noteproperty ModerateLimited -Value 2
    $ImpactType | Add-Member Noteproperty MinorLocalized -Value 3

    # [enum]::getvalues([ITSM.StatusType]) 
    $StatusType = New-Object PSObject
    $StatusType | Add-Member Noteproperty New -Value 0
    $StatusType | Add-Member Noteproperty Assigned -Value 1
    $StatusType | Add-Member Noteproperty InProgress -Value 2
    $StatusType | Add-Member Noteproperty Pending -Value 3
    $StatusType | Add-Member Noteproperty Resolved -Value 4
    $StatusType | Add-Member Noteproperty Closed -Value 5
    $StatusType | Add-Member Noteproperty Cancelled -Value 6

    $IncidentTemplate = Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Modify_Service
}
process{
    foreach ($item in $Incident_Number){
        
        $Incident = $IncidentTemplate

        $oldData = get-incident $item -Credential $credential -URI $uri
        $Incident| get-member | where MemberType -eq "NoteProperty"| select name | %{
            $name = $_.name
            $Incident."$name" = $oldData."$name"
        }

        $Incident.Reported_Source = $oldData.Reported_Source  -replace " ",""
        $Incident.Urgency = $oldData.Priority


        #these have to be reset manually
        $Incident.Work_Info_Source = "Other"
        $Incident.Work_Info_Locked = "No"
        $Incident.Work_Info_View_Access = "Public"
        $Incident.action = "MODIFY" #setting will always be MODIFY when changing a ticket
        $Incident.Status_Reason = "PendingOriginalIncident"#its focing me to specify something.. WHY?


        if ($PSBoundParameters.ContainsKey("Urgency")){
           $Incident.Urgency=$UrgencyType."$Urgency" 
        }

        if ($PSBoundParameters.ContainsKey("Resolution")){
            $Incident.Resolution = $Resolution 
        }


        if ($PSBoundParameters.ContainsKey("Resolution_Category")){
            $Incident.Resolution_Category = $Resolution_Category -replace "_", " "
        }


        if ($PSBoundParameters.ContainsKey("Impact")){
            $Incident.Impact=$ImpactType."$Impact"
        }

        if ($PSBoundParameters.ContainsKey("Status")){
            $Incident.Status=$StatusType."$Status"
            if ($Incident.Status -gt 3){
                #if the ticket is resolved, closed or cancelled no further action is required.
                $Incident.Status_Reason = "NoFurtherActionRequired"
            } 
        }

        if ($PSBoundParameters.ContainsKey("Summary")){
            $Incident.Summary=$Summary
        }
        if ($PSBoundParameters.ContainsKey("Notes")){
            $Incident.Notes=$Notes
        }
        
        if ($PSBoundParameters.ContainsKey("Categorization_Tier_1")){
            $Incident.Categorization_Tier_1 = $Categorization_Tier_1
        }
        if ($PSBoundParameters.ContainsKey("Categorization_Tier_2")){
            $Incident.Categorization_Tier_1 = $Categorization_Tier_2
        }
        if ($PSBoundParameters.ContainsKey("Categorization_Tier_3")){
            $Incident.Categorization_Tier_1 = $Categorization_Tier_3
        }

        if ($PSBoundParameters.ContainsKey("Product_Categorization_Tier_1")){
            $Incident.Product_Categorization_Tier_1 = $Product_Categorization_Tier_1
        }
        if ($PSBoundParameters.ContainsKey("Product_Categorization_Tier_2")){
            $Incident.Product_Categorization_Tier_1 = $Product_Categorization_Tier_2
        }
        if ($PSBoundParameters.ContainsKey("Product_Categorization_Tier_3")){
            $Incident.Product_Categorization_Tier_1 = $Product_Categorization_Tier_3
        }


        if ($pscmdlet.ShouldProcess("$item", "Updating")){
            $proxy.HelpDesk_Modify_Service(
                $Incident.Categorization_Tier_1,
                $Incident.Categorization_Tier_2,
                $Incident.Categorization_Tier_3,
                $Incident.Closure_Manufacturer,
                $Incident.Closure_Product_Category_Tier1,
                $Incident.Closure_Product_Category_Tier2,
                $Incident.Closure_Product_Category_Tier3,
                $Incident.Closure_Product_Model_Version,
                $Incident.Closure_Product_Name,
                $Incident.Company,
                $Incident.Summary,
                $Incident.Notes,
                $Incident.Impact,
                $Incident.Manufacturer,
                $Incident.Product_Categorization_Tier_1,
                $Incident.Product_Categorization_Tier_2,
                $Incident.Product_Categorization_Tier_3,
                $Incident.Product_Model_Version,
                $Incident.Product_Name,
                $Incident.Reported_Source,
                $Incident.Resolution,
                $Incident.Resolution_Category,
                $Incident.Resolution_Category_Tier_2,
                $Incident.Resolution_Category_Tier_3,
                $Incident.Resolution_Method,
                $Incident.Service_Type,
                $Incident.Status,
                $Incident.Urgency,
                $Incident.Action,
                $Incident.Work_Info_Summary,
                $Incident.Work_Info_Notes,
                $Incident.Work_Info_Type,
                $Incident.Work_Info_Date,
                $Incident.Work_Info_Source,
                $Incident.Work_Info_Locked,
                $Incident.Work_Info_View_Access,
                $Incident.Incident_Number,
                $Incident.Status_Reason,
                $Incident.ServiceCI,
                $Incident.ServiceCI_ReconID,
                $Incident.HPD_CI,
                $Incident.HPD_CI_ReconID,
                $Incident.HPD_CI_FormName,
                $Incident.z1D_CI_FormName,
                $Incident.WorkInfoAttachment1Name,
                $Incident.WorkInfoAttachment1Data,
                $Incident.WorkInfoAttachment1OrigSize,
                $Incident.WorkInfoAttachment1OrigSizeSpecified
            )
        } else {
            write-output $Incident
        }
    
    }
}
end{}



}
