# This installs Win32-OpenSSH
# Required to enable remote powershell from linux/mac

$openSshFilename = 'OpenSSH-Win64.zip'
# $openSshSetupUrl = "https://www.mls-software.com/files/$openSshSetupFilename"
$openSshUrl = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v1.0.0.0/OpenSSH-Win64.zip"
$openSshHome = 'C:\Program Files\OpenSSH'
$sshdConfig = "$env:ProgramData\ssh\sshd_config"
[Reflection.Assembly]::LoadWithPartialName('System.Web') | Out-Null
$openSshSetup = "C:\Windows\Temp\OpenSSH.zip"

Write-Output "Downloading Win32-OpenSSH..."
Invoke-WebRequest $openSshUrl -OutFile $openSshSetup
Add-Type -A System.IO.Compression.FileSystem
Write-Output "Extracting the OpenSSH zip..."
[IO.Compression.ZipFile]::ExtractToDirectory($openSshSetup, "C:\Program Files")
Rename-Item "C:\Program Files\OpenSSH-Win64" $openSshHome

Write-Output "Generating ssh key signature..."
Start-Process -FilePath "$openSshHome\ssh-keygen.exe" -Wait -ArgumentList '-A'

Write-Output "Fixing sshd file permissions..."
& "$openSshHome\FixHostFilePermissions.ps1" -Confirm:$false

Write-Output "Executing the install-sshd.ps1 script..."
& $openSshHome\install-sshd.ps1

Write-Host 'Installing the default vagrant insecure public key...'
$vagrantSsh = "$env:USERPROFILE\.ssh"
mkdir $vagrantSsh | Out-Null
Invoke-WebRequest `
    'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' `
    -OutFile "$vagrantSsh\authorized_keys"

# To allow powershell SSH Remoting
Write-Output "Installing latest powershell core 6.x"
$psUrl = "https://github.com/PowerShell/PowerShell/releases/download/v6.0.1/PowerShell-6.0.1-win-x64.msi"
Invoke-WebRequest $psUrl -OutFile C:\Windows\Temp\ps.msi -UseBasicParsing
Start-Process C:\Windows\Temp\ps.msi /qn -Wait

# Does openssh sshd_config handle correctly whitespaces in subsystem paths ?
# Probably correct now with the win32-openssh port, but anyway
cmd /c mklink /D c:\powershell "C:\Program Files\PowerShell\6.0.1"

Write-Output = "Configuring the sshd_config..."
[IO.File]::WriteAllText(
    "$sshdConfig",
    ([IO.File]::ReadAllText("$sshdConfig") `
        -replace '#?ListenAddress 0.0.0.0','ListenAddress 0.0.0.0'))

# disable StrictModes.
[IO.File]::WriteAllText(
    "$sshdConfig",
    ([IO.File]::ReadAllText("$sshdConfig") `
        -replace '#?StrictModes yes','StrictModes no'))

# Enable pub key
[IO.File]::WriteAllText(
    "$sshdConfig",
    ([IO.File]::ReadAllText("$sshdConfig") `
        -replace '#?RSAAuthentication yes','RSAAuthentication yes'))
[IO.File]::WriteAllText(
    "$sshdConfig",
    ([IO.File]::ReadAllText("$sshdConfig") `
        -replace '#?PubkeyAuthentication yes','PubkeyAuthentication yes'))

# Enable password auth
[IO.File]::WriteAllText(
    "$sshdConfig",
    ([IO.File]::ReadAllText("$sshdConfig") `
        -replace '#?PasswordAuthentication yes','PasswordAuthentication yes'))

$pwshPath = "C:\powershell\pwsh.exe"
# powershell subsystem for PS ssh remoting
[IO.File]::AppendAllText(
    "$sshdConfig",
    "Subsystem powershell $pwshPath -sshs -NoLogo -NoProfile`n"
)

# ensure banner is removed
[IO.File]::WriteAllText(
    "$sshdConfig",
    ([IO.File]::ReadAllText("$sshdConfig") `
        -replace '^Banner','#Banner'))

Write-Output "Open firewall for incoming ssh connections..."
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

Write-Output = "Starting the sshd services..."
Set-Service sshd -StartupType Automatic
# Set-Service ssh-agent -StartupType Automatic
Start-Service sshd
# Start-Service ssh-agent

# Get-Content C:\PROGRAMDATA\ssh\sshd_config | Where { $_ -notmatch "^Subsystem powershell" } | Set-Content C:\PROGRAMDATA\ssh\sshd_config.new
