[Reflection.Assembly]::LoadFile("$HOME\Documents\Powershell\Newtonsoft.Json.dll”)

#$fileName = "C:\Temp\FOCALPTLDS_FLDS_T1.json"
$fileName = "C:\Temp\DB2_C1_DB22_T1.json"
$outFile = "C:\Temp\xaml.out"

$startxaml = @"
    <Window x:Class="WpfJsonTreeView.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfJsonTreeView"
        mc:Ignorable="d"
        Title="MainWindow" Height="500" Width="525">
    <Grid>
        <TreeView x:Name="treeView" HorizontalAlignment="Left" Height="489" VerticalAlignment="Top" Width="520">

"@

$endxaml = @"
            </TreeView>
    </Grid>
</Window>
"@

$xamlTreeViewItemOpen = @"
            <TreeViewItem>
                <TreeViewItem.Header>
                    <StackPanel Orientation="Horizontal">
                        <CheckBox VerticalAlignment="Center"/>
                        <TextBlock Text="{0}" Margin="2, 0, 0, 0"/>
                    </StackPanel>
                </TreeViewItem.Header>

"@
$xamlTreeViewItemValueOpen = @"
            <TreeViewItem>
                <TreeViewItem.Header>
                    <StackPanel Orientation="Horizontal">
                        <CheckBox VerticalAlignment="Top"/>
                        <StackPanel Orientation="Vertical">
                            <TextBlock Text="{0}" Margin="2, 0, 0, 0" FontWeight="Medium"/>
                            <TextBlock Text="{1}" Margin="2, 0, 0, 0"/>
                        </StackPanel>
                    </StackPanel>
                </TreeViewItem.Header>

"@

$xamlTreeViewItemClose = @"

            </TreeViewItem>
"@
$xamlOutput = ""

Function xamlAddNode {
    Param ($key)
    $global:xamlOutput += $xamlTreeViewItemOpen -f $key 
}

Function xamlAddNodeValue {
    Param ( $key,
            $value
        )
        $global:xamlOutput += $xamlTreeViewItemValueOpen -f $key, $value
}

function ParseItem($jsonItem, $key) {

    if ($jsonItem.GetType() -eq [Newtonsoft.Json.Linq.JArray]) {
        xamlAddNode $key
        $outVar = ParseJsonArray($jsonItem)
        $global:xamlOutput += $xamlTreeViewItemClose
        return $outVar
    }
    elseif ($jsonItem.GetType() -eq [Newtonsoft.Json.Linq.JObject]) {
        xamlAddNode $key
        $outVar = ParseJsonObject($jsonItem)
        $global:xamlOutput += $xamlTreeViewItemClose
        return $outVar
    }
    else {
        xamlAddNodeValue $key $jsonItem.ToString()
        $global:xamlOutput += $xamlTreeViewItemClose
        return $jsonItem.ToString()
    }
}

function ParseJsonObject($jsonObj) {
    $result = @{}
    $jsonObj | Select-Object -ExpandProperty Name | ForEach-Object {
        $key = $_
        $item = $jsonObj[$key]
        $parsedItem = ParseItem $item $key
        $result.Add($key,$parsedItem)
    }
    return $result
}

function ParseJsonArray($jsonArray) {
    $counter = 0
    $result = @()
    $jsonArray | ForEach-Object {
        $parsedItem = ParseItem $_ $counter
        $result += $parsedItem
        $counter++
    }
    return $result
}

function ParseJsonString($json) {
    $config = [Newtonsoft.Json.Linq.JObject]::Parse($json)
    return ParseJsonObject($config)
}

function ParseJsonFile($fileName) {
    $json = (Get-Content $FileName | Out-String)
    return ParseJsonString $json
}

Function Get-HashKeys {
    Param ( $hash )
    $hash.Keys | % {
        if ($hash.GetType().IsArray) {
            foreach($item in $hash) {
                Get-HashKeys $item
            }
        } else {

            if ($hash[$_].GetType() -ne [String]) {
                Get-HashKeys $hash[$_]
            } else {
                $allKeys[$_] = 1
            }
        }
    }
}


$xamlOutput += $startxaml
$x = ParseJsonFile $fileName
$xamlOutput += $endxaml

$xamlOutput | Out-File -FilePath $outFile

$allKeys = @{}
Get-HashKeys $x

return $x

# Export-ModuleMember ParseJsonFile, ParseJsonString