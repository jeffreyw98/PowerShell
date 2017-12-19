# get Attunity servers\path into $servers hash and common function definitions
. "$HOME\Documents\PowerShell\AttunityServers.ps1"

# get common functions
. "$HOME\Documents\Powershell\AttunityCommon.ps1"

#Load Assemblies
# [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.5.2\System.Windows.Forms.dll")
# [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void][System.Reflection.Assembly]::LoadFrom("C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.5.2\System.Drawing.dll")
[System.Windows.Forms.Application]::EnableVisualStyles()
# [System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
 
#Add-Type -AssemblyName System.Windows.Forms

$serverList = New-Object -Typename 'System.Collections.Generic.List[System.String]'
$taskList = New-Object -Typename 'System.Collections.Generic.List[System.String]'
$dirList = New-Object -TypeName 'System.Collections.Generic.List[System.String]'

Function InitializeComponent
        {
            $tableLayoutPanel1.SuspendLayout();
            $panel1.SuspendLayout();
            $panel2.SuspendLayout();
            $Form.SuspendLayout();
            # 
            # tableLayoutPanel1
            # 
            $tableLayoutPanel1.ColumnCount = 2;
            $tableLayoutPanel1.ColumnStyles.Add($(New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent), 50));
            $tableLayoutPanel1.ColumnStyles.Add($(New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent), 50));
            $tableLayoutPanel1.Controls.Add($panel1, 0, 0);
            $tableLayoutPanel1.Controls.Add($panel2, 1, 0);
            $tableLayoutPanel1.Location = New-Object System.Drawing.Point(12, 35);
            $tableLayoutPanel1.Name = "tableLayoutPanel1";
            $tableLayoutPanel1.RowCount = 1;
            $tableLayoutPanel1.RowStyles.Add($(New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent), 50));
            $tableLayoutPanel1.Size = New-Object System.Drawing.Size(249, 116);
            $tableLayoutPanel1.TabIndex = 0;
            # 
            # panel1
            # 
            $panel1.Controls.Add($button1);
            $panel1.Location = New-Object System.Drawing.Point(3, 3);
            $panel1.Name = "panel1";
            $panel1.Size = New-Object System.Drawing.Size(118, 100);
            $panel1.TabIndex = 0;
            # 
            # panel2
            # 
            $panel2.Controls.Add($button2);
            $panel2.Location = New-Object System.Drawing.Point(127, 3);
            $panel2.Name = "panel2";
            $panel2.Size = New-Object System.Drawing.Size(119, 100);
            $panel2.TabIndex = 1;
            # 
            # button1
            # 
            $button1.Location = New-Object System.Drawing.Point(28, 40);
            $button1.Name = "button1";
            $button1.Size = New-Object System.Drawing.Size(75, 23);
            $button1.TabIndex = 0;
            $button1.Text = "button1";
            $button1.UseVisualStyleBackColor = $true;
            # 
            # button2
            # 
            $button2.Location = New-Object System.Drawing.Point(18, 40);
            $button2.Name = "button2";
            $button2.Size = New-Object System.Drawing.Size(86, 23);
            $button2.TabIndex = 0;
            $button2.Text = "button2";
            $button2.UseVisualStyleBackColor = $true;
            # 
            # Form1
            # 
            $AutoScaleDimensions = New-Object System.Drawing.SizeF([float]6, [float]13);
            $AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Font;
            $ClientSize = New-Object System.Drawing.Size(284, 261);
            $Form.Controls.Add($tableLayoutPanel1);
            $Name = "Form1";
            $Text = "Form1";
            $tableLayoutPanel1.ResumeLayout($false);
            $panel1.ResumeLayout($false);
            $panel2.ResumeLayout($false);
            $Form.ResumeLayout($false);

        }

        #endregion
        $Form = New-Object System.Windows.Forms.Form;

            $tableLayoutPanel1 = New-Object System.Windows.Forms.TableLayoutPanel;
            $panel1 = New-Object System.Windows.Forms.Panel;
            $panel2 = New-Object System.Windows.Forms.Panel;
            $button1 = New-Object System.Windows.Forms.Button;
            $button2 = New-Object System.Windows.Forms.Button;

	InitializeComponent;
$Form.Refresh();
# $Form.ShowDialog()
[System.Windows.Forms.Application]::Run($Form)

