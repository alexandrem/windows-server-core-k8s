$K8S_PATH="C:\k"
$K8S_VERSION="1.9.3"
$HOSTNAME = hostname
$K8S_MASTER_IP = "10.142.0.2"
$K8S_DNS_SERVICE_IP = "10.100.0.10"
$K8S_DNS_DOMAIN = "cluster.local"

$tmpBase = "C:\Windows\Temp"
$7zExe = "C:\Program Files\7-Zip\7z.exe"

mkdir $K8S_PATH

# Install 7z
Write-Output "Installing 7z..."
Invoke-WebRequest http://www.7-zip.org/a/7z1604-x64.exe -OutFile $tmpBase\7z1604-x64.exe
cmd /c "$tmpBase\7z1604-x64.exe /S /qn"
Remove-Item -Recurse -Force $tmpBase\7z1604-x64.exe

$k8sUrl = "https://dl.k8s.io/v$K8S_VERSION/kubernetes-node-windows-amd64.tar.gz"
Write-Output "Downloading the Kubernetes binaries..."
Invoke-WebRequest $k8sUrl -OutFile $K8S_PATH\kubernetes-node-windows-amd64.tar.gz
cd $K8S_PATH

Write-Output "Extracting the Kubernetes binaries..."
Start-Process -FilePath "$7zExe" -Wait -ArgumentList "e kubernetes-node-windows-amd64.tar.gz"
Start-Process -FilePath "$7zExe" -Wait -ArgumentList "x kubernetes-node-windows-amd64.tar"
mv kubernetes\node\bin\*.exe .
Remove-Item -Recurse -Force kubernetes
Remove-Item -Recurse -Force kubernetes-node-windows-amd64*
