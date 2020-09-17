Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser	
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope LocalMachine
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force


$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    "`nYou are running Powershell with full privilege`n"

    #Change Folder to filebeat
    $currentLocation = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

    If ( -Not (Test-Path -Path "$currentLocation\filebeat") )
    {
        Write-Host -Object "Path $currentLocation\filebeat does not exit, exiting..." -ForegroundColor Red
        Exit 1
    }
    Else
    {
        Set-Location -Path "$currentLocation\filebeat"
    }

    #Set-ExecutionPolicy Unrestricted
    
    "Filebeatbeat Execution policy set - Success`n"

    
    #=========== Filebeat Credentials Form ===========#
    "Adding Filebeat Credentials`n"

    #GUI To Insert User Credentials
    #Pop-up Box that Adds Credentials 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

    #============ Box ============#
    $objForm = New-Object System.Windows.Forms.Form 
    $objForm.Text = "Vizion.ai Credentials Form"
    $objForm.Size = New-Object System.Drawing.Size(300,400) 
    $objForm.StartPosition = "CenterScreen"

    $objForm.KeyPreview = $True
    $objForm.Add_KeyDown({
        if ($_.KeyCode -eq "Enter" -or $_.KeyCode -eq "Escape"){
            $objForm.Close()
        }
    })

    #============= Buttons =========#
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(75,280)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    $OKButton.Add_Click({$objForm.Close()})
    $objForm.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(150,280)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.Add_Click({$objForm.Close()})
    $objForm.Controls.Add($CancelButton)

    #============= Header ==========#
    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,10) 
    $objLabel.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel.Text = "Please enter the following:"
    $objForm.Controls.Add($objLabel)

    #============ First Input =======#
    $objLabel1 = New-Object System.Windows.Forms.Label
    $objLabel1.Location = New-Object System.Drawing.Size(10,40) 
    $objLabel1.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel1.Text = "Kibana URL"
    $objForm.Controls.Add($objLabel1)

    $objTextBox = New-Object System.Windows.Forms.TextBox 
    $objTextBox.Location = New-Object System.Drawing.Size(10,60) 
    $objTextBox.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBox) 

    #============ Second Input =======#
    $objLabel2 = New-Object System.Windows.Forms.Label
    $objLabel2.Location = New-Object System.Drawing.Size(10,100) 
    $objLabel2.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel2.Text = "Username:"
    $objForm.Controls.Add($objLabel2)

    $objTextBox2 = New-Object System.Windows.Forms.TextBox 
    $objTextBox2.Location = New-Object System.Drawing.Size(10,120) 
    $objTextBox2.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBox2)

    # #============ Third Input =======#
    $objLabel3 = New-Object System.Windows.Forms.Label
    $objLabel3.Location = New-Object System.Drawing.Size(10,160) 
    $objLabel3.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel3.Text = "Password:"
    $objForm.Controls.Add($objLabel3)

    $objTextBox3 = New-Object System.Windows.Forms.TextBox 
    $objTextBox3.Location = New-Object System.Drawing.Size(10,180) 
    $objTextBox3.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBox3)

    #============ Fourth Input =======#
    $objLabel4 = New-Object System.Windows.Forms.Label
    $objLabel4.Location = New-Object System.Drawing.Size(10,220) 
    $objLabel4.Size = New-Object System.Drawing.Size(280,20) 
    $objLabel4.Text = "Vizion Elasticsearch API Endpoint:"
    $objForm.Controls.Add($objLabel4)

    $objTextBox4 = New-Object System.Windows.Forms.TextBox 
    $objTextBox4.Location = New-Object System.Drawing.Size(10,240) 
    $objTextBox4.Size = New-Object System.Drawing.Size(260,20) 
    $objForm.Controls.Add($objTextBox4)

    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})
    [void]$objForm.ShowDialog()

    #Opens up YML file and inserts Kibana URL
    (Get-Content filebeat.yml) |
        ForEach-Object {$_ -Replace 'host: ""', "host: ""$($objTextBox.Text)"""} |
            Set-Content filebeat.yml

    #Opens Up YML and sets Password
    (Get-Content filebeat.yml) |       
        ForEach-Object {$_ -Replace 'password: ""', "password: ""$($objTextBox3.Text)""" } |
            Set-Content filebeat.yml

    #Opens Up YML and sets Username
    (Get-Content filebeat.yml) |       
        ForEach-Object {$_ -Replace 'username: ""', "username: ""$($objTextBox2.Text)""" } |
            Set-Content filebeat.yml

    #Opens up YML file and inserts Elasticsearch API Endpoint
    (Get-Content filebeat.yml) |
        ForEach-Object {$_ -Replace 'elasticsearch-api-endpoint', "$($objTextBox4.Text)"} |
            Set-Content filebeat.yml

    
    #Sets sets the folder path for Filebeat to monitor files
    function Read-FolderBrowserDialog([string]$Message, [string]$InitialDirectory, [switch]$NoNewFolderButton) {
        $browseForFolderOptions = 0
        if ($NoNewFolderButton) { $browseForFolderOptions += 512 }

        $app = New-Object -ComObject Shell.Application
        $folder = $app.BrowseForFolder(0, $Message, $browseForFolderOptions, $InitialDirectory)
        if ($folder) { $selectedDirectory = $folder.Self.Path } else { $selectedDirectory = '' }
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($app) > $null
        return $selectedDirectory
    }

    $directoryPath = Read-FolderBrowserDialog -Message "Select the folder you would like to monitor files from"

    #Conditional that doesn't let 
    if (![string]::IsNullOrEmpty($directoryPath)) { 
        Write-Host "You selected the folder: $directoryPath" 
        
    }
    else { 
        "You did not select a directory." 
    }

    #Work around that deletes the Linux -var/path
    $data = foreach($line in Get-Content filebeat.yml)
    {
        if($line -notlike '*/var/log*')
        {
            $line
        }
    }

    $data | Set-content filebeat.yml -Force

    # Opens Up YML and sets path to files that were declared by user
    $lineNumber = 8
    $fileContent = Get-Content filebeat.yml
    $fileContent[$lineNumber-1] += "    - $($directoryPath)\*"
    $fileContent | Set-Content filebeat.yml


    #Enables the filebeat input--manual handle
    # (Get-Content filebeat.yml) |       
    #     ForEach-Object {$_ -Replace "false", "true" } |
    #         Set-Content filebeat.yml

    # #============ Filebeat Modules Dropdown =============#

    # Add-Type -AssemblyName System.Windows.Forms
    # Add-Type -AssemblyName System.Drawing

    # $form = New-Object System.Windows.Forms.Form
    # $form.Text = 'Filebeat Modules'
    # $form.Size = New-Object System.Drawing.Size(300,350)
    # $form.StartPosition = 'CenterScreen'

    # $okButton = New-Object System.Windows.Forms.Button
    # $okButton.Location = New-Object System.Drawing.Point(75,250)
    # $okButton.Size = New-Object System.Drawing.Size(75,23)
    # $okButton.Text = 'OK'
    # $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    # $form.AcceptButton = $okButton
    # $form.Controls.Add($okButton)

    # $cancelButton = New-Object System.Windows.Forms.Button
    # $cancelButton.Location = New-Object System.Drawing.Point(150,250)
    # $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    # $cancelButton.Text = 'Cancel'
    # $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    # $form.CancelButton = $cancelButton
    # $form.Controls.Add($cancelButton)

    # $label = New-Object System.Windows.Forms.Label
    # $label.Location = New-Object System.Drawing.Point(10,20)
    # $label.Size = New-Object System.Drawing.Size(280,20)
    # $label.Text = 'Please select a module:'
    # $form.Controls.Add($label)

    # $listBox = New-Object System.Windows.Forms.ListBox
    # $listBox.Location = New-Object System.Drawing.Point(10,40)
    # $listBox.Size = New-Object System.Drawing.Size(260,20)
    # $listBox.Height = 200

    # [void] $listBox.Items.Add('apache2')
    # [void] $listBox.Items.Add('icinga')
    # [void] $listBox.Items.Add('iis')
    # [void] $listBox.Items.Add('kafka')
    # [void] $listBox.Items.Add('mongodb')
    # [void] $listBox.Items.Add('mysql')
    # [void] $listBox.Items.Add('nginx')
    # [void] $listBox.Items.Add('osquery')
    # [void] $listBox.Items.Add('postgresql')
    # [void] $listBox.Items.Add('redis')
    # [void] $listBox.Items.Add('traefik')

    # $form.Controls.Add($listBox)

    # $form.Topmost = $true

    # $result = $form.ShowDialog()

    # if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    # {
    #     $x = $listBox.SelectedItem
        
    #     .\filebeat.exe modules enable $x
    # }

    #Runs the config test to make sure all data has been inputted correctly
    #.\filebeat.exe -e -configtest
    .\filebeat.exe test config
    .\filebeat.exe test output

    #Load filebeat Preconfigured Dashboards
    .\filebeat.exe setup --dashboards

    #Install filebeat as a service
    .\install-service-filebeat.ps1

    #Runs filebeat as a Service
    Start-service filebeat

    #Show that filebeat is running
    Get-Service filebeat

    "`nFilebeat Started. Check Kibana For The Incoming Data!"

    #Close Powershell window
    #Stop-Process -Id $PID

}
else {
    Start-Process -FilePath "powershell" -ArgumentList "$('-File ""')$(Get-Location)$('\')$($MyInvocation.MyCommand.Name)$('""')" -Verb runAs
}