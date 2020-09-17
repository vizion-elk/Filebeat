Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope CurrentUser	
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope LocalMachine
Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force

$ServiceName = "filebeat"

$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    #Change Directory to filebeat
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

    #Stops filebeat from running
    Stop-Service -Force $ServiceName

    #Get The filebeat Status and delete it
    Get-Service $ServiceName
    C:\Windows\System32\sc.exe delete $ServiceName

    #Change Directory to filebeat5
    Set-Location -Path 'c:\'

    "`nUninstalling Filebeat Now..."

    Get-ChildItem -Path $currentLocation -Recurse -force |
        Where-Object { -not ($_.pscontainer)} |
            Remove-Item -Force -Recurse

    Remove-Item -Recurse -Force $currentLocation

    "`nFilebeat Uninstall Successful."

    #Close Powershell window
    #Stop-Process -Id $PID
}
else {
    Start-Process -FilePath "powershell" -ArgumentList "$('-File ""')$(Get-Location)$('\')$($MyInvocation.MyCommand.Name)$('""')" -Verb runAs
}