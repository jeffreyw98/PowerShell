param([switch]$debug, [string]$location = "work")
if ($debug) {
    $drive = "K:"
} else {
    $drive = "U:"
}
$offset = 48

# get Attunity servers\path into $servers hash and common function definitions
. "$HOME\Documents\PowerShell\AttunityServers.ps1"

# get common functions
. "$HOME\Documents\Powershell\AttunityCommon.ps1"

#Load Assemblies
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[System.Windows.Forms.Application]::EnableVisualStyles()
 
Add-Type -AssemblyName System.Windows.Forms

$serverList = New-Object -Typename 'System.Collections.Generic.List[System.String]'
$taskList = New-Object -Typename 'System.Collections.Generic.List[System.String]'
$dirList = New-Object -TypeName 'System.Collections.Generic.List[System.String]'

Function InitializeComponent {
    $tableLayoutPanel1.SuspendLayout()
    $flowLayoutServers.SuspendLayout()
    $flowLayoutTasks.SuspendLayout()
    $panelDBInfo.SuspendLayout();
    $flowLayoutDBInfo.SuspendLayout();
    $panelQuit.SuspendLayout();
    $groupBoxDBInfo.SuspendLayout();
    #([System.ComponentModel.ISupportInitialize]::($txtOffset)).BeginInit();
    $Form.SuspendLayout();
    # 
    # tableLayoutPanel1
    # 
    $tableLayoutPanel1.ColumnCount = 2;
    [void]$tableLayoutPanel1.ColumnStyles.Add($(New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent), 50));
    [void]$tableLayoutPanel1.ColumnStyles.Add($(New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent), 50));
    $tableLayoutPanel1.Controls.Add($Label, 0, 0);
    $tableLayoutPanel1.Controls.Add($flowLayoutServers, 0, 1);
    $tableLayoutPanel1.Controls.Add($flowLayoutTasks, 1, 1);
    $tableLayoutPanel1.Controls.Add($panelDBInfo, 0, 2);
    $tableLayoutPanel1.Controls.Add($flowLayoutDBInfo, 0, 3);
    $tableLayoutPanel1.Dock = [System.Windows.Forms.DockStyle]::Fill;
    $tableLayoutPanel1.Location = New-Object System.Drawing.Point(0, 0);
    $tableLayoutPanel1.Name = "tableLayoutPanel1";
    $tableLayoutPanel1.RowCount = 4;
    [void]$tableLayoutPanel1.RowStyles.Add($(New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent), 8));
    [void]$tableLayoutPanel1.RowStyles.Add($(New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent), 50));
    [void]$tableLayoutPanel1.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent), 32));
    [void]$tableLayoutPanel1.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent), 10));
    $tableLayoutPanel1.Size = New-Object System.Drawing.Size(650, 327);
    $tableLayoutPanel1.TabIndex = 0;
    # 
    # Label
    # 
    $Label.Anchor = [System.Windows.Forms.AnchorStyles]::Left;
    $Label.AutoSize = $true;
    $tableLayoutPanel1.SetColumnSpan($Label, 2);
    $Label.Location = New-Object System.Drawing.Point(3, 6);
    $Label.Name = "Label";
    $Label.Size = New-Object System.Drawing.Size(35, 13);
    $Label.TabIndex = 0;
    $Label.Text = "Server/Task";
    # 
    # flowLayoutServers
    # 
    $flowLayoutServers.Controls.Add($lblServers);
    $flowLayoutServers.Controls.Add($lstServers);
    $flowLayoutServers.Dock = [System.Windows.Forms.DockStyle]::Fill;
    $flowLayoutServers.Location = New-Object System.Drawing.Point(3, 29);
    $flowLayoutServers.Name = "flowLayoutServers";
    $flowLayoutServers.Size = New-Object System.Drawing.Size(319, 157);
    $flowLayoutServers.TabIndex = 1;
    # 
    # lblServers
    # 
    $lblServers.AutoSize = $true;
    $lblServers.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", [float]8.25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, [byte]0);
    $lblServers.Location = New-Object System.Drawing.Point(3, 0);
    $lblServers.Name = "lblServers";
    $lblServers.Size = New-Object System.Drawing.Size(43, 13);
    $lblServers.TabIndex = 0;
    $lblServers.Text = "Servers";
    # 
    # lstServers
    # 
    $lstServers.FormattingEnabled = $true;
    $lstServers.Location = New-Object System.Drawing.Point(3, 16);
    $lstServers.Name = "lstServers";
    $lstServers.Size = New-Object System.Drawing.Size(316, 134);
    $lstServers.TabIndex = 1;
    $lstServers.Add_SelectedIndexChanged({TaskListRefresh});
    # 
    # flowLayoutTasks
    # 
    $flowLayoutTasks.Controls.Add($lblTasks);
    $flowLayoutTasks.Controls.Add($lstTasks);
    $flowLayoutTasks.Dock = [System.Windows.Forms.DockStyle]::Fill;
    $flowLayoutTasks.Location = New-Object System.Drawing.Point(328, 29);
    $flowLayoutTasks.Name = "flowLayoutTasks";
    $flowLayoutTasks.Size = New-Object System.Drawing.Size(319, 157);
    $flowLayoutTasks.TabIndex = 2;
    # 
    # lblTasks
    # 
    $lblTasks.AutoSize = $true;
    $lblTasks.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", [float]8.25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, [byte]0);
    $lblTasks.Location = New-Object System.Drawing.Point(3, 0);
    $lblTasks.Name = "lblTasks";
    $lblTasks.Size = New-Object System.Drawing.Size(36, 13);
    $lblTasks.TabIndex = 0;
    $lblTasks.Text = "Tasks";
    # 
    # lstTasks
    # 
    $lstTasks.FormattingEnabled = $true;
    $lstTasks.Location = New-Object System.Drawing.Point(3, 16);
    $lstTasks.Name = "lstTasks";
    $lstTasks.Size = New-Object System.Drawing.Size(307, 134);
    $lstTasks.TabIndex = 1;
    $lstTasks.Add_SelectedIndexChanged({DatabaseLabelRefresh});
    # 
    # panelDBInfo
    # 
    $tableLayoutPanel1.SetColumnSpan($panelDBInfo, 2);
    $panelDBInfo.Controls.Add($groupBoxDBInfo);
    $panelDBInfo.Dock = [System.Windows.Forms.DockStyle]::Fill;
    $panelDBInfo.Location = New-Object System.Drawing.Point(3, 192);
    $panelDBInfo.Name = "panelDBInfo";
    $panelDBInfo.Size = New-Object System.Drawing.Size(644, 98);
    $panelDBInfo.TabIndex = 3;
    # 
    # lblhdfsPath
    # 
    $lblhdfsPath.AutoSize = $true;
    $lblhdfsPath.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", [float]8.25, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [byte]0);
    $lblhdfsPath.Location = New-Object System.Drawing.Point(24, 60);
    $lblhdfsPath.Name = "lblhdfsPath";
    $lblhdfsPath.Size = New-Object System.Drawing.Size(49, 13);
    $lblhdfsPath.TabIndex = 2;
    $lblhdfsPath.Text = "hdfsPath";
	#
    # lblSourceDB
    # 
    $lblSourceDB.AutoSize = $true;
    $lblSourceDB.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", [float]8.25, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [byte]0);
    $lblSourceDB.Location = New-Object System.Drawing.Point(25, 39);
    $lblSourceDB.Name = "lblSourceDB";
    $lblSourceDB.Size = New-Object System.Drawing.Size(56, 13);
    $lblSourceDB.TabIndex = 1;
    $lblSourceDB.Text = "SourceDB";    # 
    # 
    # lblSourceServer
    # 
    $lblSourceServer.AutoSize = $true;
    $lblSourceServer.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", [float]8.25, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [byte]0);
    $lblSourceServer.Location = New-Object System.Drawing.Point(8, 16);
    $lblSourceServer.Name = "lblSourceServer";
    $lblSourceServer.Size = New-Object System.Drawing.Size(75, 13);
    $lblSourceServer.TabIndex = 0;
    $lblSourceServer.Text = "Source Server";
	#
    # flowLayoutDBInfo
    # 
    $flowLayoutDBInfo.AutoSize = $true;
    $tableLayoutPanel1.SetColumnSpan($flowLayoutDBInfo, 2);
    $flowLayoutDBInfo.Controls.Add($lblOffset);
    $flowLayoutDBInfo.Controls.Add($txtOffset);
    $flowLayoutDBInfo.Controls.Add($btnOk);
    $flowLayoutDBInfo.Controls.Add($panelQuit);
    $flowLayoutDBInfo.Dock = [System.Windows.Forms.DockStyle]::Fill;
    $flowLayoutDBInfo.Location = New-Object System.Drawing.Point(3, 296);
    $flowLayoutDBInfo.Name = "flowLayoutPanel1";
    $flowLayoutDBInfo.Size = New-Object System.Drawing.Size(644, 28);
    $flowLayoutDBInfo.TabIndex = 5;
    # 
    # lblOffset
    # 
    $lblOffset.Anchor = [System.Windows.Forms.AnchorStyles]::Left;
    $lblOffset.AutoSize = $true;
    $lblOffset.Location = New-Object System.Drawing.Point(3, 8);
    $lblOffset.Name = "lblOffset";
    $lblOffset.Size = New-Object System.Drawing.Size(63, 13);
    $lblOffset.TabIndex = 2;
    $lblOffset.Text = "Offset (Hrs.)";
    # 
    # txtOffset
    # 
    $txtOffset.Location = New-Object System.Drawing.Point(72, 3);
    $txtOffset.Name = "txtOffset";
    $txtOffset.Size = New-Object System.Drawing.Size(120, 20);
    $txtOffset.TabIndex = 1;
    $txtOffset.Value = $offset
    $txtOffset.Text = $txtOffset.Value.ToString()
    $txtOffset.Minimum = 0
    $txtOffset.Maximum = 300
    $txtOffset.Add_Click({ChangeOffset})
    # 
    # btnOk
    # 
    $btnOk.Location = New-Object System.Drawing.Point(198, 3);
    $btnOk.Name = "btnOk";
    $btnOk.Size = New-Object System.Drawing.Size(75, 23);
    $btnOk.TabIndex = 0;
    $btnOk.Text = "Ok";
    $btnOk.UseVisualStyleBackColor = $true;
    $btnOk.Add_Click({Button-Click});
    # 
    # panelQuit
    # 
    $panelQuit.Controls.Add($btnQuit);
    $panelQuit.Dock = [System.Windows.Forms.DockStyle]::Fill;
    $panelQuit.Location = New-Object System.Drawing.Point(279, 3);
    $panelQuit.Name = "panelQuit";
    $panelQuit.Size = New-Object System.Drawing.Size(200, 23);
    $panelQuit.TabIndex = 3;
    #
    #btnQuit
    #
    $btnQuit.Anchor = [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top;
    $btnQuit.Location = New-Object System.Drawing.Point(122, 0);
    $btnQuit.Name = "btnQuit";
    $btnQuit.Size = New-Object System.Drawing.Size(75, 23);
    $btnQuit.TabIndex = 0;
    $btnQuit.Text = "Quit";
    $btnQuit.UseVisualStyleBackColor = $true;
    $btnQuit.Add_Click({$Form.Close()});
    # 
    # groupBoxDBInfo
    # 
    $groupBoxDBInfo.AutoSize = $true
    $groupBoxDBInfo.Controls.Add($lblFileFormat);
    $groupBoxDBInfo.Controls.Add($lblSourceServer);
    $groupBoxDBInfo.Controls.Add($lblhdfsPath);
    $groupBoxDBInfo.Controls.Add($lblSourceDB);
    $groupBoxDBInfo.Dock = [System.Windows.Forms.DockStyle]::Fill;
    $groupBoxDBInfo.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat;
    $groupBoxDBInfo.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", [float]8.25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, [byte]0);
    $groupBoxDBInfo.Location = New-Object System.Drawing.Point(0, 0);
    $groupBoxDBInfo.Name = "groupBoxDBInfo";
    $groupBoxDBInfo.Size = New-Object System.Drawing.Size(644, 98);
    $groupBoxDBInfo.TabIndex = 3;
    $groupBoxDBInfo.TabStop = $false;
    $groupBoxDBInfo.Text = "DB Server Information";
	# 
	# lblFileFormat
	# 
	$lblFileFormat.AutoSize = $true;
	$lblFileFormat.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", [float]8.25, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point, [byte]0);
	$lblFileFormat.Location = New-Object System.Drawing.Point(20, 82);
	$lblFileFormat.Name = "lblFileFormat";
	$lblFileFormat.Size = New-Object System.Drawing.Size(61, 13);
	$lblFileFormat.TabIndex = 3;
	$lblFileFormat.Text = "File Format:";
    # 
    # Form1
    # 
    $Form.AutoScaleDimensions = New-Object System.Drawing.SizeF([float]6, [float]13);
    $Form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font;
    $Form.ClientSize = New-Object System.Drawing.Size(650, 327);
    $Form.Controls.Add($tableLayoutPanel1);
    $Form.Name = "Form1";
    $Form.Text = "Find Data Loss";
    $tableLayoutPanel1.ResumeLayout($false);
    $tableLayoutPanel1.PerformLayout();
    $flowLayoutServers.ResumeLayout($false);
    $flowLayoutServers.PerformLayout();
    $flowLayoutTasks.ResumeLayout($false);
    $flowLayoutTasks.PerformLayout();
    $panelDBInfo.ResumeLayout($false);
    $flowLayoutDBInfo.ResumeLayout($false);
    $flowLayoutDBInfo.PerformLayout();
    #([System.ComponentModel.ISupportInitialize]::($txtOffset)).EndInit();
    $panelQuit.ResumeLayout($false);
    $groupBoxDBInfo.ResumeLayout($false);
    $groupBoxDBInfo.PerformLayout();
    $Form.ResumeLayout($false);
}

