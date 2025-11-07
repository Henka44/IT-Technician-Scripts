<#
.SYNOPSIS
    Retrieves essential system health information from the LOCAL machine.
.DESCRIPTION
    This script collects basic system health data including CPU usage, RAM status,
    OS information, and network details. It uses cmdlets designed for local access
    to avoid reliance on the WinRM service.
.NOTES
    Author: [Your Name Here]
    Version: 1.1 (WinRM-independent)
    Date: 2025-11-08
#>

# Function to get Local System Health
function Get-LocalSystemHealth {

    # Fetch basic computer information using the native cmdlet
    $CompInfo = Get-ComputerInfo

    Write-Host "--- System Health Report for $($CompInfo.CsName) ---" -ForegroundColor Green

    try {
        # 1. OS Information
        [PSCustomObject]@{
            "OperatingSystem"    = $CompInfo.OSDisplayVersion
            "OS Build"           = $CompInfo.OSBuildNumber
            "System Time"        = Get-Date
            "Last Boot"          = $CompInfo.OSLastBootUpTime
            # Calculate Uptime
            "Uptime (Days)"      = ([datetime]::Now - $CompInfo.OSLastBootUpTime).Days
        } | Format-List

        Write-Host "--- CPU & Memory ---" -ForegroundColor Cyan

        # 2. Processor and Memory (Using WMI directly, but locally)
        $Processor = Get-CimInstance -ClassName Win32_Processor
        $Memory = Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
        
        [PSCustomObject]@{
            "Model"              = $CompInfo.CsModel
            "Processor"          = $Processor.Name
            "Total RAM (GB)"     = [math]::Round($Memory.Sum / 1GB, 2)
            "Current User"       = $env:USERNAME
        } | Format-List

        Write-Host "--- Network ---" -ForegroundColor DarkYellow

        # 3. Network Information (using Net cmdlets which are local)
        Get-NetIPAddress -AddressFamily IPv4 | 
        Where-Object { $_.InterfaceAlias -notlike "Loopback*" -and $_.InterfaceAlias -notlike "Teredo*" } | 
        Select-Object InterfaceAlias, IPAddress, PrefixLength | 
        Format-Table -AutoSize
        
    }
    catch {
        Write-Error "An error occurred during local data retrieval: $($_.Exception.Message)"
    }
}

# Execute the function if the script is run directly
Get-LocalSystemHealth