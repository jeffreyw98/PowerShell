$this = Get-Content .\Documents\PowerShell\Window.xaml -raw
$that = @"
{0}
"@

$thisXml = $that -f $this

$thisxml
