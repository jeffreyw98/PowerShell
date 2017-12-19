Function Create-WPFWindow {
    Param (
            [hashtable] $windowHash,
            [string] $xamlFileName
          )
    $a = Get-Content $xamlFileName -Raw
    $b = @"
{0}
"@
    [xml]$xaml = $b -f $a

    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    
    $windowHash.Window=[Windows.Markup.XamlReader]::Load( $reader )

    $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | %{
        #Find all of the form types and add them as members to the windowHash
        $windowHash.Add($_.Name,$windowHash.Window.FindName($_.Name) )
    }
}
