# The calling script has a $location param that can be "work" (the default) or "home"
if ($HOME -eq "C:\Users\Jeff Waugh") {
    $location = "home"
} else {
    $location = "work"
}

$colorRed = "<font color=`"#ff0000`"><B>"
$colorOff = "</B></font>"
$colorOrange = "<font color=`"#ff9966`"<B>"
$colorGreen = "<font color=`"#00e600`"<B>"

<# Function to first delete a drive mapping and then map that drive to \\$server\$path #>
function Map-Drive ($drive, $server, $path) {
    if ($location -eq "work") {
        net use $drive /del /yes
        net use $drive \\$server\$path
    } else {
        subst $drive /D
        subst $drive $path
    }
}
