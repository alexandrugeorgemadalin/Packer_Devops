# Define variables
$appName = "DevopsWebApp"
$appDirectory = "C:\$appName"
$appZipFile = "C:\$appName.zip"

Write-Host "Navigate to the application directory"
Set-Location -Path "C:\"

Write-Host "Extract the application package"
Expand-Archive -Path $appZipFile

Write-Host "Delete zip file"
Remove-Item $appZipFile

# Define the registry key path
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control"

# Define the name of the registry entry
$entryName = "ServicesPipeTimeout"

# Define the value to assign to the registry entry
$entryValue = 1572864

# Workaround due to t2.micro performance, had to increase the timeout limit when starting a service
# Use New-ItemProperty to create the registry entry
New-ItemProperty -Path $registryPath -Name $entryName -Value $entryValue -PropertyType DWord

Write-Host "Create new service for $appName"
New-Service -Name $appName -BinaryPathName "dotnet $appDirectory\$appName.dll" -StartupType Automatic

Start-Service -Name $appName 2>$null