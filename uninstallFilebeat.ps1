Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser	
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope LocalMachine
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Set-ExecutionPolicy Unrestricted

    #Change Directory to filebeat
    Set-Location -Path 'c:\Filebeat-7.7.0\filebeat'

    #Stops filebeat from running
    Stop-Service -Force filebeat

    #Get The filebeat Status
    Get-Service filebeat

    #Change Directory to filebeat5
    Set-Location -Path 'c:\'

    "`nUninstalling Filebeat Now..."

    $Target = "C:\Filebeat-7.7.0"

    Get-ChildItem -Path $Target -Recurse -force |
        Where-Object { -not ($_.pscontainer)} |
            Remove-Item -Force -Recurse

    Remove-Item -Recurse -Force $Target

    "`nFilebeat Uninstall Successful."

    #Close Powershell window
    Stop-Process -Id $PID
}
else {
    Start-Process -FilePath "powershell" -ArgumentList "$('-File ""')$(Get-Location)$('\')$($MyInvocation.MyCommand.Name)$('""')" -Verb runAs
}