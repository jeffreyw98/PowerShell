function Get-ScriptPath {
[CmdletBinding(DefaultParametersetName="Full")]
param (
  [Parameter(ParameterSetName="Path")]
  [switch]$Path,
  [Parameter(ParameterSetName="Name")]
  [switch]$Name,
  [Parameter(ParameterSetName="Basename")]
  [switch]$BaseName,
  [Parameter(ParameterSetName="Full")]
  [switch]$Full
)

#try and get local file path
$scriptname = $MyInvocation.ScriptName
if ($scriptname -eq "") {$scriptName = $psISE.CurrentFile.Fullpath}
if ($scriptname -eq "") {$scriptName="$(get-location)\unnamed.ps1"}
   switch ($PSCmdlet.ParameterSetName) {
       Path {$return = split-path $scriptName -parent}
       Name {$return = split-path $scriptName -leaf}
       Basename {$return = (split-path $scriptName -leaf).split('\')[-1] -replace '\.\w+$'}
       Full {$Return = $scriptName}
   }
   $return
}

$here = Get-ScriptPath -path

invoke-pester -CodeCoverage  (dir $here\..\functions|select -exp fullname)