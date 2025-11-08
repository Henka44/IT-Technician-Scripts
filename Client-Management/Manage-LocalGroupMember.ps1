<#
.SYNOPSIS
    Adds or removes a user from a local security group.
.DESCRIPTION
    Provides a centralized function to manage local group memberships,
    most commonly used for granting or revoking temporary local administrative rights.
.PARAMETER UserName
    The name of the user account (e.g., 'Pyton') to add or remove.
.PARAMETER GroupName
    The name of the local group to modify. Defaults to 'Administrators'.
.PARAMETER Action
    The operation to perform: 'Add' or 'Remove'. Defaults to 'Add'.
.NOTES
    Author: [Henrik]
    Version: 1.2 (Robust Auto-Execution Fix)
    Date: 2025-11-08
    Requires: Run as Administrator.
#>
function Invoke-LocalGroupManagement {
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,

        [Parameter(Mandatory=$false)]
        [string]$GroupName = 'Administrators', # Default to the Administrators group
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("Add", "Remove")]
        [string]$Action
    )

    Write-Host "--- Group Management: $($Action) '$UserName' to '$GroupName' ---" -ForegroundColor Yellow

    try {
        if ($Action -eq "Add") {
            # Check if user is already a member before attempting to add
            if (-not (Get-LocalGroupMember -Group $GroupName | Where-Object {$_.Name -eq "$env:COMPUTERNAME\$UserName"})) {
                Add-LocalGroupMember -Group $GroupName -Member $UserName -ErrorAction Stop
                Write-Host "SUCCESS: User '$UserName' added to the local group '$GroupName'." -ForegroundColor Green
            } else {
                Write-Host "INFO: User '$UserName' is already a member of '$GroupName'. No action taken." -ForegroundColor DarkYellow
            }
        }
        elseif ($Action -eq "Remove") {
            # Check if user is a member before attempting to remove
            if (Get-LocalGroupMember -Group $GroupName | Where-Object {$_.Name -eq "$env:COMPUTERNAME\$UserName"}) {
                Remove-LocalGroupMember -Group $GroupName -Member $UserName -ErrorAction Stop
                Write-Host "SUCCESS: User '$UserName' removed from the local group '$GroupName'." -ForegroundColor Green
            } else {
                Write-Host "INFO: User '$UserName' is not a member of '$GroupName'. No action taken." -ForegroundColor DarkYellow
            }
        }
    }
    catch {
        Write-Error "Failed to perform action '$Action' on user '$UserName'. Error: $($_.Exception.Message)"
        Write-Host "Ensure the user '$UserName' exists locally or in the domain." -ForegroundColor Red
    }
}

if ($args.Count -gt 0) {
        $ParameterMap = @{}
    for ($i=0; $i -lt $args.Count; $i += 2) {
        $Key = $args[$i].TrimStart('-')
        $Value = $args[$i+1]
        $ParameterMap[$Key] = $Value
    }
    
    # Execute the function using the gathered parameters
    Invoke-LocalGroupManagement @ParameterMap
} 
else {
    # If no arguments are provided, guide the user.
    Write-Host "ERROR: Script requires parameters." -ForegroundColor Red
    Write-Host "USAGE: .\Manage-LocalGroupMember.ps1 -UserName 'USERNAME' -GroupName 'Administrators' -Action 'Add'" -ForegroundColor Yellow
}