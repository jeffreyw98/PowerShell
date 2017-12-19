Cls
# ==========================================================================================
# # This script takes a Json file and creates a .csv file of list of tables in json.
# ==========================================================================================

#========= Path where original jsons are available =========================================

$JSONsPath ="C:\Users\LPALAKO1\Desktop\Test_Jsons\"

#========= Temporary path where modified Jsons after removing first Line will be written====

$TmpJSONsPath="C:\Users\LPALAKO1\Desktop\Test_Jsons\Temp\"

#========= Task name without .json =========================================================

$TaskName="SERVIS2_SV2CHPR_SV2CHPR_T1"

#========= Result path where Table list will be written ====================================

$ResultPath= "C:\Users\LPALAKO1\Desktop\Test_Jsons\$TaskName TableList.csv"

#========= Removing First Line in json (Host Name) =========================================

$RemoveHeader = Get-Content "$JSONsPath\$TaskName.json"|Select-Object -Skip 1|Set-Content "$TmpJSONsPath\$TaskName.json"

#========= Reading Content from Json file and getting tables liit and writing to csv file ==

$GetTmpJsonContent= Get-Content "$TmpJSONsPath\$TaskName.json"| Out-String | ConvertFrom-Json

Write-Output $GetTmpJsonContent."cmd.replication_definition".tasks.source.source_tables.explicit_included_tables.name|Set-Content "$ResultPath"