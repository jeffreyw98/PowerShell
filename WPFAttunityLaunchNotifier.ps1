Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, WindowsFormsIntegration

$global:ReadmeDisplay = $true

<# XML for WPF gui #>
$inputXML = @"
<Window x:Class="WpfAttunityLaunchMonitor.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfAttunityLaunchMonitor"
        mc:Ignorable="d"
        Title="Attunity Launch Monitor" Height="384.314" Width="525">
    <Grid Margin="0,0,2,-55">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="379*"/>
            <ColumnDefinition Width="138*"/>
        </Grid.ColumnDefinitions>
        <Canvas x:Name="canvas" HorizontalAlignment="Left" Height="354" Margin="10,10,0,0" VerticalAlignment="Top" Width="497" Grid.ColumnSpan="2">
            <ListBox x:Name="lstServers" Height="122" Width="226" RenderTransformOrigin="0.472,0.434" Canvas.Top="33"/>
            <Label x:Name="label" Content="Servers"/>
            <ListBox x:Name="lstTasks" Height="122" Canvas.Left="263" Canvas.Top="33" Width="224"/>
            <Label x:Name="label1" Content="Tasks" Canvas.Left="263" RenderTransformOrigin="-0.693,0.198"/>
            <Label x:Name="label2" Content="Email or Text Pager" Canvas.Left="10" Canvas.Top="160" RenderTransformOrigin="0.503,0.59" Width="118"/>
            <TextBox x:Name="txtEmail" Height="23" Canvas.Left="10" TextWrapping="Wrap" Text="TextBox" Canvas.Top="186" Width="200"/>
            <Button x:Name="btnTest" Content="Test" Canvas.Left="225" Canvas.Top="186" Width="45"/>
            <CheckBox x:Name="cbxAlert" Content="Alert on Warning?" Canvas.Left="333" Canvas.Top="188" IsChecked="True"/>
            <Label x:Name="label3" Content="Start Monitoring" Canvas.Left="10" Canvas.Top="214"/>
            <Label x:Name="label4" Content="End Monitoring" Canvas.Left="10" Canvas.Top="245"/>
            <Label x:Name="label5" Content="Monitor Frequency" Canvas.Left="333" Canvas.Top="222"/>
            <Button x:Name="btnDelete" Content="Delete" Canvas.Left="10" Canvas.Top="306" Width="75"/>
            <Button x:Name="btnSave" Content="Save" Canvas.Left="412" Canvas.Top="306" Width="75"/>
        </Canvas>
    </Grid>
</Window>
"@       
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'

[xml]$XAML = $inputXML

#Read XAML
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
# Get-FormVariables


#===========================================================================
# Actually make the objects work
#===========================================================================
 
#Sample entry of how to add data to a field
 
#$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
 
$WPFbtnTest.Add_Click({TestClick})
$WPFbtnDelete.Add_Click({DeleteClick})
$WPFbtnSave.Add_Click({SaveClick})

