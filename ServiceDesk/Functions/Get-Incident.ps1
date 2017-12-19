<#
    .SYNOPSIS
     V.1.0
     Get-Incident.ps1: Connects to BMC to grab an incident by number
     
    .DESCRIPTION
     Get-Incident uses SOAP to connect to BMC webservice to query HelpDesk_QueryList_Service
    
    .NOTES
     NAME: Get-Incident
     AUTHOR: Aeron Baker (abaker9@ford.com)
     REQUIREMENTS: - Powershell 3.0
                   - WSDL file or URL

     CHANGE LOG: 
         1.00 4/11/2015: 
    	    - First Release
    
    .PARAMETER URI
        Location of WSDL
        
        For example:
            file://BMCQuery.wsdl
            http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_WS

    .PARAMETER User
        Default credential asks for BMC user name.
    
    .PARAMETER Password
        Default credential asks for BMC password.

    .PARAMETER Credential
        Specifies a user account that has permission to perform this action. Useful when running script unattended.

    .PARAMETER MaxResults
        Maximum number of tickets to return.

    .EXAMPLE
        get-incident INC000016048372 -cred $cred -verbose
        Returns details about incident ticket 

    .EXAMPLE
        get-incident INC000014720164 -cred (Import-Clixml .\cred.xml)
         Returns details about incident ticket using credentials saved to xml file
    
    .EXAMPLE
        ("INC000014720164","INC000014769105") | get-incident
         Returns details about 2 incident tickets

  #>
Function Get-Incident {
[CmdletBinding(DefaultParameterSetName="Manual")] 
param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
        [Alias('Ticket','Incident','Incident_Number')]    
        [PSObject]$InputObject,
        [Parameter(Mandatory=$true, ParameterSetName='Auto')]
        [PSCredential]$Credential,
        [String]$URI="file://$modulepath\files\HPD_IncidentInterface_WS.wsdl",
        [int]$MaxResults = 100
    )

Begin{

    $proxy = New-AuthenticatedWebServiceProxy -credential $credential -URI $URI -Maxtries 2

    $filter = "'Incident Number' = `"{0}`""
    #$InputObject = "INC000014769740", "INC000014769740"
    $criteria = @()
}

Process{
    #if more than one incident number is specified, lets build an array to query them all at once
    ForEach ($item in $InputObject){
        #write-verbose "Looking up $item.."
        $criteria += [string]::Format($filter,$item)
    }       
}
 
End{
   $criteria_string = $criteria -join " or "
   write-verbose $criteria_string
   write-output $proxy.HelpDesk_QueryList_Service($criteria_string,0,$MaxResults)
   
}  
}
