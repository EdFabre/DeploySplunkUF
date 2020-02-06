# Project Path Variables
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

. "$scriptPath\Write-Log"

function PartOfDomain {
    <#
.NOTES
    Name: PartOfDomain.ps1
    Author: Ed Fabre
    Date created: 08-13-2019
.SYNOPSIS
    Detects devices domain status
.DESCRIPTION
    This is a custom commandlette which detects workstations domain status
.INPUTS
    NONE
.OUTPUTS
    BOOLEAN
.EXAMPLE
    // Returns whether workstation is domain or workgroup
    PartOfDomain
#>
    return (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain
}

function AddAccount {
    <#
.NOTES
    Name: AddAccount
    Author: Ed Fabre
    Date created: 08-15-2019
.SYNOPSIS
    Adds the user
.DESCRIPTION
    Adds Local or Domain User account
.PARAMETER Username
    Local or Domain User account to be added
.PARAMETER Domain
    When this switch is flagged, it treats user as domain user
.INPUTS
    [PLACEHOLDER]
.OUTPUTS
    [PLACEHOLDER]
.EXAMPLE
    AddAccount -Username "userman" -Password "supersecure" -Group "Admnistrators" -Domain
#>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]    
        [String]$Username,
        [Parameter(Position = 1, Mandatory = $true)]    
        [String]$Password,
        [Parameter(Position = 2, Mandatory = $false)]    
        [String]$Group = "User",
        [Parameter(Mandatory = $false)]    
        [Switch]$Domain
    )
        
    if ($Domain) {
        if (TestUser $Username -Domain) {
            Write-Log "Did not add new domain user '$Username' since it already exists" "Debug"
            return $false
        }
        else {
            try {
                Start-Process -FilePath "cmd.exe" -WorkingDirectory $scriptPath -ArgumentList "/c net user $Username $Password /add /domain" -Wait
                if (TestUser $Username -Domain) {
                    Write-Log "Added new domain user '$Username'" "Debug"
                    AddAccountToGroup $Username $Group
                }
                else {
                    Write-Log "Failed to add new domain user '$Username'" "Debug"
                }
            }
            catch {
                Write-Log $_.Exception "Error"
                return $null                    
            }
        }
    } 
    else {
        if (TestUser $Username) {
            Write-Log "Did not add new local user '$Username' since it already exists" "Debug"
            return $false
        }
        else {
            try {
                Start-Process -FilePath "cmd.exe" -WorkingDirectory $scriptPath -ArgumentList "/c net user $Username $Password /add" -Wait
                if (TestUser $Username) {
                    Write-Log "Added new local user '$Username'" "Debug"
                    AddAccountToGroup $Username $Group
                }
                else {
                    Write-Log "Failed to add new local user '$Username'" "Debug"
                }
            }
            catch {
                Write-Log $_.Exception "Error"
                return $null                    
            }
        }
    }
}

function DeleteAccount {
    <#
.NOTES
    Name: DeleteAccount
    Author: Ed Fabre
    Date created: 08-15-2019
.SYNOPSIS
    Removes the user
.DESCRIPTION
    Removes Local or Domain User account
.PARAMETER Username
    Local or Domain User account to be removed
.PARAMETER Domain
    When this switch is flagged, it treats user as domain user
.INPUTS
    [PLACEHOLDER]
.OUTPUTS
    [PLACEHOLDER]
.EXAMPLE
    DeleteAccount -Username "userman" -Domain
#>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]    
        [String]$Username,
        [Parameter(Mandatory = $false)]    
        [Switch]$Domain
    )
        
    if ($Domain) {
        if (TestUser $Username -Domain) {
            try {
                Start-Process -FilePath "cmd.exe" -WorkingDirectory $scriptPath -ArgumentList "/c net user $Username /delete /domain" -Wait                
                Write-Log "Removed domain user '$Username'" "Debug"
            }
            catch {
                Write-Log $_.Exception "Error"
                return $null                    
            }
        }
        else {
            Write-Log "Did not delete domain user '$Username' since it DNE" "Debug"
            return $false
        }
    } 
    else {
        if (TestUser $Username) {
            try {
                Start-Process -FilePath "cmd.exe" -WorkingDirectory $scriptPath -ArgumentList "/c net user $Username $Password /delete" -Wait
                Write-Log "Removed local user '$Username'" "Debug"
            }
            catch {
                Write-Log $_.Exception "Error"
                return $null                    
            }
        }
        else {
            Write-Log "Did not delete local user '$Username' since it DNE" "Debug"
            return $false
        }
    }
}

