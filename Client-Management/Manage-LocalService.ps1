<#
.SYNOPSIS
    Manages the state of a local system service (Start, Stop, Restart).
.DESCRIPTION
    This is a flexible script primarily designed to restart the Print Spooler service,
    but it can target any service by providing the ServiceName parameter.
.PARAMETER ServiceName
    The name of the service to manage. Defaults to 'Spooler' (Print Spooler).
.PARAMETER Action
    The operation to perform: 'Restart', 'Start', or 'Stop'. Defaults to 'Restart'.
.NOTES
    Author: [Henrik]
    Version: 1.0
    Date: 2025-11-08
#>

function Invoke-LocalService {
    param(
        [Parameter(Mandatory=$false)]
        [string]$ServiceName = 'Spooler', # Default target is the Print Spooler
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Restart", "Start", "Stop")]
        [string]$Action = 'Restart'      # Default action is to restart the service
    )

    Write-Host "--- Service Management: $($Action) '$ServiceName' ---" -ForegroundColor Yellow

    try {
        $Service = Get-Service -Name $ServiceName -ErrorAction Stop
        
        # Check current status before acting
        Write-Host "Current Status: $($Service.Status)"

        switch ($Action) {
            "Restart" {
                Write-Host "Attempting to restart '$ServiceName'..." -ForegroundColor Cyan
                Restart-Service -InputObject $Service -Force -ErrorAction Stop
            }
            "Start" {
                if ($Service.Status -ne "Running") {
                    Write-Host "Attempting to start '$ServiceName'..." -ForegroundColor Cyan
                    Start-Service -InputObject $Service -ErrorAction Stop
                } else {
                    Write-Host "'$ServiceName' is already running. No action needed." -ForegroundColor Green
                    return
                }
            }
            "Stop" {
                if ($Service.Status -ne "Stopped") {
                    Write-Host "Attempting to stop '$ServiceName'..." -ForegroundColor Cyan
                    Stop-Service -InputObject $Service -Force -ErrorAction Stop
                } else {
                    Write-Host "'$ServiceName' is already stopped. No action needed." -ForegroundColor Green
                    return
                }
            }
        }
        
        # Verify status after action
        $Service = Get-Service -Name $ServiceName
        Write-Host "Operation successful. New Status: $($Service.Status)" -ForegroundColor Green

    }
    catch {
        Write-Error "Failed to perform action '$Action' on service '$ServiceName'. Error: $($_.Exception.Message)"
    }
}

# Example usage if run without parameters (will restart Print Spooler)
Invoke-LocalService

# Example usage with parameters (Run this command in the terminal after running the file)
# Invoke-LocalService -ServiceName 'BITS' -Action 'Stop'