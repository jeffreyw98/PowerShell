#Query and Modify Operations
$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_WS'
$proxy = New-WebServiceProxy -Uri $uri -ErrorAction stop #-Namespace ITSM -Verbose true 
$proxy|gm|where membertype -eq method|where name -notmatch "Abort|CancelAsync|CreateObjRef|Discover|Dispose|Equals|GetHashCode|GetType|ToString"|select name 
#GetLifetimeService             
#HelpDesk_Modify_Service        
#HelpDesk_QueryList_Service     
#HelpDesk_Query_Service         
Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Modify_Service
Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_QueryList_Service
Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Query_Service 

#Query and Modify Operations 
$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_Create_WS'
$proxy = New-WebServiceProxy -Uri $uri -ErrorAction stop #-Namespace ITSM -Verbose true 
#$proxy|gm|where membertype -eq method|where name -notmatch "Abort|CancelAsync|CreateObjRef|Discover|Dispose|Equals|GetHashCode|GetType|ToString"|select name 
$HelpDesk_Submit_Service = Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Submit_Service 
$HelpDesk_Submit_Service

#Query and Modify Operations for NIRD
$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_Create_NIRD'
$proxy = New-WebServiceProxy -Uri $uri -ErrorAction stop #-Namespace ITSM -Verbose true 
#$proxy|gm|where membertype -eq method|where name -notmatch "Abort|CancelAsync|CreateObjRef|Discover|Dispose|Equals|GetHashCode|GetType|ToString"|select name 
$NIRD = Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Submit_Service

#compare nird and standard
compare   ($HelpDesk_Submit_Service|gm)  ($Nird|gm)


$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_IncidentInterface_Create_WS'
$proxy = New-WebServiceProxy -Uri $uri -ErrorAction stop #-Namespace ITSM -Verbose true 
$proxy|gm|where membertype -eq method|where name -notmatch "Abort|CancelAsync|CreateObjRef|Discover|Dispose|Equals|GetHashCode|GetType|ToString"|select name 
Get-ProxyMethodFields -proxy $proxy -Method HelpDesk_Submit_Service
#HelpDesk_Submit_Service 


$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/Ford_Worklog_update'
$proxy = New-WebServiceProxy -Uri $uri -ErrorAction stop #-Namespace ITSM -Verbose true 
#$proxy|gm|where membertype -eq method|where name -notmatch "Abort|CancelAsync|CreateObjRef|Discover|Dispose|Equals|GetHashCode|GetType|ToString"|select name 
Get-ProxyMethodFields -proxy $proxy -Method OpSet


#HPD_update
$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/HPD_update'
$proxy = New-WebServiceProxy -Uri $uri -ErrorAction stop #-Namespace ITSM -Verbose true 
#$proxy|gm|where membertype -eq method|where name -notmatch "Abort|CancelAsync|CreateObjRef|Discover|Dispose|Equals|GetHashCode|GetType|ToString"|select name 
Get-ProxyMethodFields -proxy $proxy -Method OpSet

#FORD_HPD_WorkInfo
$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/FORD_HPD_WorkInfo'
$proxy = New-WebServiceProxy -Uri $uri -ErrorAction stop #-Namespace ITSM -Verbose true 
#$proxy|gm|where membertype -eq method|where name -notmatch "Abort|CancelAsync|CreateObjRef|Discover|Dispose|Equals|GetHashCode|GetType|ToString"|select name 
Get-ProxyMethodFields -proxy $proxy -Method OpGet

#Group
$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/Group'
$proxy = New-WebServiceProxy -Uri $uri -ErrorAction stop #-Namespace ITSM -Verbose true 
$proxy|gm|where membertype -eq method|where name -notmatch "Abort|CancelAsync|CreateObjRef|Discover|Dispose|Equals|GetHashCode|GetType|ToString"|select name 
Get-ProxyMethodFields -proxy $proxy -Method OpGet
Get-ProxyMethodFields -proxy $proxy -Method OpGetList






#not working at all

#$URI  = 'http://www.itsmsauto.ford.com/arsys/WSDL/public/itsmsapp.ford.com/CHG_ChangeInterface_WS'
#$proxy = New-WebServiceProxy -Uri $uri -ErrorAction stop #-Namespace ITSM -Verbose true 
#$proxy|gm|where membertype -eq method|where name -notmatch "Abort|CancelAsync|CreateObjRef|Discover|Dispose|Equals|GetHashCode|GetType|ToString"|select name 