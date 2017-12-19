# get Attunity servers\path into $servers hash
$location = "work"

. "$HOME\Documents\Powershell\AttunityServers.ps1"

Function New-SuspiciousTask ($path, $task, $laType, $laTime, $diff, $line) {
    $SuspiciousTask = New-Object -TypeName PSObject
    $SuspiciousTask | Add-Member -MemberType NoteProperty -Name "Server" -Value $path -PassThru |
    Add-Member -MemberType NoteProperty -Name "Task" -Value $task -PassThru |
    Add-Member -MemberType NoteProperty -Name "LAType" -Value $laType -PassThru | 
    Add-Member -MemberType NoteProperty -Name "LATime" -Value $laTime -PassThru |
    Add-Member -MemberType NoteProperty -Name "Diff" -Value $diff -PassThru |
    Add-Member -MemberType NoteProperty -Name "LALine" -Value $line
    $SuspiciousTask
}

$format = @{Expression={$_."Server"};Label="Server";width=10}, `
@{Expression={$_.Task};Label="Task                ";width=20}, `
@{Expression={$_."LATime"};Label="Time       ";width=11}, `
@{Expression={$_."Diff"};Label="Minutes";width=9}, `
@{Expression={$_."LALine"};Label="Last Activity Line";width=100}

$LogPaths = @()
foreach ($server in $servers.GetEnumerator() | where {$_.value.env -eq "prod"} | sort -Property Name) {
    $LogPaths += "\\" + $($server.Name) + "\" + $($servers.Item($server.Name).Item("dir")) + "\logs\" 
}

$LastActityThresholdInMinutes = 30
$LastActityThresholdInMinutesT2 = 1440

###########################################################

$ResultToFile = "C:\temp\ReplicateProd_"+"{0:yyyy}{0:MM}{0:dd}_{0:hh}{0:mm}" -f (get-date)+'.csv'

If (Test-Path $ResultToFile){
	Remove-Item $ResultToFile
}

Get-Date
"Started analysis"

