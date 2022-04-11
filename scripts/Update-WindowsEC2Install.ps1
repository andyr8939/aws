<#
        .SYNOPSIS
        Update Windows AWS EC2 Instances (EC2 Install and EC2 Launch).

        .DESCRIPTION
        If your instance doesn't start when changing to the latest instances, and starts to fail instance helthchecks, it will be because of incorrect/old drivers.
        First perform the AWS Automation Upgrade of the instance (https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/migrating-latest-types.html#auto-upgrade)
        as there several reboots involved with that.
        Once complete execute this script to update the remaining EC2 Install and EC2 Launch components.

        .EXAMPLE
        PS> .\Update-WindowsEC2Install.ps1

        .NOTES
        Created By - Andy Roberts - andyr8939@gmail.com
        Last Updated - 11th April 2022
        Maintained - https://github.com/andyr8939/aws/scripts/Update-WindowsEC2Install.ps1
#>

# Set Download Path
$Download_Location = Get-Location

# Download EC2 Install
Write-Output "Downloading EC2 Install from AWS"
Invoke-WebRequest -Uri https://s3.amazonaws.com/ec2-downloads-windows/EC2Config/EC2Install.zip -OutFile $Download_Location\Ec2Install.zip
Expand-Archive $Download_Location\Ec2Install.zip

# Install EC2 Install silently without reboot
Write-Output "Installing EC2 Install"
Start-Process $Download_Location\Ec2Install\Ec2Install.exe /quiet -Wait

# # Take a backup of existing EC2 Config if already exists
Compress-archive C:\ProgramData\Amazon\EC2-Windows\Launch\Config\*.* $Download_Location\Ec2ConfigBackup.zip

# Download EC2 Config and Install Script
Write-Output "Downloading EC2 Config"
Invoke-WebRequest -Uri https://s3.amazonaws.com/ec2-downloads-windows/EC2Launch/latest/EC2-Windows-Launch.zip -OutFile $Download_Location\EC2-Windows-Launch.zip
Invoke-WebRequest -Uri https://s3.amazonaws.com/ec2-downloads-windows/EC2Launch/latest/install.ps1 -OutFile $Download_Location\install.ps1

# # Install EC2 Config using the AWS provided script
Write-Output "Installing EC2 Config"
.\install.ps1

# Replace EC2 Configs with original configs
Write-Output "Restoring EC2 Config Backups"
Expand-Archive -Path $Download_Location\Ec2ConfigBackup.zip -DestinationPath C:\ProgramData\Amazon\EC2-Windows\Launch\Config\ -Force

Write-Output "Cleaning up install files"
Remove-Item -Path $Download_Location\EC2-Windows-Launch.zip -Recurse -Force
Remove-Item -Path $Download_Location\Ec2Install -Recurse -Force
Remove-Item -Path $Download_Location\Ec2Install.zip -Force
Remove-Item -Path $Download_Location\Ec2ConfigBackup.zip -Force
Remove-Item -Path $Download_Location\install.ps1 -Force
