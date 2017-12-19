Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, WindowsFormsIntegration
[void][Reflection.Assembly]::LoadFile("$HOME\Documents\Powershell\Newtonsoft.Json.dll”)

 
Function Get-FormVariables {
    if ($global:ReadmeDisplay -ne $true) {
        Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow
        $global:ReadmeDisplay = $true
    }
    write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
    get-variable WPF*
}
 
<# Example of adding item to a ListView 
    $vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
#>

function ParseItem($jsonItem, $key) {

    if ($jsonItem.GetType() -eq [Newtonsoft.Json.Linq.JArray]) {
        ParseJsonArray($jsonItem)
    }
    elseif ($jsonItem.GetType() -eq [Newtonsoft.Json.Linq.JObject]) {
        ParseJsonObject($jsonItem)
    }
    else {
        if ($key.GetType() -ine [int]) {
            $taskName = [regex]::Match($JsonFile, '(.*)\\(\w+).json').groups[2].value
            if ($location -eq "work") {
                $serverName = [regex]::Match($JsonFile.DirectoryName, "\\\\(.*?)\\").groups[1].value
            } else {
                $serverName = $Server
            }
            if ($global:keyList[$Key] -notcontains ($serverName + ' - ' + $taskName)) { 
                $global:keyList[$key] += @($serverName + ' - ' + $taskName)
            }
            if ($global:pathList[$key] -notcontains $jsonItem.Path) {
                $global:pathList[$key] += $jsonItem.Path
            }
        }
    }
}

function ParseJsonObject($jsonObj) {
    $jsonObj | Select-Object -ExpandProperty Name | ForEach-Object {
        $key = $_
        $item = $jsonObj[$key]
        ParseItem $item $key
    }
}

function ParseJsonArray($jsonArray) {
    $counter = 0
    $jsonArray | ForEach-Object {
        $parsedItem = ParseItem $_ $counter
        $counter++
    }
}

function ParseJsonString($json) {
    $config = [Newtonsoft.Json.Linq.JObject]::Parse($json)
    return ParseJsonObject($config)
}

function ParseJsonFile($fileName) {
    $json = (Get-Content $FileName | Out-String)
    return ParseJsonString $json
}

Function SelectionChanged {
    #[System.Windows.MessageBox]::Show("Selection Changed")
    if ($windowHash.propertyList.SelectedItem -ne $null) {
        $windowHash.taskView.ItemsSource = $global:keylist."$($windowHash.propertyList.SelectedItem.Children[1].Text)"
    }
}

Function ShowProgress {
    # get location of progress bar in main window and set screen location where Progress window will display in new thread 
#    $a = New-Object -TypeName "System.Windows.Point"
#    [System.Windows.Point] $p = $windowHash.Window.PointToScreen($a)
    $windowProgHash.X = $windowHash.Window.Left; $windowProgHash.Y = $windowHash.Window.Top
    $windowProgHash.wWidht = $windowHash.Window.Width; $windowProgHash.wHeight = $windowHash.Window.Height
    $newRunspace =[runspacefactory]::CreateRunspace()
    $newRunspace.ApartmentState = "STA"
    $newRunspace.ThreadOptions = "ReuseThread"
    $newRunspace.Name = "Prog"         
    $newRunspace.Open()
    $newRunspace.SessionStateProxy.SetVariable("windowProgHash",$windowProgHash)          
    $psCmd = [PowerShell]::Create().AddScript({   
        . "$HOME\Documents\PowerShell\Create-WPFWindow.ps1"
        Create-WPFWindow -windowHash $windowProgHash -xamlFileName "$HOME\Documents\PowerShell\WPFProgressBar.xaml"
        Function OnLoaded {
            $Left = ($windowProgHash.wWidht - $windowProgHash.Window.Width) / 2
            $Top = ($windowProgHash.wHeight - $windowProgHash.Window.Height) / 2
            $windowProgHash.Window.Left = $Left
            $windowProgHash.Window.Top = $Top
        }
        $windowProgHash.Window.Add_Loaded({OnLoaded})
        $windowProgHash.btnCancel.Add_Click({$windowProgHash.Canceled = $true; $windowProgHash.Window.Close()})
        [void]$windowProgHash.Window.Dispatcher.InvokeAsync{$windowProgHash.Window.ShowDialog()}.Wait()

    })
    $psCmd.Runspace = $newRunspace
    $data = $psCmd.BeginInvoke()
    Start-Sleep -Milliseconds 500
    foreach ($JsonPath in $JsonPaths) {
        if ($windowSelHash.rbAllTasks.IsChecked) {
            $fileQualifier = "*" #.json"
            $Script:fileExclude = "Replicat*.json"
        } elseif ($windowSelHash.rbReplicationDefinition.IsChecked) {
            $fileQualifier = "Replicat"
            $Script:fileExclude = $null
        }
        $JsonPath += "$fileQualifier*.json"
        $JsonFiles = Get-ChildItem -Path $JsonPath -Exclude $fileExclude
        $parsedCount = 0
        foreach ($JsonFile in $JsonFiles) {
            $pct = $parsedCount / $Jsonfiles.count * 100
            $Taskname = $($jsonFile.Name -replace ".json","")
            $selectedTasks = $windowSelHash.lstTasks.SelectedItems | ForEach-Object {$_.Children[0].Name}
            if ($selectedtasks -contains $TaskName -or $TaskName -eq "Replication_Definition") {

                # update progress bar textblock in it's own thread
                $windowProgHash.sbItem.Dispatcher.Invoke([action]{$windowProgHash.sbItem.Text = "Processing: $($JsonFile.Name)"}, "Normal")
                $windowProgHash.pb.Dispatcher.Invoke([action]{$windowProgHash.pb.Value = $pct}, "Normal")
                ParseJsonFile $JsonFile
                $parsedCount++
                if ($debug -and $parsedCount -gt $parseLimit) {
                    break
                }
            }
            if ($windowProgHash.Canceled -eq $true) {
                $windowHash.Window.Close()
                $psCmd.Dispose()
                $newRunspace.Close()
                $newRunspace.Dispose()
                exit
            }
        }
        $Global:collection = New-Object System.Collections.Arraylist

        $mg = New-Object System.Windows.Thickness
        $mg.Left = 3

        $global:keyList.GetEnumerator() | Sort-Object -Property Key | ForEach-Object {
    
            $dp = New-Object System.Windows.Controls.DockPanel
            $dp.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch; $dp.MinWidth = 220 
            $cb = New-Object System.Windows.Controls.CheckBox; 
            if ($Defaults -contains '"' + $_.Key + '"') {
                $cb.IsChecked = $true
                $cb.Name = $_.Key
            }
            $tb = New-Object System.Windows.Controls.TextBlock
            $tb.Text = $_.Key; $tb.Margin = $mg
            $btn = New-Object System.Windows.Controls.Button
            $btn.Content = "..."; $btn.Width = [System.Double]::NaN; $btn.VerticalContentAlignment = [System.Windows.VerticalAlignment]::Top
            $btn.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Right; $btn.Add_Click({DisplayDetails})
            [System.Windows.Controls.DockPanel]::SetDock($btn, [System.Windows.HorizontalAlignment]::Right)
            [void]$dp.Children.Add($cb);[void]$dp.Children.add($tb); [void]$dp.Children.Add($btn)
            [void]$collection.add($dp)
        }
        $windowHash.propertyList.ItemsSource = $Global:collection
        $windowHash.propertyList.SelectedIndex = 0
    }    
    # clean up progress bar thread
    $windowProgHash.Window.Dispatcher.Invoke({[action]$windowProgHash.Window.Close()}, "Normal")
    $psCmd.Dispose()
    $newRunspace.Close()
    $newRunspace.Dispose()
}

Function DisplayDetails {
#    [System.Windows.MessageBox]::Show("Details for " + $WPFpropertyList.SelectedItem.Children[1].Text)
    $windowHash.detailView.Items.Clear()
    $windowHash.detailView.ItemsSource = $global:pathList."$($windowHash.propertyList.SelectedItem.Children[1].Text)"
    $windowHash.pupDetails.IsOpen = $true
}

Function ProcessJsonParameters {
<# $resultList is a list of json property names selected from the selection list 
   $myObject is a PSCustomObject of json parameter and value #>

    $Global:collection.GetEnumerator() | ForEach-Object {
        if ($_.Children[0].IsChecked) {
            $global:resultList += '"' + $_.Children[1].Text + '"'
        }
    }
    $allObjects = New-Object System.Collections.ArrayList
    
    # build a seed object to contain all properties that were selected in the selection dialog
    $myObject = [PSCustomObject][ordered]@{Taskname = "seed"}
    $resultList | ForEach-Object {if (($myObject | Get-Member -Name $_) -eq $null) {$myObject | Add-Member -MemberType NoteProperty -Name $_ -Value $null}}

    $allObjects.Add($myObject)
<# TODO Add looping through selected tasks #>
    foreach ($JsonPath in $JsonPaths) {
        $JsonPath += "*.json"
        $JsonFiles = Get-ChildItem -Path $JsonPath -Exclude $Script:fileExclude
        $parsedCount = 0
        foreach ($JsonFile in $JsonFiles) {
            $Taskname = $($jsonFile.Name -replace ".json","")
            if ($windowSelHash.lstTasks.SelectedItems -contains $TaskName) {
                $myObject = [PSCustomObject][ordered]@{Taskname = $Taskname}
                $Results = Select-String -Path $JsonFile -Pattern $global:resultList |
                Sort-Object -Property @{Expression={[string]$_.Line -replace '^.*?\"', "" -replace ":.*$", "" }} |
                ForEach-Object {
                    $value = ($_.Line -Replace "^.*?:","" -Replace '"', "" -Replace '\[', "" -Replace '\]', "" -Replace ',', '').Trim()
                    if (($myObject | Get-Member -Name $($_.Matches.Value)) -eq $null) {
                        $myObject |Add-Member -MemberType NoteProperty -Name $($_.Matches.Value) -Value ($value)
                    }
                }
                $allObjects.Add($myObject)
                $parsedCount++
                if ($debug -and $parsedCount -gt $parseLimit) {
                    break
                }
            }
        }
    }
    $allObjects | Export-Csv -Path $ResultPath #Out-GridView
    $windowHash.Window.Close()
}

Function SaveTo {
    $windowHash.FileDialog = New-Object Microsoft.Win32.OpenFileDialog
    $windowHash.FileDialog.FileName = $ResultPath
    $windowHash.FileDialog.CheckFileExists = $false
    if($windowHash.FileDialog.ShowDialog() -eq $true) {
        $Global:ResultPath = $windowHash.FileDialog.FileName
    }
}

Function PopupClose {
    $windowHash.detailView.ItemsSource = $null
    $windowHash.detailView.Items.Refresh()
    $windowHash.pupDetails.IsOpen = $false
}

<# Main program entry point #>

$debugOneServer = $false
$debug = $true

if ($HOME -eq "C:\Users\Jeff Waugh") {
    $location = "home"
} else {
    $location = "work"
}

if ($location -eq "home") {
    $fileQualifier = "ARIP_ARMKSPRD_T1"
} else {
    $fileQualifier = "Replicat"
}
$parseLimit = 100

if ($location -eq "home") {
    $ResultPath = "z:\root\mnt\C\Temp\results.csv"
} else {
    $ResultPath = "c:\temp\results.csv"
}

$Global:windowHash = [hashtable]::new()                 # hashtable for main window
$Global:windowSelHash = [hashtable]::new()              # hashtable for selection window
$Global:windowProgHash = [hashtable]::Synchronized(@{}) # hashtable for progress window

# get Attunity servers\path into $servers hash and common function definitions
. "$HOME\Documents\PowerShell\AttunityServers.ps1"

# get common functions
. "$HOME\Documents\Powershell\AttunityCommon.ps1"

# get Create-WPFWindow function
. "$HOME\Documents\Powershell\Create-WPFWindow.ps1"

# Show dialog to select server(s)/task(s) etc.
. "$HOME\Documents\PowerShell\WPFJsonSelect.ps1"
if ($windowSelHash.Window.DialogResult -eq $false) {
    exit
}

Create-WPFWindow -xamlFileName "$HOME\Documents\PowerShell\WPF_NSJsonListView.xaml" -windowHash $windowHash 

# a hash of json setting names (keys) and the array of 'server - taskname' that contains those keys 
$global:keylist = New-Object "System.Collections.Generic.Dictionary``2[System.String,System.Collections.Generic.List[System.String]]"

# a hash of json setting names (keys) and the array of json paths that contains those keys 
$global:pathList = New-Object "System.Collections.Generic.Dictionary``2[System.String,System.Collections.Generic.List[System.String]]"


$resultList = @()
$Defaults = @('"source_name"','"server"','"accessAlternateDirectly"','"emptyStringValue"','"username"','"sourceName"','"Timeout"',
            '"EventWait"','"cdcBatchSize"','"bulkBatchSize"','"addSupplementalLogging"','"useLogminerReader"','"retryInterval"',
            '"archivedLogDestId"','"useWindowsAuthentication"','"activateSafeguard"','"safeguardFrequency"','"use3rdPartyBackupDevice"',
            '"target_names"','"authenticationType"','"useHDFSHA"','"webHDFSHost"','"krbKDCType"','"krbRealm"','"krbPrincipal"','"krbKeyTabFile"',
            '"webHDFSHost"','"webHDFSPort"','"hdfsPath"','"hiveAccess"','"hiveODBCHost"','"hiveODBCPort"','"hiveJobAdditionalProperties"',
            '"useHDFSHA"','"webHDFSHost2"','"fileFormat"','"serdeName"','"serdeProperties"','"csvDelimiter"','"maxFileSize"','"compressionType"',
            '"writeBufferSize"','"cdcMinFileSize"','"cdcBatchTimeOut"','"lob_max_size"','"full_load_sub_tasks"','"full_load_enabled"',
            '"handle_ddl"','"start_table_behaviour"','"save_changes_enabled"','"batch_apply_enabled"','"header_columns_settings"',
            '"recovery_table_settings"','"safeguardPolicy"')


$JsonPaths = @()
$selectedServers = New-Object System.Collections.ArrayList
# initialize $JsonPaths based on the servers selected in the selection dialog
foreach( $sli in $windowSelHash.lstServers.SelectedItems) {$selectedServers.Add($sli.Children[0].Name)}

foreach ($server in $selectedServers.GetEnumerator() | where {$servers.item($_).env -eq "prod"} | sort ) {

#foreach ($server in $windowSelHash.lstServers.Selecteditems.GetEnumerator() | where {$servers.item($_).env -eq "prod"} | sort ) {
<# foreach ($server in $servers.GetEnumerator() | where {$_.value.env -eq "prod"} | sort -Property Name) { #>
    if ($location -eq "home") {
        $JsonPaths += $($servers.Item($server).Item("dir")) + "\logs\LatestJsons\"
    } else {
        $JsonPaths += "\\" + $($server) + "\" + $($servers.Item($server).dir) + "\logs\LatestJsons\" 
    }
    if ($degugOneServer) {break}
} 

$DataContext = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$Text = [string]"Starting..."
$DataContext.Add($Text)
$windowHash.sbItem.DataContext = $DataContext

# Create and set a binding on the textbox object
$Binding = New-Object System.Windows.Data.Binding # -ArgumentList "[0]"
$Binding.Path = "[0]"
$Binding.Mode = [System.Windows.Data.BindingMode]::OneWay
[void][System.Windows.Data.BindingOperations]::SetBinding($windowHash.sbItem,[System.Windows.Controls.TextBlock]::TextProperty, $Binding)

# Event Handlers
$windowHash.propertyList.Add_SelectionChanged({SelectionChanged})
$windowHash.btnOk.Add_Click({ProcessJsonParameters})
$windowHash.btnSaveTo.Add_Click({SaveTo})
$windowHash.btnClose.Add_Click({PopupClose})
$windowHash.Window.Add_ContentRendered({ShowProgress})

# Instantiate main window and execute ContentRendered event handler
[void]$windowHash.Window.Dispatcher.InvokeAsync{$windowHash.Window.ShowDialog()}.Wait()

