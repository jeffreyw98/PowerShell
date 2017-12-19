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

$verbose = $true
$ModuleName = (Split-Path -Leaf (Get-ScriptPath)) -replace '\.Tests\.ps1', ''
$here = Get-ScriptPath -path


#prompt for credentials if needed
if(-not $cred){$cred = get-credential}

import-module $modulename -force

Describe "$modulename Module" -Tags Module{
    $commands = @(get-command -commandtype Function -module $modulename |select -expandproperty name)
    #$CommandTestCase = @($commands|%{@{Command = $_}})

    Context 'Module Tests'{
        It "$ModuleName should have helpfile"{
            dir $here\..\en-US\about*.txt|should exist
        }
    }    
    Context 'Functions all load'{
        dir $here\..\functions *.ps1|%{
           $command = $_.Name -replace '\.ps1$',''
           It "should load $command" {
               $CommandExists = $commands -contains $command
               $CommandExists |should be $true
           }            
        }
    }
    Context 'Functions have examples'{
        foreach ($command in $commands){
          It "$command should have examples" {
            $result = get-help $command -Examples
            $examples = @($result.examples|select -exp example)
            $examples.count |should BeGreaterThan 0
          }    
        }
    }
}

Describe "Find-Incident" -Tags Unit{
    Context 'functionality'{
        It "should find 2 incidents"{
            $results = Find-Incident -credential $cred -Assigned_Group 'The Americas Windows Server Operations' -MaxResults 2
            $results.count|should be 2
        }
        It "should work using all parameters for an Assignee"{
            $results = Find-Incident -credential $cred  -Assignee 'Aeron L. Baker' -Assigned -Closed -Cancelled -Resolved -Pending -MaxResults 2
            $results.count|should be 2
        }
    }
}

Describe "Get-Incident" -Tags Unit{
    Context 'functionality'{
        It "should return 2 incidents"{
            $results = Get-Incident INC000016048372,INC000016051864 -credential $cred 
            $results.count | should Be 2
        }
    }
}

Describe "Get-IncidentWorkLog" -Tags Unit{
    Context 'functionality'{
        It "should retrieve incident"{
            $results = Get-IncidentWorkLog INC000016048372 -credential $cred
            $results.Incident_Number|should be 'INC000016048372'
        }
    }
}

Describe "New-IncidentWorkLog" -Tags Unit,whatif{
    Context 'functionality'{
        It "should create incident"{
            $results = New-IncidentWorklog -credential $cred -Incident_Number INC000016048372 -WhatIf -Work_Info_Notes 'testing'
            $results.Incident_Number|should be 'INC000016048372'
            $results.Work_Info_Notes|should be 'testing'
        }
    }
}

Describe "Get-ProxyMethodFields" -Tags Unit{
    Context 'requirements'{
        It "should have access to file"{
            dir "$here\..\files\HPD_IncidentInterface_WS.wsdl"|should exist
        }
    }
    Context 'HPD_IncidentInterface_WS.wsdl'{
        It "should contain HelpDesk_Query_Service"{
            $proxy = New-WebServiceProxy -Uri "$here\..\files\HPD_IncidentInterface_WS.wsdl"
            $results = Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Query_Service
            ($results|gm|where name -eq 'Incident_Number').count|should be 1

        }
        It "should contain HelpDesk_Modify_Service"{
            $proxy = New-WebServiceProxy -Uri "$here\..\files\HPD_IncidentInterface_WS.wsdl"
            $results = Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Modify_Service
            ($results|gm).count|should begreaterthan 25
        }
    }
   Context 'requirements'{
       It "should have access to file"{
            dir "$here\..\files\FORD_HPD_WorkInfo.wsdl"|should exist
        }
    }
   Context 'HFORD_HPD_WorkInfo.wsdl'{   
       It "should contain OpGet"{
           $proxy = New-WebServiceProxy -Uri "$here\..\files\FORD_HPD_WorkInfo.wsdl"
           $results = Get-ProxyMethodFields -proxy $proxy -Method OpGet
           ($results|gm|where name -eq 'Incident_Number').count|should be 1
       }
   }
   Context 'requirements'{
    It "should have access to file"{
        dir "$here\..\files\HelpDesk_Submit_Service.wsdl"|should exist
    }
   }
   Context 'HelpDesk_Submit_Service.wsdl'{
     It "should contain HelpDesk_Submit_Service"{
         $proxy = New-WebServiceProxy -Uri "$here\..\files\HelpDesk_Submit_Service.wsdl"
         $proxy|gm|where membertype -eq method|where name -notmatch "Abort|CancelAsync|CreateObjRef|Discover|Dispose|Equals|GetHashCode|GetType|ToString"|select name 
         $results = Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Submit_Service
         ($results|get-member).count |should begreaterthan 25
     }

   }
}

Describe "New-Incident " -Tags Unit,whatif{
    Context 'whatif'{
        It "should create a new ticket object"{
            $results = New-Incident -credential $cred -ci_name 'fsilws10' -Summary 'Testing' -Notes 'here are the details' -whatif
            $results.CI_Name|should be 'fsilws10'
            $results.Summary|should be 'Testing'
            $results.Notes|should be 'here are the details'
            $results.Action|should be "CREATE"   
        }
    }
}

Describe "New-AuthenticatedWebServiceProxy" -Tags Unit{
    Context 'requirements'{
        It "should have access to file"{
            dir "$here\..\files\HPD_IncidentInterface_WS.wsdl"|should exist
        }
    }
    Context 'functionality'{
        It "should create proxy object"{
            $proxy = New-AuthenticatedWebServiceProxy -Uri "$here\..\files\HPD_IncidentInterface_WS.wsdl" -credential $cred
            ($proxy -ne $null)|should be $true
        }
    }
}

Describe "Set-Incident" -Tags Unit,whatif{
    Context 'whatif'{
        It "should modify incident"{
           $results = 'INC000016048372'| Set-Incident -credential $cred -Status Resolved -Resolution 'Rebooted server' -Resolution_Category Application_Software_Defect -WhatIf
           $results.Incident_Number|should be 'INC000016048372'
           $results.Action|should be "MODIFY" 
           $results.Resolution|should be "Rebooted server"
           $results.Resolution_Category -replace " ","_"|should be "Application_Software_Defect"
        }
    }
}

Describe "Set-Incident" -Tags Unit,whatif{
    Context 'whatif'{
        It "should modify incident"{
           $results = Set-IncidentAssignment -credential $cred -Incident_Number INC000016048372 -Assignee "Aeron L. Baker" -whatif
           $results.Incident_Number|should be 'INC000016048372'
           $results.Assignee|should be "Aeron L. Baker" 
        }
    }
}

Describe "Get-Fullname" -Tags Unit,whatif{
    Context 'functionality'{
        It "should get a fullname"{
           $results = get-fullname abaker9
           $results |should be "Aeron L. Baker"
        }
    }
}