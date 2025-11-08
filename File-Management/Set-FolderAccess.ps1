<#
.SYNOPSIS
    Adds or removes a specific NTFS access rule for a user or group on a folder.
.DESCRIPTION
    This is a critical script for managing file system permissions. It allows
    an administrator to explicitly grant ('Add') or revoke ('Remove') a defined
    level of access (e.g., Read, Modify, FullControl) for a specific identity.
.PARAMETER Path
    The full path to the directory whose permissions should be modified.
.PARAMETER Identity
    The security principal (User or Group name) to grant or revoke access for. (e.g., 'Username', 'Domain Users')
.PARAMETER Permission
    The level of access to grant or revoke: e.g., 'Read', 'Modify', 'FullControl'.
.PARAMETER Action
    The operation to perform on the security rule: 'Add' or 'Remove'.
.NOTES
    Author: [Henrik]
    Version: 1.0
    Date: 2025-11-08
    Requires: Run as Administrator.
#>
function Set-FolderAccess {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$true)]
        [string]$Identity,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("Read", "Modify", "FullControl", "Write")]
        [string]$Permission,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("Add", "Remove")]
        [string]$Action
    )

    # Check if the folder exists
    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Error "Error: The specified path does not exist or is not a folder: $Path"
        return
    }

    Write-Host "--- Attempting $($Action) $($Permission) access for '$Identity' on '$Path' ---" -ForegroundColor Yellow

    try {
        # 1. Get the current Access Control List (ACL)
        $Acl = Get-Acl -Path $Path -ErrorAction Stop

        # 2. Define the rule type (Allow or Deny) and inheritance flags (Standard folder settings)
        $AccessType = 'Allow'
        $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
        $PropagationFlags = [System.Security.AccessControl.PropagationFlags]::None

        # 3. Create the new access rule object
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $Identity,
            $Permission,
            $InheritanceFlags,
            $PropagationFlags,
            $AccessType
        )

        if ($Action -eq "Add") {
            # Add the rule to the ACL
            $Acl.AddAccessRule($AccessRule)
            Write-Host "SUCCESS: Access rule ADDED for '$Identity'." -ForegroundColor Green
        }
        elseif ($Action -eq "Remove") {
            # Remove the rule from the ACL
            $Acl.RemoveAccessRule($AccessRule)
            Write-Host "SUCCESS: Access rule REMOVED for '$Identity'." -ForegroundColor Green
        }

        # 4. Apply the modified ACL back to the folder
        Set-Acl -Path $Path -AclObject $Acl -ErrorAction Stop

    }
    catch {
        Write-Error "Failed to perform action '$Action' on '$Identity'. Error: $($_.Exception.Message)"
        Write-Host "Ensure the user/group exists and you are running as Administrator." -ForegroundColor Red
    }
}

# --- END OF FILE: AUTOMATIC EXECUTION ---

# This code uses $args to automatically pass all command line arguments to the function.
if ($args.Count -gt 0) {
    # Map the command line arguments to the function parameters for execution
    $ParameterMap = @{}
    for ($i=0; $i -lt $args.Count; $i += 2) {
        $Key = $args[$i].TrimStart('-') 
        $Value = $args[$i+1]
        $ParameterMap[$Key] = $Value
    }
    
    # Execute the function using the gathered parameters
    Set-FolderAccess @ParameterMap
} 
else {
    # If no arguments are provided, guide the user.
    Write-Host "ERROR: Script requires parameters." -ForegroundColor Red
    Write-Host "USAGE: .\Set-FolderAccess.ps1 -Path 'C:\Test' -Identity 'Username' -Permission 'Modify' -Action 'Add'" -ForegroundColor Yellow
}