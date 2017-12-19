Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, WindowsFormsIntegration

# get Create-WPFWindow function
. "$HOME\Documents\Powershell\Create-WPFWindow.ps1"

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
    [System.Windows.Forms.MessageBox]::Show("SelectionChanged")
}

$b = Add-Type $a

Create-WPFWindow -windowHash $windowHash -xamlFileName "$HOME\Documents\PowerShell\WPFTestApp.xaml"

$windowHash.lstBox.Add_SelectionChanged({ListRefresh});

[void]$windowHash.Window.Dispatcher.InvokeAsync{$windowHash.Window.ShowDialog()}.Wait()
