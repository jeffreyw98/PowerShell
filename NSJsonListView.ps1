[Reflection.Assembly]::LoadFile("$HOME\Documents\Powershell\Newtonsoft.Json.dll”)

#$fileName = "C:\Temp\FOCALPTLDS_FLDS_T1.json"
#$fileName = "C:\Temp\DB2_C1_DB22_T1.json"
$outFile = "C:\Temp\xaml.out"

# get Attunity servers\path into $servers hash
$location = "home"

. "$HOME\Documents\Powershell\AttunityServers.ps1"

$startxaml = @"
    <Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WPFPowerShell"
        mc:Ignorable="d"
        Title="MainWindow" Height="500" Width="525">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <ListBox x:Name="propertyList" Margin="0" SelectionMode="Extended">
"@

$endxaml = @"
        </ListBox>
        <ListView x:Name="taskView" Grid.Column="1" Margin="0" HorizontalContentAlignment="Stretch" VerticalContentAlignment="Stretch">
            <ListView.View>
                <GridView>
                    <GridViewColumn/>
                </GridView>
            </ListView.View>
        </ListView>
    </Grid>
</Window>
"@

$xamlListItem = @"

            <ListBoxItem>
                <StackPanel Orientation="Horizontal">
                    <CheckBox/>
                    <TextBlock Text="{0}" Margin="4,0,0,0"/>
                </StackPanel>
            </ListBoxItem>
"@

# $keyList = @{}
$keyList = New-Object "System.Collections.Generic.Dictionary``2[System.String,System.Collections.Generic.List[System.String]]"

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
            if ( $global:keyList[$key] -notcontains $taskName) { 
                $global:keyList[$key] += @(($server.Name) + ' - ' + $taskName)
            }
        }
    }
}

function ParseJsonObject($jsonObj) {
#    $result = @{}
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

$JsonPaths = @()
foreach ($server in $servers.GetEnumerator() | where {$_.value.env -eq "prod"} | sort -Property Name) {
    if ($location -eq "home") {
        $JsonPaths += $($servers.Item($server.Name).Item("dir")) + "\logs\LatestJsons\"
    } else {
        $JsonPaths += "\\" + $($server.Name) + "\" + $($servers.Item($server.Name).Item("dir")) + "\logs\LatestJsons\" 
    }
}

foreach ($JsonPath in $JsonPaths) {
    $JsonPath += "*.json"
    $JsonFiles = Get-ChildItem -Path $JsonPath

    foreach ($JsonFile in $JsonFiles) {
        ParseJsonFile $JsonFile
    }
}

$xamlOutput = $null
$xamlOutput += $startxaml

$global:keyList.GetEnumerator() | Sort-Object -Property Name | ForEach-Object {
    $global:xamlOutput += $xamlListItem -f $_.Key
}

$xamlOutput += $endxaml

$xamlOutput | Out-File -FilePath $outFile


