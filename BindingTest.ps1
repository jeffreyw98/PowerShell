
$Global:windowHash = [hashtable]::new()

# get Attunity servers\path into $servers hash and common function definitions
. "$HOME\Documents\PowerShell\AttunityServers.ps1"

# get common functions
. "$HOME\Documents\Powershell\AttunityCommon.ps1"

[xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:BindingTest"
        Title="MainWindow" Height="79.274" Width="390.385">
    <Grid>
        <TextBox Name="txtBox" HorizontalAlignment="Left" Height="23" TextWrapping="Wrap" Text="TextBox" VerticalAlignment="Top" Width="120"/>
        <TextBlock HorizontalAlignment="Right" TextWrapping="Wrap" Text="{Binding Text, ElementName=txtBox}" VerticalAlignment="Top"/>
        <Button Name="Button" HorizontalAlignment="Center" Height="Auto" Width="Auto" Content="Increment Me!"/>
    </Grid>
</Window>
"@

$reader=(New-Object System.Xml.XmlNodeReader $xaml)
    
$windowHash.Window=[Windows.Markup.XamlReader]::Load( $reader )

$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | %{
    #Find all of the form types and add them as members to the windowHash
    $windowHash.Add($_.Name,$windowHash.Window.FindName($_.Name) )
}

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

# https://smsagent.wordpress.com/2017/02/03/powershell-deepdive-wpf-data-binding-and-inotifypropertychanged/
