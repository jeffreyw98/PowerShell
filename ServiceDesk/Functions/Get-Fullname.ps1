<#
.Synopsis
   uses a cn to find a user's full name
.DESCRIPTION
   uses a cn to find a user's full name
.EXAMPLE
   Get-Fullname abaker9
.EXAMPLE
      Get-Fullname abaker9,wcoyle
.EXAMPLE
    "abaker9","wcoyle"|  Get-Fullname 
#>
Function Get-Fullname{
param(
[Parameter(Mandatory=$false,
            ValueFromPipelineByPropertyName=$true,
            ValueFromPipeline=$true,
            Position=0)]
[string[]]$SamAccountName=$env:USERNAME
)
    begin{}
    process{
        foreach ($item in $SamAccountName){
            $user = (find-adsiobject -SearchString $item -sAMAccountType user -PropertiesToLoad sn,givenname,initials|select -ExpandProperty properties)
            write-output "$($user.givenname[0]) $($user.initials[0]) $($user.sn[0])"  
        }

    }
    end{}
}
