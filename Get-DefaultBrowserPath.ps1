Function Get-DefaultBrowserPath {
    #Get the default Browser path
    New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root | Out-Null
    (Get-ItemProperty ‘HKCR:\http\shell\open\command’).'(default)’.Split(‘”‘)[1]
}
# this does not quite work. I was able to get a string into $b using this command and then 
# $a = Get-ItemProperty hkcr:\http\shell\open\command
# $a is a PSCustomObject then
# $b = $a.'(default)'.Split('"')[1] then
# $a = '"' + $b + '"' and then 
# Invoke-Expression "&$a" opened IE
