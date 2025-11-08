<#
.SYNOPSIS
    Removes the local computer from its Active Directory domain and places it in a Workgroup.
.DESCRIPTION
    This script removes the machine from the current domain. Note that the command uses
    local administrator credentials to authenticate the unjoin process. A restart is mandatory.
.PARAMETER WorkgroupName
    The name of the workgroup to join after unjoining the domain. Defaults to 'WORKGROUP'.
.NOTES
    Author: [Henrik]
    Version: 1.2 (Strict Verb Fix)
    Date: 2025-11-08
    Requires: Run as Administrator.
#>
function Remove-DomainComputer {
    param(
        [Parameter(Mandatory=$false)]
        [string]$WorkgroupName = "WORKGROUP"
    )

    Write-Host "--- Initiating Domain Unjoin Process (Using Remove Verb) ---" -ForegroundColor Yellow
    
    try {
        # Securely prompt for local administrator credentials to authenticate the unjoin
        Write-Host "Please enter LOCAL administrator credentials to unjoin the domain..." -ForegroundColor Cyan
        $LocalAdminCred = Get-Credential 

        # Remove the computer from the domain and join the workgroup
        Remove-Computer -WorkgroupName $WorkgroupName -UnjoinDomainCredential $LocalAdminCred -Restart -ErrorAction Stop

        Write-Host "SUCCESS: Computer is unjoining the domain and will restart now." -ForegroundColor Green
    }
    catch {
        Write-Error "Domain unjoin failed. Check local administrator credentials. Error: $($_.Exception.Message)"
    }
}

# Execute the function
Remove-DomainComputer -WorkgroupName "WORKGROUP"