##Create an Array of Suspicious Tasks 
$SuspiciousTasks = @()
$PI = 0
$ScannedI = 0
$WarningsI = 0
ForEach ($LogPath in $LogPaths)
{
    write-eventlog -Logname Application -Source "TaskErrors.ps1" -EntryType Information -EventId 1 -Message "Beginning $($server.Name)"

    Get-Date
    $PI += 1
    "Going over path " + $LogPath
    $LogFilesPatern = $LogPath + "reptask_*.log"
    <#
    #The following command has been replaced due to performance issues:
    $Files  = Get-ChildItem -Path $LogFilesPatern -Name -Exclude *__*.*
    #>
    #Getting the list of file names on the folder
    $command = 'cmd.exe /C dir /b ' + $LogFilesPatern
    Try
        {
        $ErrorActionPreference = "Stop"; #Make all errors terminating
        $Files = (Invoke-Expression -Command:$command |Select-String -pattern "__" -NotMatch |Select-Object -Property Line)
        $NumberOfFiles = $Files.Count
        "Start running over " + $Files.Count + " on the folder"
        $I = 0
        ForEach ($FileNameX in $Files)
        {
            $FileName = $FileNameX.Line
            $I +=1
            $ScannedI += 1
            [Int]$PctI = 100 * $I / ($NumberOfFiles+1)/$LogPaths.Count+($PI-1)*(100/$LogPaths.Count)
            Write-Progress -Activity "Search on $LogPath$FileName is in Progress" -Status "$ScannedI Scanned ($PctI% Completed) $WarningsI warnings" -PercentComplete $PctI;
            $TaskName = $FileName.Replace("reptask_","").Replace(".log","")
            $CompleteFileName = $LogPath + $FileName
            $TaskFileName = $LogPath.Replace("logs", "tasks") + $TaskName
            # only read log files that belong to an active task
            if (Test-Path $TaskFileName) {
                <#
                #The following command has been disabled since it might lock a file 
                $LastRow = Get-Content $CompleteFileName | Select-Object -Last 1
                #>
                #<#
                Try
                {
                    $Stream = (Get-item $CompleteFileName).Open([System.IO.FileMode]::Open, 
                                       [System.IO.FileAccess]::Read, 
                                       [System.IO.FileShare]::ReadWrite)
                    $reader = "" #Have to clear reader to prevent residual from previous iteration
                    $reader = New-Object System.IO.StreamReader($Stream) 
                    #Retrieving last 1000 characters of the file (or the entire file if it's smaller)
                    $FileSize = $Stream.length
                    $ChunckSize = [Math]::Min($Stream.length,10000)
                    $Cursor = $reader.BaseStream.seek((-($ChunckSize)) ,[System.IO.SeekOrigin]::End) 
                    $LastRow = $reader.ReadToEnd().Trim()
                    $LastRow = $LastRow -replace ("(\n\D)", "~NewLine~") #Removing false New Lines (Lines that dont start with thread number)
                    $LastRow = $LastRow.Split("`n")[$LastRow.Split("`n").Count-1] #Last character is always `n (New line) --> Need to take LastLineNum-1
                }
                Catch
                {
                    Write-Error "Unable to read the file"
                }
                Finally
                {
                    $Stream.Close() 
                    $reader.Close() 
                }

                #Analyzing the last row in the file
                Try
                { 
                    $LastActivityTime = $LastRow.Substring(10,19).Replace("T", " ")
                    If ($LastActivityTime -match "201*")
                    {
                        $Now = Get-Date
                        [int]$MinutesSinceLastActivity = ($Now - [DateTime]$LastActivityTime).TotalMinutes
                        IF ($FileName.Replace("reptask_","").Replace(".log","") -Like "*T2"){$Threshold = $LastActityThresholdInMinutesT2}
                        Else {$Threshold = $LastActityThresholdInMinutes}
                
                        If ($MinutesSinceLastActivity -gt $Threshold)
                        {
                            Write-Warning "Something is wrong!!"
                            $WarningsI +=1
                            $LastActivityDetected = $LastRow.Split("]")[0].Split("[")[1].trimEnd(" ")
                            $SuspiciousTasks += New-SuspiciousTask $logpath.Replace("\", "").replace("data`$logs", "").replace("Attunitylogs","") $FileName.Replace("reptask_","").Replace(".log","") $LastActivityDetected $LastActivityTime $MinutesSinceLastActivity $LastRow
                        }
                    }
                    else
                    {
                        Write-Warning "Last activity unclear"
                        Write-Warning $LastRow
                        $suspiciousTasks += $logpath.Replace("\", "").replace("data`$logs", "").replace("Attunitylogs","") +','+$FileName.Replace("reptask_","").Replace(".log","") + ',WARNING - Last activity unclear, , ,"Warning - Last activity is unclear;  Please check the file manually!!"'
                    }
                }
                Catch
                {
                    $ErrorMessage = $_.Exception.Message
                    Write-Warning "Failed to analyze the file!!!"
                    Write-Warning $ErrorMessage
                    $LastRow
                    $suspiciousTasks += $LogPath+','+$FileName.Replace("reptask_","").Replace(".log","") + ',"ERROR-Failed to analyze the task", , ,"ERROR-Failed to analyze the task; Please check the file manually!!"'
                }
            }
        }
    }
    Catch
        {
        Write-Warning "Unable to locate tasks in folder!!"
        $suspiciousTasks += $LogPath+',"WARNING","WARNING - No tasks found on the folder", , ,"Unable to locate tasks in folder; Please read the folder manually!"'
        }
    write-eventlog -Logname Application -Source "TaskErrors.ps1" -EntryType Information -EventId 1 -Message "Finished $($server.Name)"

    }

$body = $SuspiciousTasks | sort-object -Property "LATime" -Descending | ft -Wrap $format 

$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
if ($debug) {
    if ($location -eq "home") {
        $Mail.To = "jwaugh@griddlecat.com"
    } else {
        $Mail.To = "jwaugh@ford.com"
    }
} else {
#    $Mail.To = $servers.Item($server.Name).Item("mailto")
    $Mail.To = "jwaugh@ford.com"
}
$Mail.Subject = "Last Log Activity Report "
$body | out-file "c:\temp\tail.txt"
$a = $null
get-content -raw "c:\temp\Tail.txt" | foreach {
    $a = "$a" + [string]"$_" + "`n"
} 
$Mail.BodyFormat = 2
$Mail.HTMLBody = "<pre><font face='Lucida Sans Typewriter' style=`"font-size:9pt`">$a</font></pre>"
$Mail.Send()

Get-Date
#Invoke-Expression $ResultToFile