function AddAccountToGroup {
    <#
.NOTES
    Name: AddAccountToGroup
    Author: Ed Fabre
    Date created: 08-15-2019
.SYNOPSIS
    Adds the user to the specified local group
.DESCRIPTION
    Adds Local or Domain User account to a local window's group
.PARAMETER Username
    Local or Domain User account to be added
.PARAMETER Group
    Local Group to add user to
.INPUTS
    [PLACEHOLDER]
.OUTPUTS
    [PLACEHOLDER]
.EXAMPLE
    AddAccountToGroup -Username "userman" -Group "Administrators"
#>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]    
        [String]$Username,
        [Parameter(Position = 1, Mandatory = $true)]    
        [String]$Group
    )
    
    if (TestGroup($Group)) {
        try {
            Add-LocalGroupMember -Group $Group -Member $Username -ErrorAction SilentlyContinue
            Write-Log "Added user '$Username' to the '$Group' Group!" "Debug"
        }
        catch {
            Write-Log $_.Exception "Error"
            return $null        
        }
    }
}

function TestGroup {
    <#
.NOTES
    Name: TestGroup
    Author: Ed Fabre
    Date created: 08-14-2019
.SYNOPSIS
    Checks for local groups on workstations
.DESCRIPTION
    Checks for local groups on workstations
.PARAMETER Group
    Local Group to be tested
.INPUTS
    [PLACEHOLDER]
.OUTPUTS
    [PLACEHOLDER]
.EXAMPLE
    TestGroup -Group "GroupName"
#>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]    
        [String]$Group,  
        [Switch]$Domain
    )

    if ((glg $Group -ErrorAction SilentlyContinue).Name -eq $Group) {
        Write-Log "Local Group '$Group' already exists" "Debug"
        return $true
    }
    else {
        Write-Log "Local Group '$Group' DNE" "Debug"
        return $false
    }      
    
}

function TestUser {
    <#
.NOTES
    Name: TestUser
    Author: Ed Fabre
    Date created: 08-14-2019
.SYNOPSIS
    Checks for local and domain accounts on workstations
.DESCRIPTION
    Checks for local and domain accounts on workstations
.PARAMETER Username
    Local or Domain User account to be tested
.PARAMETER Domain
    Switch to determine whether or not this is testing Domain account
.INPUTS
    [PLACEHOLDER]
.OUTPUTS
    [PLACEHOLDER]
.EXAMPLE
    TestUser -Username "userman" -Domain
#>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0, Mandatory = $true)]    
        [String]$Username,  
        [Switch]$Domain
    )
    
    if ($Domain) {
        if (PartOfDomain) {
            Write-Log "This machine is a part of a domain" "Debug"

            try {
                if (([ADSISearcher] "(sAMAccountName=$Username)").FindOne().length -gt 0) {
                    Write-Log "Domain User already exists" "Debug"
                    return $true
                } 
                else {
                    Write-Log "Domain User DNE" "Debug"
                    return $false
                }
            }
            catch {
                Write-Log $_.Exception "Error"
                return $null
            }            
        }
        else {
            Write-Log "This machine is not part of domain" "Debug"
            return $null
        }
    }
    else {
        try {
            if ((Get-LocalUser $Username -ErrorAction SilentlyContinue).name -eq $Username) {
                Write-Log "Local User already exists" "Debug"
                return $true
            }
            else {
                Write-Log "Local User DNE" "Debug"
                return $false
            }
        }
        catch {
            Write-Log $_.Exception "Error"
            return $null
        }      
    }
}