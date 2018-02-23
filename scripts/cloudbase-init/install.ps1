Write-Output "Downloading Cloudbase-Init..."
$cbiUrl = "https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi"
Invoke-WebRequest $cbiUrl -OutFile "C:\Windows\Temp\CloudbaseInitSetup.msi" -UseBasicParsing

Write-Output "Installing Cloudbase-Init..."
$serialPortName = @(Get-WmiObject Win32_SerialPort)[0].DeviceId
$p = Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList "/i C:\Windows\Temp\CloudbaseInitSetup.msi /qn /l*v C:\Windows\Temp\CloudbaseInitSetup.log LOGGINGSERIALPORTNAME=$serialPortName"
if ($p.ExitCode -ne 0) {
    throw "Installing Cloudbase-Init failed. Log: C:\Windows\Temp\cloudbase-init.log"
}