#Define Find-DataLoss Function
Function Find-DataLoss ($server, $task) {
#    $ErrorActionPreference = "SilentlyContinue"
    $path = $servers.$($lstServers.SelectedItem).Item("dir")
    $title = $lstServers.SelectedItem  + " - " + $lstTasks.SelectedItem
    $offset = $txtOffset.Value
    if ($location -eq "home") {
        Map-Drive $drive $server $path
        get-childitem "$drive\logs\reptask_$task*.log" `
        | where { $_.LastWriteTime -gt (get-date).AddHours(-$offset) } `
        | sort -property LastWriteTime `
        | Select-String ".*User does not have permission to query backup files.*" -CaseSensitive `
        | select Filename, LineNumber, Line  `
        | Out-GridView -Title "$title"
    } else {
        Try 
        {
            $ErrorActionPreference = "Stop"
            get-childitem "\\$server\$path\logs\reptask_$task*.log" `
            | where { $_.LastWriteTime -gt (get-date).AddHours(-$offset) } `
            | sort -property LastWriteTime `
            | Select-String ".*User does not have permission to query backup files.*" -CaseSensitive `
            | select Filename, LineNumber, Line  `
            | Out-GridView -Title "$title" 
        }
#        Catch [System.Management.Automation.PipelineStoppedException] {continue}
        Catch {Write-host "caught"}
        Finally {$Error.Clear()}
    }
}

