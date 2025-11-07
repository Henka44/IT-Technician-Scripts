<#
.SYNOPSIS
    Retrieves system health information, supporting both local and remote execution.
.DESCRIPTION
    This script attempts to retrieve system data using CIM/WMI (WinRM dependent) for remote systems.
    If connection fails for the local machine, it falls back to native cmdlets (WinRM independent).
.NOTES
    Author: [Henrik]
    Version: 1.2 (Hybrid Local/Remote)
    Date: 2025-11-08
#>

# Function to get System Health (Hybrid Mode)
function Get-SystemHealth {
    param(
        # Specify a computer name (local or remote)
        [string]$ComputerName = $env:COMPUTERNAME
    )

    Write-Host "--- System Health Report for $ComputerName ---" -ForegroundColor Green

    # Use a variable to track if we successfully connected via CIM
    $CimSuccess = $false

    try {
        # === 1. Attempt CIM/WinRM connection first (Standard for IT Support) ===
        $OSInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction Stop
        $CompSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $ComputerName -ErrorAction Stop
        $Processor = Get-CimInstance -ClassName Win32_Processor -ComputerName $ComputerName -ErrorAction Stop
        $CimSuccess = $true
        
        # --- Data Extraction using CIM/WMI objects ---
        
        $Memory = Get-CimInstance -ClassName Win32_PhysicalMemory -ComputerName $ComputerName | Measure-Object -Property Capacity -Sum
        $LastBootTime = $OSInfo.LastBootUpTime

        Write-Host "--- OS & System (via CIM/WMI) ---" -ForegroundColor Cyan
        
        [PSCustomObject]@{
            "OperatingSystem"    = $OSInfo.Caption
            "OS Build"           = $OSInfo.BuildNumber
            "System Time"        = Get-Date
            "Last Boot"          = $LastBootTime
            "Uptime (Days)"      = ([datetime]::Now - $LastBootTime).Days
            "Model"              = $CompSystem.Model
            "Processor"          = $Processor.Name
            "Total RAM (GB)"     = [math]::Round($Memory.Sum / 1GB, 2)
            "Current User"       = $CompSystem.UserName
        } | Format-List
    }
    catch {
        # === 2. Fallback to Local Cmdlets if CIM/WinRM failed ===
        if ($ComputerName -eq $env:COMPUTERNAME -and -not $CimSuccess) {
            Write-Warning "CIM/WinRM failed. Falling back to local cmdlets for $ComputerName."
            $CompInfo = Get-ComputerInfo
            
            Write-Host "--- OS & System (via Local Cmdlets) ---" -ForegroundColor Cyan
            
            [PSCustomObject]@{
                "OperatingSystem"    = $CompInfo.OSDisplayVersion
                "OS Build"           = $CompInfo.OSBuildNumber
                "System Time"        = Get-Date
                "Last Boot"          = $CompInfo.OSLastBootUpTime
                "Uptime (Days)"      = ([datetime]::Now - $CompInfo.OSLastBootUpTime).Days
                "Model"              = $CompInfo.CsModel
                "Processor"          = (Get-CimInstance -ClassName Win32_Processor).Name # Safe CIM call
                "Total RAM (GB)"     = [math]::Round((Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)
                "Current User"       = $env:USERNAME
            } | Format-List
        }
        else {
            Write-Error "Failed to retrieve data from $ComputerName. Check WinRM and network connectivity. Error: $($_.Exception.Message)"
        }
    }
    
    # 3. Network Information (Local cmdlets, always works locally)
    Write-Host "--- Network ---" -ForegroundColor DarkYellow
    Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object { $_.InterfaceAlias -notlike "Loopback*" -and $_.InterfaceAlias -notlike "Teredo*" } | 
    Select-Object InterfaceAlias, IPAddress, PrefixLength | 
    Format-Table -AutoSize

}

# Execute the function if the script is run directly
Get-SystemHealth