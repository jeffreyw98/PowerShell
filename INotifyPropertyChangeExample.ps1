Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, WindowsFormsIntegration

# get Create-WPFWindow function

. "$HOME\Documents\Powershell\Create-WPFWindow.ps1"
. "$HOME\Documents\Powershell\ObservableObject.ps1"
#. "$HOME\Documents\Powershell\PersonViewModel.ps1"
. "$HOME\Documents\Powershell\BackgroundViewModel.ps1"
. "$HOME\Documents\Powershell\MainViewModel.ps1"

$windowHash = [hashtable]::new()

$a = @'
using System;
public class WPFTestApp {
  public static string MainWindow() {
     return "Foo";
   }
}
'@

Function ListRefresh {
    "SelectionChanged"
}

Function Red_Click {
    $windowHash.Grid1.Background = [System.Windows.Media.Brushes]::Red
}

Function Blue_Click {
    $windowHash.Grid1.Background = [System.Windows.Media.Brushes]::Blue
}
Function Yellow_Click {
    $windowHash.Grid1.Background = [System.Windows.Media.Brushes]::Yellow
}

$b = Add-Type $a

Create-WPFWindow -windowHash $windowHash -xamlFileName "$HOME\Documents\PowerShell\INotifyPropertyChangeExample.xaml"


$windowHash.Red.Add_Click({Red_Click})
$windowHash.Blue.Add_Click({Blue_Click})
$windowHash.Yellow.Add_Click({Yellow_Click})

$main = [MainViewModel]::new()
$windowHash.Window.DataContext = $main

$binding = [System.Windows.Data.Binding]::new()
$binding.Source = $main
$binding.Path = "Person.Name"
$binding.Mode = [System.Windows.Data.BindingMode]::OneWayToSource
$binding.UpdateSourceTrigger = [System.Windows.Data.UpdateSourceTrigger]::PropertyChanged
#$binding.UpdateSourceTrigger = [System.Windows.Controls.TextBox]::TextChangedEvent
$binding1 = [System.Windows.Data.Binding]::new()
$binding1.Source = $main.Person
$binding1.Path = "Name"
$binding1.StringFormat = "Welcome {0}"
$binding1.BindsDirectlyToSource = $true
$binding1.NotifyOnSourceUpdated = $true


[void]$windowHash.txtName.SetBinding([System.Windows.Controls.TextBox]::TextProperty, $binding)
# [void][System.Windows.Data.BindingOperations]::SetBinding($windowHash.txtName, [System.Windows.Controls.TextBox]::TextProperty, $binding)
# [System.Windows.Data.BindingOperations]::SetBinding($windowHash.txtBlock, [System.Windows.Controls.TextBlock]::TextProperty, $binding1)
[void]$windowHash.txtBlock.SetBinding([System.Windows.Controls.TextBlock]::TextProperty, $binding1)
# $windowHash.lstBox.Add_SelectionChanged({ListRefresh});

[void]$windowHash.Window.Dispatcher.InvokeAsync{$windowHash.Window.ShowDialog()}.Wait()
