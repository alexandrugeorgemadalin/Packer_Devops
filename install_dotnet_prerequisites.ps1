# Install .NET 7 and ASP.NET CORE Runtime
Write-Host "Installing .NET 7 and ASP.NET CORE Runtime..."
Invoke-WebRequest -Uri https://dot.net/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1
.\dotnet-install.ps1 -Channel 7.0 -Runtime aspnetcore
Remove-Item -Path dotnet-install.ps1

Write-Host "Add dotnet to PATH environment variable"
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Users\Administrator\AppData\Local\Microsoft\dotnet\", "Machine")

Write-Host "Prerequisites installation completed."