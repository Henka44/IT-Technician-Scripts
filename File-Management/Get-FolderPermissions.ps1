<#
.SYNOPSIS
    Retrieves and summarizes NTFS permissions for a specified folder.
.DESCRIPTION
    This script takes a folder path and returns a clean, formatted table
    showing the IdentityReference (User/Group), AccessControlType (Allow/Deny),
    and FileSystemRights (Read, Write, FullControl).
.PARAMETER Path
    The full path to the directory for which permissions should be retrieved.
.NOTES
    Author: [Henrik]
    Version: 1.0
    Date: 2025-11-08
    Requires: Read access to the target folder.
#>
function Get-FolderPermissions {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    # Validate that the provided path actually exists
    if (-not (Test-Path -Path $Path -PathType Container)) {
        Write-Error "Error: The specified path does not exist or is not a folder: $Path"
        return
    }

    Write-Host "--- NTFS Permission Report for: $Path ---" -ForegroundColor Yellow

    try {
        # Use Get-Acl to retrieve the Access Control List
        $Acl = Get-Acl -Path $Path -ErrorAction Stop
        
        # Process each access rule and select only the relevant properties
        $Acl.Access | Select-Object IdentityReference, AccessControlType, FileSystemRights | Format-Table -AutoSize
        
    }
    catch {
        Write-Error "Failed to retrieve permissions for '$Path'. Ensure you have sufficient permissions. Error: $($_.Exception.Message)"
    }
}

# --- END OF FILE: AUTOMATIC EXECUTION ---

# Check if arguments are present and call the function with those arguments.
if ($args.Count -gt 0) {
    # We only need the first argument, as the function only takes one positional path parameter.
    # The syntax $args[0] retrieves the path provided immediately after the script name.
    Get-FolderPermissions -Path $args[0]
} 
else {
    # If no path is provided, guide the user.
    Write-Host "ERROR: Script requires a folder path." -ForegroundColor Red
    Write-Host "USAGE: .\Get-FolderPermissions.ps1 'C:\Path\To\Folder'" -ForegroundColor Yellow
}