<#
.SYNOPSIS
    Retrieves essential system health information.
.DESCRIPTION
    This script collects basic system health data including CPU usage, RAM status,
    OS information, and network details for quick troubleshooting and inventory.
.NOTES
    Author: [Henrik]
    Version: 1.0
    Date: 2025-11-08
#>

# Function to get System Health
function Get-SystemHealth {
    param(
        # Specify a remote computer name to target
        [string]$ComputerName = $env:COMPUTERNAME
    )

    Write-Host "--- System Health Report for $ComputerName ---" -ForegroundColor Green

    try {
        # 1. OS Information
        $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName
        [PSCustomObject]@{
            "OperatingSystem"    = $OSInfo.Caption
            "OS Build"           = $OSInfo.BuildNumber
            "System Time"        = $OSInfo.LocalDateTime
            "Last Boot"          = $OSInfo.LastBootUpTime
            "Uptime (Days)"      = ([datetime]::Now - $OSInfo.LastBootUpTime).Days
        } | Format-List

        Write-Host "--- CPU & Memory ---" -ForegroundColor Cyan

        # 2. Processor and Memory
        $CompSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $ComputerName
        $Memory = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $ComputerName | Measure-Object -Property Capacity -Sum
        
        [PSCustomObject]@{
            "Model"              = $CompSystem.Model
            "Processor"          = (Get-CimInstance -ClassName Win32_Processor -ComputerName $ComputerName).Name
            "Total RAM (GB)"     = [math]::Round($Memory.Sum / 1GB, 2)
            "Current User"       = $CompSystem.UserName
        } | Format-List

        Write-Host "--- Network ---" -ForegroundColor DarkYellow

        # 3. Network Information
        Get-NetIPAddress -AddressFamily IPv4 -ComputerName $ComputerName | 
        Where-Object { $_.InterfaceAlias -notlike "Loopback*" } | 
        Select-Object InterfaceAlias, IPAddress, PrefixLength | 
        Format-Table -AutoSize
        
    }
    catch {
        Write-Error "Could not connect or retrieve data from $ComputerName. Error: $($_.Exception.Message)"
    }
}

# Execute the function if the script is run directly
Get-SystemHealth