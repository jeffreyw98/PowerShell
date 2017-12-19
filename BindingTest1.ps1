Add-Type -AssemblyName PresentationFramework

$Global:windowHash = [hashtable]::new()

# get Attunity servers\path into $servers hash and common function definitions
. "$HOME\Documents\PowerShell\AttunityServers.ps1"

# get common functions
. "$HOME\Documents\Powershell\AttunityCommon.ps1"

# get Create-WPFWindow function
. "$HOME\Documents\Powershell\Create-WPFWindow.ps1"

Create-WPFWindow -xamlFileName ".\Documents\PowerShell\Window.xaml" -windowHash $windowHash 

# Create a datacontext for the textbox and set it
$DataContext = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$Text = [int]0
$DataContext.Add($Text)
$windowHash.txtBox.DataContext = $DataContext

# Create and set a binding on the textbox object
$Binding = New-Object System.Windows.Data.Binding # -ArgumentList "[0]"
$Binding.Path = "[0]"
$Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
[void][System.Windows.Data.BindingOperations]::SetBinding($windowHash.txtBox,[System.Windows.Controls.TextBox]::TextProperty, $Binding)

# Add an event for the button click
$windowHash.Button.Add_Click{
    $DataContext[0] ++
}

[void]$windowHash.Window.Dispatcher.InvokeAsync{$windowHash.Window.ShowDialog()}.Wait()

