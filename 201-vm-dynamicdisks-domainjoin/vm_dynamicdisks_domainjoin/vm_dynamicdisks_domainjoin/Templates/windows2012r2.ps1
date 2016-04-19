function IsAdmin
{
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()` 
        ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") 
    
    return $IsAdmin
}

function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

function Enable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 1
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 1
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been enabled." -ForegroundColor Green
}

function Disable-UserAccessControl {
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 00000000
    Write-Host "User Access Control (UAC) has been disabled." -ForegroundColor Green    
}

"Create Filecheck"
new-item -path C:\temp\ -name "windows2012r2.txt" -itemtype "file" -value "Windows 2012 R2 Script Executed" -Force

"Disable IE-ESC"
Disable-InternetExplorerESC

"Disable Firewall windows 2012"
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

"Install chocolatey"
#(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')))>$null 2>&1
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "((new-object net.webclient).DownloadFile('https://chocolatey.org/install.ps1','c:\temp\install.ps1'))"
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& 'c:\temp\install.ps1'"

"Create Storage Pools"
$storagePoolName = "StoragePool"
$storageSubName = "Storage Spaces*"
$vDiskName = "VirtualDisk"
$allocationSize = "65536"

New-StoragePool –FriendlyName $storagePoolName –StorageSubsystemFriendlyName $storageSubName –PhysicalDisks (Get-PhysicalDisk –CanPool $True)
$disks = Get-StoragePool –FriendlyName $storagePoolName -IsPrimordial $false | Get-PhysicalDisk
New-VirtualDisk –FriendlyName $vDiskName -ResiliencySettingName Simple –NumberOfColumns ($disks.Count) –UseMaximumSize –Interleave 256KB –StoragePoolFriendlyName $storagePoolName
Get-VirtualDisk –FriendlyName $vDiskName | Get-Disk | Initialize-Disk –Passthru | New-Partition –AssignDriveLetter –UseMaximumSize | Format-Volume –AllocationUnitSize $allocationSize -FileSystem NTFS 

"Change TimeZone to Central Time"
$timezone = "Central Standard Time"
&tzutil.exe /s "$timezone"
