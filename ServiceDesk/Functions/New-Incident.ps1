<#
.Synopsis
   Creates a new BMC Incident with SOAP
.DESCRIPTION
   Creates a new BMC Incident with SOAP
.EXAMPLE
   New-Incident -credential $cred -ci_name 'fsilws10' -Summary 'Testing' -Notes 'here are the details' -URI 'http://wwwqa.itsms.ford.com/arsys/WSDL/public/eccvas1037/HPD_IncidentInterface_Create_WS'
.EXAMPLE 
  [pscustomobject]@{ci_name='fsilws10';Summary='Testing';Notes='here are the details'}|New-Incident -credential $cred  -whatif|out-null
.EXAMPLE
   @(
   [pscustomobject]@{ci_name='fsilws10';Summary='Testing';Notes='here are the details'}
   [pscustomobject]@{ci_name='fmc103105';Summary='testing automation';Notes='The notes go here'}
   ) |New-Incident -credential $cred  -whatif|out-null    
#>
Function New-Incident {
  [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
  param(
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [String]$CI_Name,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [String]$Summary,
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [String]$Notes,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$URI = "http://www.itsms.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_Create_WS", 
    [ValidateSet('ExtensiveWidespread', 'SignificantLarge', 'ModerateLimited', 'MinorLocalized')]
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Impact = 'ModerateLimited',
    [ValidateSet('Critical', 'High', 'Medium', 'Low')]
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Urgency = 'Low',
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Assigned_Group = 'The Americas Windows Server Operations',
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Assigned_Support_Organization = 'Global Service Desk',
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Assigned_Support_Company = 'Ford Motor Company',
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Corporate_ID = ([Environment]::UserName -replace '\$', ''),
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Assignee,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Categorization_Tier_1 = "Broken",
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Categorization_Tier_2 = "Hardware",
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Categorization_Tier_3 = "",
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Product_Categorization_Tier_1 = "Hardware" ,
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Product_Categorization_Tier_2 = "Miscellaneous",
    [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true)]
    [String]$Product_Categorization_Tier_3 = "Hardware",
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    [PSCredential]$Credential,
    $Work_Info_TypeSpecified = '',
    #$Vendor_Ticket_Number,
    $Submitter = $env:USERNAME,
    [ValidateSet('DirectInput', 'Chat', 'Email', 'Event', 'Escalation', 'Fax', 'SelfService', 'InstantMessage', 'Pager', 'Radio', 'SystemsManagement', 'Phone', 'VoiceMail', 'WalkIn', 'Web', 'Other', 'BMCImpactManagerEvent')]
    $Reported_Source = 'Event',
    [ValidateSet('CustomerInbound', 'CustomerCommunication', 'CustomerFollowup', 'CustomerStatusUpdate', 'CustomerOutbound', 'ClosureFollowUp', 'DetailClarification', 'GeneralInformation', 'ResolutionCommunications', 'SatisfactionSurvey', 'StatusUpdate', 'General', 'CRCCommunication', 'IncidentTaskAction', 'ProblemScript', 'WorkingLog', 'EmailSystem', 'PagingSystem', 'BMCImpactManagerUpdate', 'Chat', 'L1NoAccesstoPerformTask', 'L1LackofadequateKnowledgeArticle', 'L1ArticleInstructstoescalatetoL2', 'L2NoAccessforL1toperformtask', 'L2LackofadequateKnowledgeArticleatL1', 'L2ArticleInstructstoescalatetoL2', 'L2KnowledgeDocumentationnotfollowed', 'L2NoIncorrectTroubleshooting', 'L2ShiftLeftOpportunityforITSD', 'L2ShiftLeftOpportunityforOPSCTRL', 'L2Other', 'L2Misrouted', 'L2EngagedL3')]
    $Work_Info_Type = 'GeneralInformation'
  )
  begin {
    
    $proxy = New-AuthenticatedWebServiceProxy -credential $credential -URI $URI -Maxtries 2

    <#
    $CI_Name='test123'
    $Assigned_Group='The Americas Windows Server Operations'
    $Assigned_Support_Organization='Global Service Desk'
    $Assigned_Support_Company = 'Ford Motor Company'
    $Impact='ModerateLimited'
    $Urgency='low'
    $Summary='this is a test'
    $Notes='notes here'
    $Corporate_ID='abaker9'
    $Assignee='Aeron L. Baker'
    #> 

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


  }
  process {

    #get fields
    $Newticket = Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Submit_Service

    #creation Defaults
    $Newticket.Action = "CREATE"
    $Newticket.Create_Request = "No"
    $Newticket.Reported_Source = "DirectInput"
    $Newticket.Service_Type = "InfrastructureEvent"

    #work Info defaults
    $Newticket.Work_Info_Type = $Work_Info_Type
    $Newticket.Work_Info_Date = "$(get-date -f u)"
    $Newticket.Work_Info_Source = "SystemAssignment"
    $Newticket.Work_Info_Locked = "No"
    $Newticket.Work_Info_View_Access = "Public"
    $Newticket.Work_Info_Summary = ""
    $Newticket.Work_Info_Notes = ""

    #mandatory
    $Newticket.CI_Name = $CI_Name
    $Newticket.Assigned_Group = $Assigned_Group
    $Newticket.Assigned_Support_Organization = $Assigned_Support_Organization
    $Newticket.Assigned_Support_Company = $Assigned_Support_Company
    $Newticket.Impact = $ImpactType."$Impact"
    $Newticket.Urgency = $UrgencyType."$Urgency"
    $Newticket.Summary = $Summary
    $Newticket.Notes = $Notes
    $Newticket.Corporate_ID = $Corporate_ID

    #Misc
    $Newticket.Categorization_Tier_1 = $Categorization_Tier_1
    $Newticket.Categorization_Tier_2 = $Categorization_Tier_2
    $Newticket.Categorization_Tier_3 = $Categorization_Tier_3
    $Newticket.Product_Categorization_Tier_1 = $Product_Categorization_Tier_1
    $Newticket.Product_Categorization_Tier_2 = $Product_Categorization_Tier_2
    $Newticket.Product_Categorization_Tier_3 = $Product_Categorization_Tier_3
    
    $Newticket.Work_Info_TypeSpecified = $Work_Info_TypeSpecified
    #if ($PSBoundParameters.ContainsKey('Vendor_Ticket_Number')) {
    #  $Newticket.Vendor_Ticket_Number = $Vendor_Ticket_Number
    #}
    
    #no longer included?
    #$Newticket.Submitter = $Submitter

    #assignement
    if ($PSBoundParameters.ContainsKey("Assignee")) {
      $Newticket.Status = "Assigned"
      $Newticket.Assignee = $Assignee
    } else {
      $Newticket.Status = "New" # "InProgress"
    }
 

    #Blank
    $Newticket.Assigned_Group_Shift_Name = ""
    $Newticket.Lookup_Keyword = ""
    $Newticket.Manufacturer = ""
    $Newticket.Product_Model_Version = ""
    $Newticket.Product_Name = ""
    $Newticket.Resolution = ""
    $Newticket.Resolution_Category_Tier_1 = ""
    $Newticket.Resolution_Category_Tier_2 = ""
    $Newticket.Resolution_Category_Tier_3 = ""
    $Newticket.Closure_Manufacturer = ""
    $Newticket.Closure_Product_Category_Tier1 = ""
    $Newticket.Closure_Product_Category_Tier2 = ""
    $Newticket.Closure_Product_Category_Tier3 = ""
    $Newticket.Closure_Product_Model_Version = ""
    $Newticket.Closure_Product_Name = ""

    #Create Incident Ticket
    if ($pscmdlet.ShouldProcess("New Ticket", "Creating")) {
      $proxy.HelpDesk_Submit_Service(
        $Newticket.Assigned_Group,
        $Newticket.Assigned_Group_Shift_Name,
        $Newticket.Assigned_Support_Company,
        $Newticket.Assigned_Support_Organization,
        $Newticket.Assignee,
        $Newticket.Categorization_Tier_1,
        $Newticket.Categorization_Tier_2,
        $Newticket.Categorization_Tier_3,
        $Newticket.CI_Name,
        $Newticket.Closure_Manufacturer,
        $Newticket.Closure_Product_Category_Tier1,
        $Newticket.Closure_Product_Category_Tier2,
        $Newticket.Closure_Product_Category_Tier3,
        $Newticket.Closure_Product_Model_Version,
        $Newticket.Closure_Product_Name,
        $Newticket.Department,
        $Newticket.First_Name,
        $Newticket.Impact,
        $Newticket.Last_Name,
        $Newticket.Lookup_Keyword,
        $Newticket.Manufacturer,
        $Newticket.Product_Categorization_Tier_1,
        $Newticket.Product_Categorization_Tier_2,
        $Newticket.Product_Categorization_Tier_3,
        $Newticket.Product_Model_Version,
        $Newticket.Product_Name,
        $Newticket.Reported_Source,
        $true,
        $Newticket.Resolution,
        $Newticket.Resolution_Category_Tier_1,
        $Newticket.Resolution_Category_Tier_2,
        $Newticket.Resolution_Category_Tier_3,
        $Newticket.Service_Type,
        $Newticket.Status,
        $Newticket.Action,
        $Newticket.Create_Request,
        $Newticket.Summary,
        $Newticket.Notes,
        $Newticket.Urgency,
        $Newticket.Work_Info_Notes,
        $Newticket.Work_Info_Summary,
        $Newticket.Work_Info_Date,
        $Newticket.Work_Info_Type,
        $true,
        $Newticket.Work_Info_Source,
        $Newticket.Work_Info_Locked,
        $Newticket.Work_Info_View_Access,
        $Newticket.Middle_Initial,
        $Newticket.Corporate_ID
      )
    } else {
      $Newticket.Urgency = $Urgency
      $Newticket.Impact = $Impact
      write-output $Newticket
    }

  }
  end {}
}