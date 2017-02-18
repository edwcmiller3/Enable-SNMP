<#
.SYNOPSIS
    Enable-SNMP: Script to enable and configure the SNMP service on Windows workstations and servers.

.DESCRIPTION
    Enables SNMP service and sets the necessary registry keys to configure SNMP.
#>

$SNMPManagers = Read-Host "Enter SNMP managers separated by a semicolon (;)"
$SNMPManagers = $SNMPManagers.Split(';')

$CommString = Read-Host "Enter the community strings separated by a semicolon (;)"
$CommString = $CommString.Split(';')

#Gather list of currently enabled Windows features and check for SNMP
$TempFile = "$env:temp\TempFile.log"
& dism.exe /Online /Get-Features /Format:Table | Out-File $TempFile -Force

$WinFeatures = (Import-Csv -Delimiter '|' -Path $TempFile -Header Name,state | Where-Object { $_.State -eq "Enabled " }) | Select-Object Name

Remove-Item -Path $TempFile

#If SNMP service not installed, run the installer
if ($WinFeatures | Where-Object { $_.Name.Trim() -like "SNMP*" }) {
    Write-Host "SNMP service already installed."
} else {
    Write-Host "Enabling the SNMP service."
    $ dism.exe /Online /Enable-Feature /FeatureName:SNMP
}

Write-Host "Configuring SNMP Services..."

#Set SNMP Permitted Manager(s) ** WARNING : This will over write current settings **
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v 1 /t REG_SZ /d localhost /f | Out-Null