Function SaveClick {
    [System.Windows.MessageBox]::Show($dtpBegin.Value.ToString())
    $startDate = $dtpBegin.Value
    $endDate = $dtpEnd.Value
    $interval = $nud.Value

    $ts = New-Object -ComObject("Schedule.Service")
    $filePath = "notepad.exe"
    $TaskName = "AttunityLaunch"

    $ts.connect()

    $td = $ts.NewTask(0);
            
    $td.RegistrationInfo.Author = "My company";
    $td.RegistrationInfo.Description = "Runs test application";
    $td.Settings.Enabled = $true;
    $td.Settings.Hidden = $false;
    $td.Settings.Compatibility = 2 #[TaskScheduler]::_TASK_COMPATIBILITY.TASK_COMPATIBILITY_V2;
    $timeSpan = [System.TimeSpan]::FromMinutes(10);
    $td.Settings.ExecutionTimeLimit = [System.Xml.XmlConvert]::ToString($timeSpan);
    $td.Settings.IdleSettings.IdleDuration = [system.Xml.XmlConvert]::ToString($timeSpan);
    $td.Settings.RunOnlyIfIdle = $false;
    $triggers = $td.Triggers;
    $trigger = $triggers.Create(2) # [TaskScheduler]::_TASK_TRIGGER_TYPE2.TASK_TRIGGER_DAILY);
    $trigger.Enabled = $true;
    $trigger.StartBoundary = [System.Xml.XmlConvert]::ToString($startDate);
    $trigger.EndBoundary = [System.Xml.XmlConvert]::ToString($endDate);
    $trigger.Repetition.Interval = "PT" + $interval + "M";
    $actions = $td.Actions;
    $actionType = 0 # [TaskScheduler]::_TASK_ACTION_TYPE.TASK_ACTION_EXEC;
    $action = $actions.Create($actionType);
    $execAction = $action # as IExecAction;
    $execAction.Path = $filePath;

    $rootFolder = $ts.GetFolder("\");
    $rootFolder.RegisterTaskDefinition($TaskName, $td, 6, $null, $null, 0, <#[TaskScheduler]::_TASK_LOGON_TYPE.TASK_LOGON_NONE,#> $null);
}

Function DeleteClick {
    $ts = New-Object -ComObject("Schedule.Service")
    $filePath = "notepad.exe"
    $TaskName = "AttunityLaunch"

    $ts.connect()

    $rootFolder = $ts.GetFolder("\");

    try {
        $rootFolder.DeleteTask($TaskName, 0)
        }
    catch {}
}

Function TestClick {
        $mailTo = $WPFtxtEmail.Text

        $Outlook = New-Object -ComObject Outlook.Application
        $Mail = $Outlook.CreateItem(0)
        if ($debug) {
            if ($location -eq "home") {
                $Mail.To = "jwaugh@griddlecat.com"
            } else {
                $Mail.To = "jwaugh@ford.com"
            }
        } else {
            $Mail.To = $mailTo
        }
        $Mail.Subject = "Testing Attunity Launch Monitor" 
        $Mail.BodyFormat = 2
        $Mail.HTMLBody = "Testing mail or text paging from Attunity Launch Monitor. `n"
        $Mail.HTMLBody = "<pre><font face='Lucida Sans Typewriter'>$a</font></pre>"
        $Mail.Send()
}

<# Add Windows.Forms.DateTimePicker and NumericUpDown controls to canvas #>
$dtpBeginhost = New-Object System.Windows.Forms.Integration.WindowsFormsHost
$dtpBegin = New-Object System.Windows.Forms.DateTimePicker
$dtpBegin.Format = "Custom"
$dtpBegin.CustomFormat = "dd MMMM 'at' hh:mm tt"
$dtpBegin.Width = 180
$dtpBeginhost.Child = $dtpBegin
[System.Windows.Controls.Canvas]::SetTop($dtpBeginhost, 220)
[System.Windows.Controls.Canvas]::SetLeft($dtpBeginhost, 124)
$WPFcanvas.AddChild($dtpBeginhost)

$dtpEndhost = New-Object System.Windows.Forms.Integration.WindowsFormsHost
$dtpEnd = New-Object System.Windows.Forms.DateTimePicker
$dtpEnd.Format = "Custom"
$dtpEnd.CustomFormat = "dd MMMM 'at' hh:mm tt"
$dtpEnd.Width = 180
$dtpEndhost.Child = $dtpEnd
[System.Windows.Controls.Canvas]::SetTop($dtpEndhost, 254)
[System.Windows.Controls.Canvas]::SetLeft($dtpEndhost, 124)
$WPFcanvas.AddChild($dtpEndhost)

$nudhost = New-Object System.Windows.Forms.Integration.WindowsFormsHost
$nud = New-Object System.Windows.Forms.NumericUpDown
$nud.Height = 20
$nud.Width = 35
$nud.Value = 10
$nud.Enabled = $true
$nudhost.Child = $nud
[System.Windows.Controls.Canvas]::SetTop($nudhost, 253)
[System.Windows.Controls.Canvas]::SetLeft($nudhost, 333)
$WPFcanvas.AddChild($nudhost)


$Form.ShowDialog() | Out-Null

