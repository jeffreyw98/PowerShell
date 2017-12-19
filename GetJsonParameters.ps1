# ==========================================================================================
# # This script takes a Json file and creates a .csv file of list of tables in json.
# ==========================================================================================

#========= Path where original jsons are available =========================================

#$JSONsPath = 'X:\logs\LatestJsons\'
$JSONsPath = 'Z:\root\mnt\C\Users\Jeff\Documents\Powershell\work\logs\LatestJsons\'

#========= Result path where parameters list csv file will be written ====================================

#$ResultPath= "C:\Users\LPALAKO1\Desktop\resluts.csv"
$ResultPath = "z:\root\mnt\C\Temp\results.csv"

#Remove-Item $ResultPath
If (Test-Path $ResultPath){
	Remove-Item $ResultPath
}
#$Results =(Get-Content file.json -Raw | ConvertFrom-Json) | Select id,itemName,sellerId | Convertto-CSV -NoTypeInformation
$Results =Get-ChildItem -Path $JSONsPath*.json  |  Select-String -Pattern '"source_name"|"server"|"accessAlternateDirectly"|"emptyStringValue"|"username"|"sourceName"|"Timeout"|"EventWait"|"cdcBatchSize"|"bulkBatchSize"|"addSupplementalLogging"|"useLogminerReader"|"retryInterval"|"archivedLogDestId"|"useWindowsAuthentication"|"activateSafeguard"|"safeguardFrequency"|"use3rdPartyBackupDevice"|"target_names"|"authenticationType"|"useHDFSHA"|"webHDFSHost"|"krbKDCType"|"krbRealm"|"krbPrincipal"|"krbKeyTabFile"|"webHDFSHost"|"webHDFSPort"|"hdfsPath"|"hiveAccess"|"hiveODBCHost"|"hiveODBCPort"|"hiveJobAdditionalProperties"|"useHDFSHA"|"webHDFSHost2"|"fileFormat"|"serdeName"|"serdeProperties"|"csvDelimiter"|"maxFileSize"|"compressionType"|"writeBufferSize"|"cdcMinFileSize"|"cdcBatchTimeOut"|"lob_max_size"|"full_load_sub_tasks"|"full_load_enabled"|"handle_ddl"|"start_table_behaviour"|"save_changes_enabled"|"batch_apply_enabled"|"header_columns_settings"|"recovery_table_settings"|"safeguardPolicy"'
$LastTaskName="TaskName"
$source_name="source_name"
$server="server"
$accessAlternateDirectly="accessAlternateDirectly"
$emptyStringValue="emptyStringValue"
$username="username"
$sourceName="sourceName"
$Timeout="Timeout"
$EventWait="EventWait"
$cdcBatchSize="cdcBatchSize"
$bulkBatchSize="bulkBatchSize"
$addSupplementalLogging="addSupplementalLogging"
$useLogminerReader="useLogminerReader"
$retryInterval="retryInterval"
$archivedLogDestId="archivedLogDestId"
$useWindowsAuthentication="useWindowsAuthentication"
$activateSafeguard="activateSafeguard"
$safeguardFrequency="safeguardFrequency"
$use3rdPartyBackupDevice="use3rdPartyBackupDevice"
$target_names="target_names"
$authenticationType="authenticationType"
$useHDFSHA="useHDFSHA"
$webHDFSHost="webHDFSHost"
$krbKDCType="krbKDCType"
$krbRealm="krbRealm"
$krbPrincipal="krbPrincipal"
$krbKeyTabFile="krbKeyTabFile"
$webHDFSHost="webHDFSHost"
$webHDFSPort="webHDFSPort"
$hdfsPath="hdfsPath"
$hiveAccess="hiveAccess"
$hiveODBCHost="hiveODBCHost"
$hiveODBCPort="hiveODBCPort"
$hiveJobAdditionalProperties="hiveJobAdditionalProperties"
$useHDFSHA="useHDFSHA"
$webHDFSHost2="webHDFSHost2"
$fileFormat="fileFormat"
$serdeName="serdeName"
$serdeProperties="serdeProperties"
$csvDelimiter="csvDelimiter"
$maxFileSize="maxFileSize"
$compressionType="compressionType"
$writeBufferSize="writeBufferSize"
$cdcMinFileSize="cdcMinFileSize"
$cdcBatchTimeOut="cdcBatchTimeOut"
$lob_max_size="lob_max_size"
$full_load_sub_tasks="full_load_sub_tasks"
$full_load_enabled="full_load_enabled"
$handle_ddl="handle_ddl"
$start_table_behaviour="start_table_behaviour"
$save_changes_enabled="save_changes_enabled"
$batch_apply_enabled="batch_apply_enabled"
$header_columns_settings="header_columns_settings"
$recovery_table_settings="recovery_table_settings"
$safeguardPolicy="safeguardPolicy"