#Define Button Click Function
Function Button-Click {
    $Label.Text = $lstServers.SelectedItem  + " - " + $lstTasks.SelectedItem + " Working..."
    Find-DataLoss $lstServers.SelectedItem $lstTasks.SelectedItem
#    $Form.close()
    $Label.Text = $lstServers.SelectedItem  + " - " + $lstTasks.SelectedItem + " Done"
    $Label.Refresh()
}

#define $txtOffset changed function
Function ChangeOffset {
    $global:offset = $txtOffset.Value
}

#define ServerList SelectedIndexChanged function
Function TaskListRefresh {
    if ($lstServers.SelectedItem) {
        $path = $servers.$($lstServers.SelectedItem).Item("dir")
        $taskList.Clear()
        if ($location -eq "home") {
            Map-Drive $drive $($lstServers.SelectedItem) $path
            Get-ChildItem $drive\tasks | ?{$_.psiscontainer} | foreach-object {[void]$taskList.Add($_.Name)}
        } else {
            Get-ChildItem \\$($lstServers.SelectedItem)\$path\tasks | ?{$_.psiscontainer} | foreach-object {[void]$taskList.Add($_.Name)}
        }
        $lstTasks.DataSource = $null
        $lstTasks.DataSource = $taskList
        $lstTasks.Refresh()
        $Label.Text = $lstServers.SelectedItem  + " - " + $lstTasks.SelectedItem
        $Label.Refresh()
    }
}

