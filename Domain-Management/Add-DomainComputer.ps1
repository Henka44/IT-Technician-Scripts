<#
.SYNOPSIS
    Securely adds the local computer to an Active Directory domain.
.DESCRIPTION
    Prompts for domain credentials and attempts to join the local machine
    to the specified Active Directory domain. A mandatory restart is performed
    upon successful completion.
.PARAMETER DomainName
    The FQDN (Fully Qualified Domain Name) of the target Active Directory domain (e.g., contoso.local).
.NOTES
    Author: [Henrik]
    Version: 1.2 (Strict Verb Fix)
    Date: 2025-11-08
    Requires: Run as Administrator.
#>
function Add-DomainComputer {
    param(
        [Parameter(Mandatory=$true)]
        [string]$DomainName
    )

    Write-Host "--- Initiating Domain Join Process (Using Add Verb) ---" -ForegroundColor Yellow

    try {
        # Securely prompt the user for the domain admin credentials
        Write-Host "Please enter credentials for joining the domain '$DomainName'..." -ForegroundColor Cyan
        $DomainCred = Get-Credential 

        # Attempt to join the domain
        Write-Host "Attempting to join '$DomainName'. Computer will restart upon success." -ForegroundColor Cyan
        
        Add-Computer -DomainName $DomainName -Credential $DomainCred -Restart -ErrorAction Stop

        Write-Host "SUCCESS: Computer is joining the domain and will restart now." -ForegroundColor Green

    }
    catch {
        Write-Error "Domain join failed. Check credentials, network connectivity, and DNS. Error: $($_.Exception.Message)"
    }
}

# Execute the function
Add-DomainComputer -DomainName "SKOLA.LOKAL"