 
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
                $serverName = ($Server.Name)
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
    $WPFtaskView.ItemsSource = $global:keylist."$($WPFpropertyList.SelectedItem.Children[1].Text)"
}

Function ShowProgress {
    $WPFprogressTb.Text = "Loading Replication_Definition.json"
    $WPFpupProgress.IsOpen = $true
    $WPFpupProgress.Add_Loaded({$WPFpupProgress.IsOpen=$true})

    foreach ($JsonPath in $JsonPaths) {
    $JsonPath += "Replicat*.json"
    $JsonFiles = Get-ChildItem -Path $JsonPath
    $parsedCount = 0
    foreach ($JsonFile in $JsonFiles) {
        ParseJsonFile $JsonFile
        $parsedCount++
        if ($debug -and $parsedCount -gt $parseLimit) {
            break
        }
    }
    $collection = New-Object System.Collections.Arraylist

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

    $WPFpropertyList.ItemsSource = $collection
    $WPFpropertyList.SelectedIndex = 0
    $WPFpupProgress.IsOpen = $false
}

}
Function DisplayDetails {
#    [System.Windows.MessageBox]::Show("Details for " + $WPFpropertyList.SelectedItem.Children[1].Text)
    $WPFdetailView.Items.Clear()
    $WPFdetailView.ItemsSource = $global:pathList."$($WPFpropertyList.SelectedItem.Children[1].Text)"
    $WPFpupDetails.IsOpen = $true
}

Function ProcessJsonParameters {
#    [System.Windows.MessageBox]::Show("Ok Clicked")
    $collection.GetEnumerator() | ForEach-Object {
        if ($_.Children[0].IsChecked) {
            $global:resultList += '"' + $_.Children[1].Text + '"'
        }
    }
    $allObjects = New-Object System.Collections.ArrayList

    $myObject = [PSCustomObject][ordered]@{Taskname = "seed"}
    $resultList | ForEach-Object {$temp = ($myObject | Get-Member -Name $_); if ($temp -eq $null) {$myObject | Add-Member -MemberType NoteProperty -Name $_ -Value $null}}

    $allObjects.Add($myObject)

    foreach ($JsonPath in $JsonPaths) {
        $JsonPath += "*.json"
        $JsonFiles = Get-ChildItem -Path $JsonPath
        $parsedCount = 0
        foreach ($JsonFile in $JsonFiles) {
            $myObject = [PSCustomObject][ordered]@{Taskname = $($jsonFile.Name -replace ".json","")}
            $Results = Select-String -Path $JsonFile -Pattern $global:resultList |
            Sort-Object -Property @{Expression={[string]$_.Line -replace '^.*?\"', "" -replace ":.*$", "" }} |
            ForEach-Object {
                $value = ($_.Line -Replace "^.*?:","" -Replace '"', "" -Replace '\[', "" -Replace '\]', "" -Replace ',', '').Trim()
                $temp = ($myObject | Get-Member -Name $($_.Matches.Value))
                if ($temp -eq $null) {
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
    $allObjects | Export-Csv -Path $ResultPath #Out-GridView
    $Form.Close()
}

Function PopupClose {
    $WPFdetailView.ItemsSource = $null
    $WPFdetailView.Items.Refresh()
    $WPFpupDetails.IsOpen = $false
}

<# Main program entry point #>
Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, WindowsFormsIntegration
[void][Reflection.Assembly]::LoadFile("$HOME\Documents\Powershell\Newtonsoft.Json.dll”)

$debugOneServer = $false
$debug = $true
$location = "home"
$parseLimit = 25

if ($location -eq "home") {
    $ResultPath = "z:\root\mnt\C\Temp\results.csv"
} else {
    $ResultPath = "c:\temp\results.csv"
}

# get Attunity servers\path into $servers hash and common function definitions
. "$HOME\Documents\PowerShell\AttunityServers.ps1"

# get common functions
. "$HOME\Documents\Powershell\AttunityCommon.ps1"

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

$InputXML = @"
<Window x:Class="WPFPowerShell.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WPFPowerShell"
        mc:Ignorable="d"
        Title="MainWindow" Height="500" Width="525">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="15*"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <ListBox x:Name="propertyList" Margin="2,2,1,2" SelectionMode="Extended" HorizontalAlignment="Stretch">
        </ListBox>
        <ListView x:Name="taskView" Grid.Column="1" Margin="1,2,2,2" HorizontalContentAlignment="Stretch" VerticalContentAlignment="Stretch">
            <ListView.View>
                <GridView>
                    <GridViewColumn/>
                </GridView>
            </ListView.View>
        </ListView>
        <StackPanel Orientation="Horizontal" Grid.Row="1" Grid.ColumnSpan="2" Margin="2">
            <Button x:Name="btnOk" Content="Ok" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="2"/>
        </StackPanel>
        <Popup x:Name="pupDetails" Placement="Mouse">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="20*"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <ListView x:Name="detailView" Margin="2,2,2,2" HorizontalContentAlignment="Stretch" VerticalContentAlignment="Stretch">
                    <GridView>
                    </GridView>
                </ListView>
                <Button x:Name="btnClose" Content="Close" HorizontalAlignment="Center" Margin="10" Grid.Row="1"/>
            </Grid>
        </Popup>
        <Popup x:Name="pupProgress" Placement="Center">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition/>
                    <RowDefinition/>
                </Grid.RowDefinitions>
                <TextBlock x:Name="progressTb" HorizontalAlignment="Stretch" Text="" Grid.Row="0" Background="#FFFFFFFF" />
                <ProgressBar Height="20"  Width="100" IsIndeterminate="True" Grid.Row="1"/>
            </Grid>
        </Popup>
    </Grid>
</Window>
"@

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'

[xml]$xaml = $inputXML

$reader = (New-Object System.Xml.XmlNodeReader $xaml)

try {
    $Form = [Windows.Markup.XamlReader]::Load( $reader )
}
catch {
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
    Write-Host $_.Exception.Message
}
 
<# Get UIElement named from xaml and create PS variables prefixed with WPF #> 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
$JsonPaths = @()
foreach ($server in $servers.GetEnumerator() | where {$_.value.env -eq "prod"} | sort -Property Name) {
    if ($location -eq "home") {
        $JsonPaths += $($servers.Item($server.Name).Item("dir")) + "\logs\LatestJsons\"
    } else {
        $JsonPaths += "\\" + $($server.Name) + "\" + $($servers.Item($server.Name).Item("dir")) + "\logs\LatestJsons\" 
    }
    if ($degugOneServer) {break}
}


$WPFpropertyList.Add_SelectionChanged({SelectionChanged})
$WPFbtnOk.Add_Click({ProcessJsonParameters})
$WPFbtnClose.Add_Click({PopupClose})
$Form.Add_ContentRendered({ShowProgress})

$buttonType = [System.Windows.MessageBoxButton]::OKCancel
$message = "Loading Replication_Definition.json`n This will take several minutes."
$title = "Loading json properties"
$icon = [System.Windows.MessageBoxImage]::Information
[System.Windows.MessageBox]::Show($message, $title, $buttonType, $icon)

[void]$Form.ShowDialog() 
