Write-Output "Inspecting a few things for debug..."
Tree "c:\Program Files\OpenSSH" /F
Tree "$env:ProgramData\ssh" /F

Get-Content "$env:ProgramData\ssh\sshd_config"

netstat -an

Get-Process
