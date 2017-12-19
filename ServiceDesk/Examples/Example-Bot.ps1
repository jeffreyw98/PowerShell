$cred = get-credential


Find-Incident -Assigned_Group 'The Americas Windows Server Operations' -verbose -Credential $cred
    

$incidents = Find-Incident -credential $cred -Assigned_Group 'The Americas Windows Server Operations' -verbose
$incidents.count

$incidents|out-gridview

#get backup tickets
$backup = $incidents|where notes -match 'dcbackups\.ford\.com'
$backup.count

#assign all backup tickets
$backup| Set-IncidentAssignment -credential $cred  -Assignee "William J. Coyle" -whatif

#add a new worklog to all backup tickets
$backup|New-IncidentWorklog -credential $cred -Work_Info_Notes 'new note' -whatif


#add a new worklog to all backup tickets
$backup| Set-Incident -credential $cred -Status Resolved -Resolution 'Restarted TSM Service' -Resolution_Category Application_Software_Defect -WhatIf -verbose|out-null

