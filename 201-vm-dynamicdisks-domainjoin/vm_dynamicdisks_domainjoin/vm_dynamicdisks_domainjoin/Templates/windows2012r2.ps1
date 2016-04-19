﻿function IsAdmin
{
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()` 
        ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") 
    
    return $IsAdmin
}

"Set Timezone"

"Disable Firewall windows 2012"
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

"Install chocolatey"
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 

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

"Create Filecheck"
new-item -path C:\temp\ -name "windows2012r2.txt" -itemtype "file" -value "Windows 2012 R2 Script Executed" -Force
