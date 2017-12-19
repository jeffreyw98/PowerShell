Function Get-ObjectMembers {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PSCustomObject]$obj
    )
    $obj | Get-Member -MemberType NoteProperty | ForEach-Object {
        $key = $_.Name
        [PSCustomObject] @{Key = $key; Value = $obj."$key"}
    }
}
$x = Get-Content -Path C:\Temp\FOCALPTLDS_FLDS_T1.json

# $x = Get-Content -Path \\edcas416\Attunity\logs\LatestJsons\FIS_CAMEP_MAA_T1.json
$json = $x[1..$x.Length] | Out-String 
$json | ConvertFrom-Json | Get-ObjectMembers | foreach {
    $_.Value | Get-ObjectMembers | foreach {
        if ( $($_.Value.GetType().Name) -eq "String")
        {
                $_.Key
        }
         else {
#            $_.Value | Get-ObjectMembers | foreach {

            [PSCustomObject] @{Setting = $_.Value}
        }
        
    }
}

