# The calling script has a $location param that can be "work" (the default) or "home"
if ($HOME -eq "C:\Users\Jeff Waugh") {
    $location = "home"
} else {
    $location = "work"
}
if ($location -eq "home") {
    $servers = @{ 
        "Server1" = @{"dir" = "Z:\root\mnt\C\Users\Jeff\Documents\Powershell\work"; "mailto" = "jwaugh@griddlecat.com"; "env" = "prod"}
        "Server2" = @{"dir" = "Z:\root\mnt\C\Users\Jeff\Documents\Powershell\work"; "mailto" = "jwaugh@griddlecat.com"; "env" = "prod"}
    }
} else {
    $servers = @{
        "fcvas2667" = @{"dir" = "data$"; "mailto" = "jwaugh@ford.com"; "env" = "prod"}
        "fcvas2668" = @{"dir" = "data$"; "mailto" = "jwaugh@ford.com"; "env" = "prod"}
        "edcas416" = @{"dir" = "Attunity"; "mailto" = "jwaugh@ford.com"; "env" = "prod"}
        "edcas417" = @{"dir" = "Attunity"; "mailto" = "jwaugh@ford.com"; "env" = "prod"}
        "edcas418" = @{"dir" = "Attunity"; "mailto" = "jwaugh@ford.com"; "env" = "prod"}
        "edcas419" = @{"dir" = "Attunity"; "mailto" = "jwaugh@ford.com"; "env" = "prod"}
        "edcas420" = @{"dir" = "Attunity"; "mailto" = "jwaugh@ford.com"; "env" = "prod"}
        "edcas421" = @{"dir" = "Attunity"; "mailto" = "jwaugh@ford.com"; "env" = "prod"}
        "eccvas2989" = @{"dir" = "Attunity"; "mailto" = "jwaugh@ford.com"; "env" = "dev"}
        "eccvas2987" = @{"dir" = "Attunity"; "mailto" = "jwaugh@ford.com"; "env" = "qa"}
        "eccvas2988" = @{"dir" = "Attunity"; "mailto" = "jwaugh@ford.com"; "env" = "dev"}
        "eccvas2557" = @{"dir" = "data$"; "mailto" = "jwaugh@ford.com"; "env" = "qa"}
    }
}



