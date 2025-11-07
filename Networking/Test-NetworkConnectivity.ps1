<#
.SYNOPSIS
    Tests network connectivity to critical internal and external targets.
.DESCRIPTION
    This script runs Test-NetConnection against a list of common targets
    (Gateway, DNS, External web) to quickly diagnose network isolation issues.
.NOTES
    Author: [Henrik]
    Version: 1.0
    Date: 2025-11-08
#>

function Test-NetworkConnectivity {
    # Define critical targets for testing
    $Targets = @(
        # Standard gateway (Router) - Check local connectivity
        @{ Name = "Local Gateway"; Target = (Get-NetRoute | Where-Object { $_.DestinationPrefix -eq '0.0.0.0/0' }).NextHop; Port = 0 },
        
        # Google Public DNS - Check external name resolution
        @{ Name = "Google DNS"; Target = "8.8.8.8"; Port = 0 },
        
        # External Web Site (HTTPS) - Check internet connection and web traffic
        @{ Name = "External Web (Google)"; Target = "google.com"; Port = 443 }

        # Add a common internal resource (You can customize this for a work environment)
        # @{ Name = "Internal DC/Server"; Target = "192.168.1.10"; Port = 3389 } 
    )

    Write-Host "--- Network Connectivity Test ---" -ForegroundColor Yellow
    Write-Host "Testing from $($env:COMPUTERNAME)"

    # Array to store results
    $Results = @()

    foreach ($Target in $Targets) {
        Write-Host "Testing $($Target.Name) ($($Target.Target))..." -NoNewline

        # Check if the port is defined for the test
        if ($Target.Port -gt 0) {
            # Test using TCP (Port check)
            $TestResult = Test-NetConnection -ComputerName $Target.Target -Port $Target.Port -InformationLevel Quiet -WarningAction SilentlyContinue
            $Protocol = "TCP Port $($Target.Port)"
        }
        else {
            # Test using ICMP (Ping check)
            $TestResult = Test-NetConnection -ComputerName $Target.Target -InformationLevel Quiet -WarningAction SilentlyContinue
            $Protocol = "ICMP"
        }

        # Determine status and color
        if ($TestResult -eq $true) {
            $Status = "SUCCESS"
            Write-Host " OK" -ForegroundColor Green
        }
        else {
            $Status = "FAILED"
            Write-Host " FAIL" -ForegroundColor Red
        }

        # Add result to the collection
        $Results += [PSCustomObject]@{
            TargetName = $Target.Name
            Target = $Target.Target
            Protocol = $Protocol
            Status = $Status
        }
    }

    Write-Host "`n--- Summary ---" -ForegroundColor Yellow
    $Results | Format-Table -AutoSize
}

# Execute the function
Test-NetworkConnectivity