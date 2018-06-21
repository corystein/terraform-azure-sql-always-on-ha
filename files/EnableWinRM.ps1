# https://blog.netspi.com/powershell-remoting-cheatsheet/

Start-Transcript -Path C:\EnableWinRM.Log

# WinRM Quick Default Configuration
winrm quickconfig -quiet

Enable-PSRemoting –force

# Set start mode to automatic
Set-Service WinRM -StartMode Automatic

# Verify start mode and state - it should be running
Get-WmiObject -Class win32_service | Where-Object {$_.name -like "WinRM"}


# Trust all hosts
Set-Item WSMan:localhost\client\trustedhosts -value *

# Verify trusted hosts configuration
Get-Item WSMan:\localhost\Client\TrustedHosts

Write-Host "Open Firewall Port"
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5986
netsh advfirewall firewall add rule name="Windows Remote Management (HTTP-In)" dir=in action=allow protocol=TCP localport=5985

Restart-Service -Name WinRM -Force


Stop-Transcript