#define TaskList SelectedIndexChanged function
Function DatabaseLabelRefresh {

    if ($lstTasks.SelectedItem) {    
        $path = $servers.$($lstServers.SelectedItem).Item("dir")
        if ($location -eq "home") {
#            Map-Drive $drive $($serverList.Item(0)) $($dirList.Item(0))
            $x = get-content -Path $drive\logs\LatestJsons\$($lstTasks.SelectedItem).json
        } else {
            $x = get-content -Path "\\$($lstServers.SelectedItem)\$path\logs\LatestJsons\$($lstTasks.SelectedItem).json" -ErrorAction "SilentlyContinue"
        }
        if ($x) {
            $json = $x[1..$x.Length] | Out-String | ConvertFrom-Json
            $lblhdfsPath.Text = "HDFS Path: " + ($json.'cmd.replication_definition'.databases | where role -EQ TARGET).db_settings.hdfsPath
            $lblFileFormat.Text = "File Format: " + ($json.'cmd.replication_definition'.databases | where role -EQ TARGET).db_settings.fileFormat
            if (($json.'cmd.replication_definition'.databases | where role -EQ SOURCE).db_settings.'$type' -eq "Db2mfaisSettings") {
                $lblSourceServer.Text = "Source Server: " + ($json.'cmd.replication_definition'.databases | where role -EQ SOURCE).db_settings.server
                $lblSourceDB.Text = "Source DB: " + ($json.'cmd.replication_definition'.databases | where role -EQ SOURCE).db_settings.sourcename
            } elseif (($json.'cmd.replication_definition'.databases | where role -EQ SOURCE).db_settings.'$type' -eq "OracleSettings") {
                $lblSourceServer.Text = "      Source TNS: " + ($json.'cmd.replication_definition'.databases | where role -EQ SOURCE).db_settings.server
                $lblSourceDB.Text = ""
            } else {
                    $lblSourceServer.Text = "Source Server: " + ($json.'cmd.replication_definition'.databases | where role -EQ SOURCE).db_settings.server
                    $lblSourceDB.Text = "Source DB: " + ($json.'cmd.replication_definition'.databases | where role -EQ SOURCE).db_settings.database
            }
        } else {
            $lblhdfsPath.Text = "HDFS Path: "
            $lblSourceServer.Text = "Source Server: "
            $lblSourceDB.Text = "Source DB: "
        }
        $lblhdfsPath.Refresh()
        $lblSourceServer.Refresh()
        $lblSourceDB.Refresh()
        $lblFileFormat.Refresh()
        $Label.Text = $lstServers.SelectedItem  + " - " + $lstTasks.SelectedItem
        $Label.Refresh()
        
    }
}

