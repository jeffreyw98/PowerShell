
$cred = get-credential

get-fullname abaker9

New-Incident -credential $cred -ci_name 'www.gsoutils.ford.com' -Summary 'Need help using dstx files in shared DB farm' `
-Notes 'Need help getting SQL server import/export wizard working in shared DB farm' -Assigned_Group "The Americas SQL Server Operations"

New-Incident -credential $cred -ci_name 'www.gsoutils.ford.com' -Summary 'test ticket' `
-Notes 'This is a test, please cancel' -Assigned_Group "The Americas Windows Server Operations" -Assignee (get-fullname wcoyle)

