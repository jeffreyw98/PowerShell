$modulepath = $psScriptRoot
dir $ModulePath\functions *.ps1 | %{
    . $_.FullName
}

