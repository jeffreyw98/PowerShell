<#
.Synopsis
   Uses SOAP connection to find a list of BMC servicedesk tickets
.DESCRIPTION
   Uses SOAP connection to find a list of BMC servicedesk tickets
.EXAMPLE
    Find-Incident -credential $cred -Assigned_Group 'The Americas Windows Server Operations'
.EXAMPLE
    Find-Incident -credential $cred -Assignee 'Ali I. Noureddine' -Assigned
.EXAMPLE
    Find-Incident -credential $cred -Assigneeid abaker9 -verbose
.EXAMPLE
    Find-Incident -credential $cred -verbose
.NOTES

-InProgress not working?: Exception calling "HelpDesk_QueryList_Service" with "3" argument(s): "ERROR (4558): Qualification line error; "

$filter = @"
'Assignee'="Aeron L. Baker" AND ('Status'="Cancelled")
"@

$filter = @"
'Assignee'="Aeron L. Baker" AND ('Status'="InProgress")
"@

$filter = @"
'Assignee'="Aeron L. Baker" AND 'Status'="Closed"
"@
$proxy.HelpDesk_QueryList_Service($filter,0,100)

#if you try to use the the production WSDL:
    'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_WS'

#you get the following:
    Exception calling "HelpDesk_QueryList_Service" with "3" argument(s): "There is an error in XML document (242, 23)."
    Find-Incident -credential $cred -verbose -URI  'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_WS'

    Find-Incident -credential $cred -verbose -URI 'C:\Users\$abaker9\documents\WindowsPowerShell\modules\ServiceDesk\files\HPD_IncidentInterface_WS.wsdl'
    Find-Incident -credential $cred -verbose -URI 'C:\Users\$abaker9\documents\WindowsPowerShell\modules\ServiceDesk\files\BMCQuery.xml'
#>
function Find-Incident{
[CmdletBinding(DefaultParameterSetName="ID")] 
param(
[Parameter(Mandatory=$true, ParameterSetName='Group')]
$Assigned_Group,
[Parameter(Mandatory=$true, ParameterSetName='User')]
$Assignee,
[Parameter(Mandatory=$false, ParameterSetName='ID')]
$AssigneeID=($env:USERNAME).TrimStart('$'),
[switch]$Assigned,
[switch]$Closed,
[switch]$Resolved,
[switch]$Cancelled,
[switch]$Pending,
#[switch]$InProgress, "doesn't work?"
[String]$URI= "file://$modulepath\files\HPD_IncidentInterface_WS.wsdl",#'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_WS'
[int]$MaxResults=200,
[Parameter(Mandatory=$true)]
[pscredential]$Credential
)
begin{
    $Status = @()
    $filter = @()
    write-verbose -message "Creating Proxy from $URI"
    $proxy = New-AuthenticatedWebServiceProxy -credential $credential -URI $URI -Maxtries 2

}
process{
   $Status = @()
    if ($Assigned){
        $Status+="'Status'=`"Assigned`""
    }
    if ($Closed){
        $Status+="'Status'=`"Closed`""
    }
    if ($Resolved){
        $Status+="'Status'=`"Resolved`""
    }
    if ($Cancelled){
        $Status+="'Status'=`"Cancelled`""
    }
    if ($Pending){
        $Status+="'Status'=`"Pending`""
    }
    if ($Pending){
        $Status+="'Status'=`"Pending`""
    }
    if ($InProgress){
        $Status+="'Status'=`"InProgress`""
    }
    
    if ($Status){
        $StatusFilter = $Status -join ' OR '
    } else {
        $StatusFilter = "'Status' <> `"Closed`" AND 'Status' <> `"Cancelled`" AND 'Status' <> `"Resolved`""
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        'Group' {
            $filter += "'Assigned Group'=`"$Assigned_Group`""
        }
        'User' {
            $filter += "'Assignee'=`"$Assignee`""
        }
        'ID' {
            write-verbose -message 'Looking up fullname from ID'
            $filter += "'Assignee'=`"$(Get-fullname $AssigneeID)`""
        }
    }

    if ($status){
        $filter+= "($StatusFilter)"
    }
}
end{
    write-verbose -Message "$($filter -join " AND ")"
    $proxy.HelpDesk_QueryList_Service($filter -join " AND ",0,$MaxResults)
}
    
}
