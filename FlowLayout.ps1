        #region Windows Form Designer generated code

        #/ <summary>
        #/ Required method for Designer support - do not modify
        #/ the contents of this method with the code editor.
        #/ </summary>
InitializeComponent
        {
            $tableLayoutPanel1.SuspendLayout();
            $flowLayoutPanel1.SuspendLayout();
            $flowLayoutPanel2.SuspendLayout();
            $SuspendLayout();
            # 
            # tableLayoutPanel1
            # 
            $tableLayoutPanel1.ColumnCount = 2;
            $tableLayoutPanel1.ColumnStyles.Add(New-Object System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            $tableLayoutPanel1.ColumnStyles.Add(New-Object System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 50F));
            $tableLayoutPanel1.Controls.Add($flowLayoutPanel2, 1, 0);
            $tableLayoutPanel1.Controls.Add($flowLayoutPanel1, 0, 0);
            $tableLayoutPanel1.Location = New-Object System.Drawing.Point(0, 0);
            $tableLayoutPanel1.Name = "tableLayoutPanel1";
            $tableLayoutPanel1.RowCount = 1;
            $tableLayoutPanel1.RowStyles.Add(New-Object System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 50F));
            $tableLayoutPanel1.Size = New-Object System.Drawing.Size(281, 121);
            $tableLayoutPanel1.TabIndex = 0;
            # 
            # flowLayoutPanel1
            # 
            $flowLayoutPanel1.Controls.Add($button1);
            $flowLayoutPanel1.Location = New-Object System.Drawing.Point(3, 3);
            $flowLayoutPanel1.Name = "flowLayoutPanel1";
            $flowLayoutPanel1.Size = New-Object System.Drawing.Size(134, 100);
            $flowLayoutPanel1.TabIndex = 0;
            # 
            # flowLayoutPanel2
            # 
            $flowLayoutPanel2.Controls.Add($button2);
            $flowLayoutPanel2.Location = New-Object System.Drawing.Point(143, 3);
            $flowLayoutPanel2.Name = "flowLayoutPanel2";
            $flowLayoutPanel2.Size = New-Object System.Drawing.Size(135, 100);
            $flowLayoutPanel2.TabIndex = 0;
            # 
            # button1
            # 
            $button1.Location = New-Object System.Drawing.Point(3, 3);
            $button1.Name = "button1";
            $button1.Size = New-Object System.Drawing.Size(88, 38);
            $button1.TabIndex = 0;
            $button1.Text = "button1";
            $button1.UseVisualStyleBackColor = true;
            # 
            # button2
            # 
            $button2.Location = New-Object System.Drawing.Point(3, 3);
            $button2.Name = "button2";
            $button2.Size = New-Object System.Drawing.Size(75, 23);
            $button2.TabIndex = 0;
            $button2.Text = "button2";
            $button2.UseVisualStyleBackColor = true;
            # 
            # Form1
            # 
            $AutoScaleDimensions = New-Object System.Drawing.SizeF(6F, 13F);
            $AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            $ClientSize = New-Object System.Drawing.Size(284, 261);
            $Controls.Add($tableLayoutPanel1);
            $Name = "Form1";
            $Text = "Form1";
            $tableLayoutPanel1.ResumeLayout(false);
            $flowLayoutPanel1.ResumeLayout(false);
            $flowLayoutPanel2.ResumeLayout(false);
            $ResumeLayout(false);

        }

        #endregion

            $tableLayoutPanel1 = New-Object System.Windows.Forms.TableLayoutPanel();
            $flowLayoutPanel1 = New-Object System.Windows.Forms.FlowLayoutPanel();
            $flowLayoutPanel2 = New-Object System.Windows.Forms.FlowLayoutPanel();
            $button1 = New-Object System.Windows.Forms.Button();
            $button2 = New-Object System.Windows.Forms.Button();
    }
}