ForEach ($Line in $Results)
    {
        $TaskName=$Line.Filename.Replace(".json","")
        #$TaskName=$Line.ToString().Replace($Path,"").Split(".json")[0]
        if ($LastTaskName -ne $TaskName)
        {
         $OutputLine = 
        $LastTaskName + "," +
        $source_name + "," +
		$server + "," +
		$accessAlternateDirectly + "," +
		$emptyStringValue + "," +
		$username + "," +
		$sourceName + "," +
		$Timeout + "," +
		$EventWait + "," +
		$cdcBatchSize + "," +
		$bulkBatchSize + "," +
		$addSupplementalLogging + "," +
		$useLogminerReader + "," +
		$retryInterval + "," +
		$archivedLogDestId + "," +
		$useWindowsAuthentication + "," +
		$activateSafeguard + "," +
		$safeguardFrequency + "," +
		$use3rdPartyBackupDevice + "," +
		$target_names + "," +
		$authenticationType + "," +
		$useHDFSHA + "," +
		$webHDFSHost + "," +
		$krbKDCType + "," +
		$krbRealm + "," +
		$krbPrincipal + "," +
		$krbKeyTabFile + "," +
		$webHDFSHost + "," +
		$webHDFSPort + "," +
		$hdfsPath + "," +
		$hiveAccess + "," +
		$hiveODBCHost + "," +
		$hiveODBCPort + "," +
		$hiveJobAdditionalProperties + "," +
		$useHDFSHA + "," +
		$webHDFSHost2 + "," +
		$fileFormat + "," +
		$serdeName + "," +
		$serdeProperties + "," +
		$csvDelimiter + "," +
		$maxFileSize + "," +
		$compressionType + "," +
		$writeBufferSize + "," +
		$cdcMinFileSize + "," +
		$cdcBatchTimeOut + "," +
		$lob_max_size + "," +
		$full_load_sub_tasks + "," +
		$full_load_enabled + "," +
		$handle_ddl + "," +
		$start_table_behaviour + "," +
		$save_changes_enabled + "," +
		$batch_apply_enabled + "," +
		$header_columns_settings + "," +
		$recovery_table_settings + "," +
		$safeguardPolicy

		
        Add-Content $ResultPath $OutputLine

        $LastTaskName=$TaskName
        $source_name=
		$server=
		$accessAlternateDirectly=
		$emptyStringValue=
		$username=
		$sourceName=
		$Timeout=
		$EventWait=
		$cdcBatchSize=
		$bulkBatchSize=
		$addSupplementalLogging=
		$useLogminerReader=
		$retryInterval=
		$archivedLogDestId=
		$useWindowsAuthentication=
		$activateSafeguard=
		$safeguardFrequency=
		$use3rdPartyBackupDevice=
		$target_names=
		$authenticationType=
		$useHDFSHA=
		$webHDFSHost=
		$krbKDCType=
		$krbRealm=
		$krbPrincipal=
		$krbKeyTabFile=
		$webHDFSHost=
		$webHDFSPort=
		$hdfsPath=
		$hiveAccess=
		$hiveODBCHost=
		$hiveODBCPort=
		$hiveJobAdditionalProperties=
		$useHDFSHA=
		$webHDFSHost2=
		$fileFormat=
		$serdeName=
		$serdeProperties=
		$csvDelimiter=
		$maxFileSize=
		$compressionType=
		$writeBufferSize=
		$cdcMinFileSize=
		$cdcBatchTimeOut=
		$lob_max_size=
		$full_load_sub_tasks=
		$full_load_enabled=
		$handle_ddl=
		$start_table_behaviour=
		$save_changes_enabled=
		$batch_apply_enabled=
		$header_columns_settings=
		$recovery_table_settings=
		$safeguardPolicy=
        ""
        }

        $Title=$Line.ToString().split('"')[1]
        $Value=$Line.ToString().replace('":','~').split("~")[1].Split(",")[0].Replace('"','').Trim()
        #$TaskName + "," + $Title + "," + $Value
        switch($Title)
            {
            "source_name" {$source_name=$Value}
			"server" {$server=$Value}
			"accessAlternateDirectly" {$accessAlternateDirectly=$Value}
			"emptyStringValue" {$emptyStringValue=$Value}
			"username" {$username=$Value}
			"sourceName" {$sourceName=$Value}
			"Timeout" {$Timeout=$Value}
			"EventWait" {$EventWait=$Value}
			"cdcBatchSize" {$cdcBatchSize=$Value}
			"bulkBatchSize" {$bulkBatchSize=$Value}
			"addSupplementalLogging" {$addSupplementalLogging=$Value}
			"useLogminerReader" {$useLogminerReader=$Value}
			"retryInterval" {$retryInterval=$Value}
			"archivedLogDestId" {$archivedLogDestId=$Value}
			"useWindowsAuthentication" {$useWindowsAuthentication=$Value}
			"activateSafeguard" {$activateSafeguard=$Value}
			"safeguardFrequency" {$safeguardFrequency=$Value}
			"use3rdPartyBackupDevice" {$use3rdPartyBackupDevice=$Value}
			"target_names" {$target_names=$Value}
			"authenticationType" {$authenticationType=$Value}
			"useHDFSHA" {$useHDFSHA=$Value}
			"webHDFSHost" {$webHDFSHost=$Value}
			"krbKDCType" {$krbKDCType=$Value}
			"krbRealm" {$krbRealm=$Value}
			"krbPrincipal" {$krbPrincipal=$Value}
			"krbKeyTabFile" {$krbKeyTabFile=$Value}
			"webHDFSHost" {$webHDFSHost=$Value}
			"webHDFSPort" {$webHDFSPort=$Value}
			"hdfsPath" {$hdfsPath=$Value}
			"hiveAccess" {$hiveAccess=$Value}
			"hiveODBCHost" {$hiveODBCHost=$Value}
			"hiveODBCPort" {$hiveODBCPort=$Value}
			"hiveJobAdditionalProperties" {$hiveJobAdditionalProperties=$Value}
			"useHDFSHA" {$useHDFSHA=$Value}
			"webHDFSHost2" {$webHDFSHost2=$Value}
			"fileFormat" {$fileFormat=$Value}
			"serdeName" {$serdeName=$Value}
			"serdeProperties" {$serdeProperties=$Value}
			"csvDelimiter" {$csvDelimiter=$Value}
			"maxFileSize" {$maxFileSize=$Value}
			"compressionType" {$compressionType=$Value}
			"writeBufferSize" {$writeBufferSize=$Value}
			"cdcMinFileSize" {$cdcMinFileSize=$Value}
			"cdcBatchTimeOut" {$cdcBatchTimeOut=$Value}
			"lob_max_size" {$lob_max_size=$Value}
			"full_load_sub_tasks" {$full_load_sub_tasks=$Value}
			"full_load_enabled" {$full_load_enabled=$Value}
			"handle_ddl" {$handle_ddl=$Value}
			"start_table_behaviour" {$start_table_behaviour=$Value}
			"save_changes_enabled" {$save_changes_enabled=$Value}
			"batch_apply_enabled" {$batch_apply_enabled=$Value}
			"header_columns_settings" {$header_columns_settings=$Value}
			"recovery_table_settings" {$recovery_table_settings=$Value}
			"safeguardPolicy" {$safeguardPolicy=$Value}
            }

    }
        $OutputLine = 
        $LastTaskName + "," +
        $source_name + "," +
		$server + "," +
		$accessAlternateDirectly + "," +
		$emptyStringValue + "," +
		$username + "," +
		$sourceName + "," +
		$Timeout + "," +
		$EventWait + "," +
		$cdcBatchSize + "," +
		$bulkBatchSize + "," +
		$addSupplementalLogging + "," +
		$useLogminerReader + "," +
		$retryInterval + "," +
		$archivedLogDestId + "," +
		$useWindowsAuthentication + "," +
		$activateSafeguard + "," +
		$safeguardFrequency + "," +
		$use3rdPartyBackupDevice + "," +
		$target_names + "," +
		$authenticationType + "," +
		$useHDFSHA + "," +
		$webHDFSHost + "," +
		$krbKDCType + "," +
		$krbRealm + "," +
		$krbPrincipal + "," +
		$krbKeyTabFile + "," +
		$webHDFSHost + "," +
		$webHDFSPort + "," +
		$hdfsPath + "," +
		$hiveAccess + "," +
		$hiveODBCHost + "," +
		$hiveODBCPort + "," +
		$hiveJobAdditionalProperties + "," +
		$useHDFSHA + "," +
		$webHDFSHost2 + "," +
		$fileFormat + "," +
		$serdeName + "," +
		$serdeProperties + "," +
		$csvDelimiter + "," +
		$maxFileSize + "," +
		$compressionType + "," +
		$writeBufferSize + "," +
		$cdcMinFileSize + "," +
		$cdcBatchTimeOut + "," +
		$lob_max_size + "," +
		$full_load_sub_tasks + "," +
		$full_load_enabled + "," +
		$handle_ddl + "," +
		$start_table_behaviour + "," +
		$save_changes_enabled + "," +
		$batch_apply_enabled + "," +
		$header_columns_settings + "," +
		$recovery_table_settings + "," +
		$safeguardPolicy

        Add-Content $ResultPath $OutputLine


type $ResultPath
