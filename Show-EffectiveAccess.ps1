function Show-EffectiveAccess {
    <#
	.SYNOPSIS
	Show GUI with effective access right of a user on directories on given path as a tree.
	Module PowerShellAccessControl is required.
	https://github.com/PowerShellOrg/PowerShellAccessControl
	
	.PARAMETER User
	Username like DOMAIN\USERNAME or USERNAME.
	Default current user.
	
	.PARAMETER RootPath
	Root of directory structure.
	Default current path.
	
	.EXAMPLE
	Show-EffectiveAccess -RootPath C:\ -User tuser
	
	.NOTES
		Form based on https://blogs.technet.microsoft.com/heyscriptingguy/2010/06/15/hey-scripting-guy-how-can-i-use-the-windows-forms-treeview-control/ by Ravikanth 
	.LINK
		https://github.com/amnich/Show-EffectiveAccess
		
#>
    param(
        $User = $env:username,
        [ValidateScript( {Test-Path $_ -PathType ‘Container’})]
        $RootPath = (Get-Location).Path
    )
    BEGIN {
        if ($rootPath -match '\\$') {
            $rootPath = $rootPath.Substring(0, $rootPath.Length - 1)		
        }
        $script:user = $user
        $script:rootPath = $rootPath
        try {
            Import-Module PowerShellAccessControl
        }
        catch {
            Write-Warning "PowerShellAccessControl Module missing. Install first"
            return
        }
        function Add-Node { 
            param ( 
                $selectedNode, 
                $name, 
                $tag 
            ) 
            $newNode = new-object System.Windows.Forms.TreeNode  
            $newNode.Name = $name 
            $newNode.Text = $name 
            $newNode.Tag = $tag 
            $selectedNode.Nodes.Add($newNode) | Out-Null 
            return $newNode 
        } 
	 
        function Create-Tree { 
            if ($script:directoryNodes) {  
                $treeStructure.Nodes.remove($script:directoryNodes) 
                $frmMain.Refresh() 
            } 
            $script:directoryNodes = New-Object System.Windows.Forms.TreeNode 
            $script:directoryNodes.text = "$($script:rootPath)"
            $script:directoryNodes.Name = "rootPath" 
            $script:directoryNodes.Tag = "root" 
            $treeStructure.Nodes.Add($script:directoryNodes) | Out-Null 
	     
            $treeStructure.add_AfterSelect( { 
	
                    $rtbDescription.Text = "" 	
	
                    if ($this.SelectedNode.Tag -eq "Directory" -and !$this.SelectedNode.Nodes) {			
                        Get-ChildItem $this.SelectedNode.FullPath -Directory -ErrorAction Continue| ForEach-Object { 
                            try {
                                if (Get-EffectiveAccess -Path $_.Fullname -Principal $script:user) {
                                    $parentNode = Add-Node $this.SelectedNode $_.Name "Directory"			
                                }
                            }
                            catch {
                                Write-Warning "$($Error[0] | out-string)"
                            }
                        }
				
                        $frmMain.refresh() 
                    }
                    if ($this.SelectedNode.Tag -eq "Directory") {
                        try {
                            $access = Get-EffectiveAccess -Principal $script:user -Path $this.SelectedNode.FullPath -ListAllRights -ErrorAction Continue
                        }
                        catch {
                            $access = "Failed to get results for " + $this.SelectedNode.FullPath
                        }
                        $rtbDescription.Text = $($access | Format-Table -AutoSize | Out-String)
                        $frmMain.refresh() 
                    }
                    $this.SelectedNode.Expand()
                }) 
	    
	    
            $folders = Get-ChildItem "$($script:rootPath)\" -Directory 
            foreach ($folder in $folders) { 
                try {
                    if (Get-EffectiveAccess -Path $folder.Fullname -Principal $script:user) {
                        $parentNode = Add-Node $script:directoryNodes $folder.Name "Directory" 
                    }
                }
                catch {	
                    Write-Warning "$($Error[0] | out-string)"
                }
			
            } 
            $script:directoryNodes.Expand() 
        } 
	 
        #Generated Form Function 
        function Show-frmMain { 	
		 
            #region Import the Assemblies 
            [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null 
            [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null 
            #endregion 
				 
            $frmMain = New-Object System.Windows.Forms.Form 
            $lblDescription = New-Object System.Windows.Forms.Label 
            $lblAccessRights = New-Object System.Windows.Forms.Label 
            $btnClose = New-Object System.Windows.Forms.Button 
            $rtbDescription = New-Object System.Windows.Forms.RichTextBox 
            $treeStructure = New-Object System.Windows.Forms.TreeView 
            $InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState 
		
            $btnClose_OnClick = 
            { 
                $frmMain.Close() 		 
            } 
		 
            $OnLoadForm_StateCorrection = 
            {Create-Tree 
            } 
				 
            #---------------------------------------------- 
            #region Generated Form Code 
            $frmMain.Text = "Access rights on $script:rootpath for user $script:user" 
            $frmMain.Name = "frmMain" 
            $frmMain.DataBindings.DefaultDataSourceUpdateMode = 0 
            $System_Drawing_Size = New-Object System.Drawing.Size 
            $System_Drawing_Size.Width = 838 
            $System_Drawing_Size.Height = 612 
            $frmMain.ClientSize = $System_Drawing_Size 
					 
            $System_Drawing_Size = New-Object System.Drawing.Size 
            $System_Drawing_Size.Width = 539 
            $System_Drawing_Size.Height = 23 
            $System_Drawing_Point = New-Object System.Drawing.Point 
            $System_Drawing_Point.X = 253 
            $System_Drawing_Point.Y = 541 
		 
            $System_Drawing_Size = New-Object System.Drawing.Size 
            $System_Drawing_Size.Width = 136 
            $System_Drawing_Size.Height = 23 
		 
            $System_Drawing_Point = New-Object System.Drawing.Point 
            $System_Drawing_Point.X = 253 
            $System_Drawing_Point.Y = 518 
				 
            $lblDescription.TabIndex = 6 
            $System_Drawing_Size = New-Object System.Drawing.Size 
            $System_Drawing_Size.Width = 100 
            $System_Drawing_Size.Height = 23 
            $lblDescription.Size = $System_Drawing_Size 
            $lblDescription.Text = "Description" 
            $lblDescription.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9, 1, 3, 0) 
		 
            $System_Drawing_Point = New-Object System.Drawing.Point 
            $System_Drawing_Point.X = 255 
            $System_Drawing_Point.Y = 37 
            $lblDescription.Location = $System_Drawing_Point 
            $lblDescription.DataBindings.DefaultDataSourceUpdateMode = 0 
            $lblDescription.Name = "lblDescription" 
		 
            $frmMain.Controls.Add($lblDescription) 
		 
            $lblAccessRights.TabIndex = 5 
            $System_Drawing_Size = New-Object System.Drawing.Size 
            $System_Drawing_Size.Width = 177 
            $System_Drawing_Size.Height = 23 
            $lblAccessRights.Size = $System_Drawing_Size 
            $lblAccessRights.Text = "Access Rights" 
            $lblAccessRights.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 9, 1, 3, 0) 
		 
            $System_Drawing_Point = New-Object System.Drawing.Point 
            $System_Drawing_Point.X = 13 
            $System_Drawing_Point.Y = 13 
            $lblAccessRights.Location = $System_Drawing_Point 
            $lblAccessRights.DataBindings.DefaultDataSourceUpdateMode = 0 
            $lblAccessRights.Name = "lblAccessRights" 
		 
            $frmMain.Controls.Add($lblAccessRights) 
		 
            $btnClose.TabIndex = 4 
            $btnClose.Name = "btnClose" 
            $System_Drawing_Size = New-Object System.Drawing.Size 
            $System_Drawing_Size.Width = 75 
            $System_Drawing_Size.Height = 23 
            $btnClose.Size = $System_Drawing_Size 
            $btnClose.UseVisualStyleBackColor = $True 
		 
            $btnClose.Text = "Close" 
            $btnClose.Anchor = "Bottom", "Right"
		 
            $System_Drawing_Point = New-Object System.Drawing.Point 
            $System_Drawing_Point.X = 760 
            $System_Drawing_Point.Y = 577 
            $btnClose.Location = $System_Drawing_Point 
            $btnClose.DataBindings.DefaultDataSourceUpdateMode = 0 
            $btnClose.add_Click($btnClose_OnClick) 
		 
            $frmMain.Controls.Add($btnClose) 
		 
            $rtbDescription.Name = "rtbDescription" 
            $rtbDescription.Text = "" 
            $rtbDescription.DataBindings.DefaultDataSourceUpdateMode = 0 
            $System_Drawing_Point = New-Object System.Drawing.Point 
            $System_Drawing_Point.X = 255 
            $System_Drawing_Point.Y = 61 
            $rtbDescription.Location = $System_Drawing_Point 
            $System_Drawing_Size = New-Object System.Drawing.Size 
            $System_Drawing_Size.Width = 562 
            $System_Drawing_Size.Height = 454 
            $rtbDescription.Size = $System_Drawing_Size 
            $rtbDescription.TabIndex = 1 
            $rtbDescription.Anchor = "right", "bottom", "left", "top"
            $rtbDescription.Font = "Consolas"
		 	$rtbDescription.ReadOnly = $true
			
            $frmMain.Controls.Add($rtbDescription) 
		 
            $System_Drawing_Size = New-Object System.Drawing.Size 
            $System_Drawing_Size.Width = 224 
            $System_Drawing_Size.Height = 563 
            $treeStructure.Size = $System_Drawing_Size 
            $treeStructure.Name = "treeStructure" 
            $System_Drawing_Point = New-Object System.Drawing.Point 
            $System_Drawing_Point.X = 13 
            $System_Drawing_Point.Y = 37 
            $treeStructure.Location = $System_Drawing_Point 
            $treeStructure.DataBindings.DefaultDataSourceUpdateMode = 0 
            $treeStructure.TabIndex = 0 
            $treeStructure.Anchor = "left", "bottom", "top" 
            $frmMain.Controls.Add($treeStructure) 
		 
            #endregion Generated Form Code 
		 
            #Save the initial state of the form 
            $InitialFormWindowState = $frmMain.WindowState 
            #Init the OnLoad event to correct the initial state of the form 
            $frmMain.add_Load($OnLoadForm_StateCorrection) 
            #Show the Form 
            $frmMain.ShowDialog()| Out-Null 
		 
        } #End Function 
	 
        #Call the Function 	
    }
    PROCESS {
        Show-frmMain $user $rootPath
    }
}
