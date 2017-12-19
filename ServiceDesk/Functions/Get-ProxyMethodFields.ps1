<#
.Synopsis
    Gets a list of fields given a SOAP proxy and Method
.DESCRIPTION
    Gets a list of fields given a SOAP proxy and Method
.EXAMPLE
    Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Modify_Services
.EXAMPLE
    Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Submit_Service
.EXAMPLE
    Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Query_Service
#>
Function Get-ProxyMethodFields{
param(
[Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
$Proxy,
[Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
$Method
)   
    $OverloadDefinitions = $Proxy."$method".OverloadDefinitions

    if (-not ($OverloadDefinitions)){
        write-error "Can't find Method:'$method' in proxy!" -ErrorAction stop
    }

    $s = $OverloadDefinitions -replace '.*\(|\)$',''

    $hash = [ordered]@{}   
    $s -split ', ' | %{
        $a = $_ -split " "
        $name = $a|select -last 1
        $hash.add($name,$null)
        #$Fields | Add-Member Noteproperty $name -Value $null
    }
    write-output ([pscustomobject]$hash)
}