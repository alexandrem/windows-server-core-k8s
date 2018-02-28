#
# Configure Windows server for containers
#

Write-Output "Installing Windows Containers feature..."
Install-WindowsFeature -Name Containers

Write-Output "Installing powershell NuGet provider..."
Install-PackageProvider -Name NuGet -Force

Write-Output "Installing Docker EE preview..."
# Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
# Install-Package -Name Docker -ProviderName DockerMsftProvider

# Install-Module -Name DockerProvider -Repository PSGallery -Force
# Install-Package -Name docker -ProviderName DockerProvider -Force
Install-Module -Name DockerProvider -Force
Install-Package -Name docker -ProviderName DockerProvider -RequiredVersion Preview -Force
