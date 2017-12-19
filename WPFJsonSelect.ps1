# Load WPF assembly if necessary
Add-Type -AssemblyName PresentationFramework
if ($HOME -eq "C:\Users\Jeff Waugh") {
    $location = "home"
} else {
    $location = "work"
}
$drive = "K:"
$Global:windowSelHash = [hashtable]::new()

# get Attunity servers\path into $servers hash and common function definitions
. "$HOME\Documents\PowerShell\AttunityServers.ps1"

# get common functions
. "$HOME\Documents\Powershell\AttunityCommon.ps1"

# get Create-WPFWindow function
. "$HOME\Documents\Powershell\Create-WPFWindow.ps1"

Create-WPFWindow -xamlFileName "$HOME\Documents\PowerShell\WPFJsonSelect.xaml" -windowHash $windowSelHash 

$serverList = New-Object -Typename 'System.Collections.Generic.List[System.String]'
$xamlServerList = New-Object -Typename 'System.Collections.Generic.List``1[System.Object]'
$taskList = New-Object -Typename 'System.Collections.Generic.List[System.String]'
$dirList = New-Object -TypeName 'System.Collections.Generic.List[System.String]'

Function TaskListRefresh {
    if ($windowSelHash.lstServers.SelectedItem) {
#        [System.Windows.Messagebox]::Show("SelectionChanged");
        $taskList.Clear()
        $global:taskDataContext.Clear()
        foreach ($lbi in $windowSelHash.lstServers.Selecteditems) {
            $server = $lbi.Children[0].Name
            $path = $servers.$server.Item("dir")
            
            if ($location -eq "home") {
                Map-Drive $drive $($windowSelHash.lstServers.SelectedItem) $path
                Get-ChildItem $drive\tasks | ?{$_.psiscontainer} | foreach-object {[void]$(FormatListItem $_.Name ($global:taskDataContext) $windowSelHash.lstTasks)}
            } else {
                Get-ChildItem \\$server\$path\tasks | ?{$_.psiscontainer} | foreach-object {[void]$(FormatListItem $_.Name ($global:taskDataContext) $windowSelHash.lstTasks)}
            }
        }
        $windowSelHash.lstTasks.ItemsSource = $null
        #$windowSelHash.lstTasks.ItemsSource = $global:taskDataContext
        $windowSelHash.lstTasks.SelectedIndex = 0
    }
}

Function Close {
    $windowSelHash.Window.Close()
}

Function FormatListItem {
    Param (
            $parm,
            $DataContext,
            $list
          )
    $sp = New-Object System.Windows.Controls.StackPanel
    $sp.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch;
    $sp.Orientation = [System.Windows.Controls.Orientation]::Horizontal
    $cb = New-Object System.Windows.Controls.CheckBox;
    $cb.IsChecked = $true
    $cb.Name = $parm
    $tb = New-Object System.Windows.Controls.TextBlock
    $tb.Text = $parm; $tb.Margin = "2,0,0,0"
    $lbi = New-Object System.Windows.Controls.ListBoxItem
    #$lbi.IsFocused = $true
#    $lbi.Focusable = $true
    $sp.Children.Add($cb); $sp.Children.Add($tb)
#   $lbi.DataContext = $sp
    $lbi.Content = $sp
    $list.AddChild($lbi)
#    $DataContext.Add($sp)
}

$global:serverDataContext = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$global:taskDataContext = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
<#
# Create and set a binding on the listbox object
$Binding = New-Object System.Windows.Data.Binding # -ArgumentList "[0]"
#$Binding.Path = "[0]"
$Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
$Binding.Source = $global:serverDataContext
[void][System.Windows.Data.BindingOperations]::SetBinding($windowSelHash.lstServers,[System.Windows.Controls.ListBox]::ItemsSourceProperty, $Binding)
$windowSelHash.lstServers.DataContext = $global:serverDataContext
#>
foreach ($server in $servers.GetEnumerator() | where {$_.value.env -eq "prod"} | sort -Property Name) {
    [void]$serverList.Add($server.Name)
    [void]$(FormatListItem $server.name $Global:serverDataContext $windowSelHash.lstServers)
    [void]$dirList.Add($($servers.Item($server.Name).Item("dir")))
}
#$windowSelHash.lstServers.ItemsSource = $global:serverDataContext

[System.Windows.Controls.ListBox]::itemss

if ($location -eq "home") {
    Map-Drive $drive $($serverList.Item(0)) $($dirList.Item(0))
    Get-ChildItem $drive\tasks | ?{$_.psiscontainer} | foreach-object {[void]$(FormatListItem $_.Name $global:taskDataContext $windowSelHash.lstTasks)}
} else {
    Get-ChildItem "\\$($serverlist.Item(0))\$($dirList.Item(0))\tasks" | ?{$_.psiscontainer} | foreach-object {[void]$(FormatListItem $_.Name $global:taskDataContext $windowSelHash.lstTasks)}
}
#$windowSelHash.lstTasks.ItemsSource = $global:taskDataContext
$windowSelHash.lstServers.SelectAll()
$windowSelHash.lstTasks.SelectAll()
$windowSelHash.lstServers.Add_SelectionChanged({TaskListRefresh});
$windowSelHash.btnSelOk.Add_Click({$windowSelHash.Window.DialogResult = $true; Close})

[void]$windowSelHash.Window.Dispatcher.InvokeAsync{$windowSelHash.Window.ShowDialog()}.Wait()
