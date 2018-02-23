Write-Output "Cloudbase-Init configuration started..."

$filePath = "C:\Windows\Temp\cloudbase-init.conf"
$destPath = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf"
Copy-Item -Path $filePath -Destination $destPath

$filePath = "C:\Windows\Temp\cloudbase-init-unattend.conf"
$destPath = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf"
Copy-Item -Path $filePath -Destination $destPath

# Registry cleanup
Write-Output "Registry cleanup..."
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name Unattend*

# Running Cloudbase-Init setup complete
Write-Output "Running SetSetupComplete..."
& "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\SetSetupComplete.cmd"

Write-Output "Cloudbase-Init configuration completed.."