#Draw form
$Form = New-Object System.Windows.Forms.Form
$tableLayoutPanel1 = New-Object System.Windows.Forms.TableLayoutPanel;
$Label = New-Object System.Windows.Forms.Label;
$flowLayoutServers = New-Object System.Windows.Forms.FlowLayoutPanel;
$lblServers = New-Object System.Windows.Forms.Label;
$lstServers = New-Object System.Windows.Forms.ListBox;
$flowLayoutTasks = New-Object System.Windows.Forms.FlowLayoutPanel;
$lblTasks = New-Object System.Windows.Forms.Label;
$lstTasks = New-Object System.Windows.Forms.ListBox;
$panelDBInfo = New-Object System.Windows.Forms.Panel;
$lblhdfsPath = New-Object System.Windows.Forms.Label;
$lblSourceDB = New-Object System.Windows.Forms.Label;
$lblSourceServer = New-Object System.Windows.Forms.Label;
$flowLayoutDBInfo = New-Object System.Windows.Forms.FlowLayoutPanel;
$lblOffset = New-Object System.Windows.Forms.Label;
$txtOffset = New-Object System.Windows.Forms.NumericUpDown;
$btnOk = New-Object System.Windows.Forms.Button;
$panelQuit = New-Object System.Windows.Forms.Panel;
$btnQuit = New-Object System.Windows.Forms.Button;
$groupBoxDBInfo = New-Object System.Windows.Forms.GroupBox;
$lblFileFormat = New-Object System.Windows.Forms.Label;

InitializeComponent

foreach ($server in $servers.GetEnumerator() | sort -Property Name) {
    [void]$serverlist.Add($server.Name)
    [void]$dirList.Add($($servers.Item($server.Name).Item("dir")))
}
$lstServers.DataSource = $serverlist
if ($location -eq "home") {
    Map-Drive $drive $($serverList.Item(0)) $($dirList.Item(0))
    Get-ChildItem $drive\tasks | ?{$_.psiscontainer} | foreach-object {[void]$taskList.Add($_.Name)}
} else {
    Get-ChildItem "\\$($serverlist.Item(0))\$($dirList.Item(0))\tasks" | ?{$_.psiscontainer} | foreach-object {[void]$taskList.Add($_.Name)}
}
$lstTasks.DataSource = $taskList
 
$Form.ShowDialog()
#[System.Windows.Forms.Application]::Run($Form)


