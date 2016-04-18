function IsAdmin
{
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()` 
        ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") 
    
    return $IsAdmin
}

function Disable-IEESC
{
    $AdminKey = HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}
    $UserKey = HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}
    Set-ItemProperty -Path $AdminKey -Name IsInstalled -Value 0
    Set-ItemProperty -Path $UserKey -Name IsInstalled -Value 0
    Stop-Process -Name Explorer
    Write-Host IE Enhanced Security Configuration (ESC) has been disabled. -ForegroundColor Green
}

"Disable Firewall windows 2012"
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

"Disable IE ESC"
Disable-IEESC

"Install chocolatey"
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

