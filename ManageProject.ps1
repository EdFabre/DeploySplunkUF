<#
.NOTES
    Name: ManageProject.ps1
    Author: Ed Fabre
    Date created: 07-22-2019
.SYNOPSIS
    Used to manage the project through it's lifecycle
.DESCRIPTION
    Utilizes variable modules to package, maintain and share this project.
.PARAMETER Build
    When set to true, this flag packs the project into a zip saved to 'releases'.
.PARAMETER Reset
    When set to true, this flag updates the version number of project to 0 and prompts for new info. Bear in mind, when using this flag, project will not pack.
.PARAMETER Publish
    When set, this flag will push the git repo to remote repo
.PARAMETER Flush
    When set, this flag clears old releases from the 'releases' folder. Bear in mind, when using this flag, project will not pack.
.PARAMETER Init
    When set, this flag prompts the user for project details and updates the project info file. Bear in mind, when using this flag, project will not pack.
.PARAMETER GetInfo
    When set, this flag returns information about this project. Bear in mind, when using this flag, project will not pack.
.PARAMETER SetInfo
    When set, this flag prompts user for information about this project. Bear in mind, when using this flag, project will not pack.
.PARAMETER SemVer
    When set, this flag returns the semantic MAJOR.MINOR.PATCH version of the project. Bear in mind, when using this flag, project will not pack.
.PARAMETER Develop
    When set, this flag monitors project for changes in files and restarts main application. Bear in mind, when using this flag, project will not pack.
.INPUTS
    Varies
.OUTPUTS
    Archive found in project's 'releases' folder
.EXAMPLE
    .\ManageProject.ps1 -Build # Packages project and increments version number
    .\ManageProject.ps1 -Reset # Resets project's info
    .\ManageProject.ps1 -Publish "Sample Commit Message" # Pushes this repository to remote git repo
    .\ManageProject.ps1 -Flush # Clears 'releases' folder
    .\ManageProject.ps1 -Init # Initializes projectinfo config file for the project
    .\ManageProject.ps1 -GetInfo # Returns the current information of project
    .\ManageProject.ps1 -SetInfo # Sets information of project
    .\ManageProject.ps1 -SemVer # Returns the current Semantic Version
    .\ManageProject.ps1 -Develop "Arguments for main script" # Runs application in development mode"
#>

# Receives script parameters
param (
    [Parameter(Mandatory = $false)]    
    [Switch]$Build,
    [Parameter(Mandatory = $false)]    
    [Switch]$Reset,
    [Parameter(Mandatory = $false)]    
    [Switch]$Publish,    
    [Parameter(Position = 0, Mandatory = $false)]    
    [String]$ARGorSTRING,
    [Parameter(Mandatory = $false)]    
    [Switch]$Flush,
    [Parameter(Mandatory = $false)]    
    [Switch]$Init,
    [Parameter(Mandatory = $false)]    
    [Switch]$GetInfo,
    [Parameter(Mandatory = $false)]    
    [Switch]$SetInfo,
    [Parameter(Mandatory = $false)]    
    [Switch]$SemVer,
    [Parameter(Mandatory = $false)]    
    [Switch]$Develop
)

# Project path variables
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$projectDirName = Split-Path (Split-Path $MyInvocation.MyCommand.Definition -Parent) -Leaf
$releasesPath = "$scriptPath\releases"
$ScriptName = $MyInvocation.MyCommand.Name

function FlushProjectReleases {
    Remove-Item -Path "$releasesPath\*" -Recurse -Force
}

function PublishProject {
    param (
        [Parameter(Mandatory = $false)]    
        [String]$MSG,
        [Parameter(Mandatory = $false)]    
        [Switch]$Release
    )
    
    $projectInfo = GetProjectInfo
    $gitRepository = [string]$projectInfo.gitRepo

    try {
        git | Out-Null
        if (Test-Path -Path "$scriptPath\.git") {

            $x = git remote -v 
            if ($null -ne $x) {
                if ([string]::IsNullOrWhiteSpace($MSG)) {
                    git add . 
                    git commit -m "Automatically pushed!" 
                    if ($Release) {
                        $tempVer = SemVer
                        git tag -a $tempVer -m "Releasing version $tempVer"
                        git push -u origin master --tags
                    }
                    else {
                        git push -u origin master
                    }
                }
                else {
                    git add . 
                    git commit -m $MSG 
                    if ($Release) {
                        $tempVer = SemVer
                        git tag -a $tempVer -m "Releasing version $tempVer"
                        git push -u origin master --tags
                    }
                    else {
                        git push -u origin master
                    }
                }
            }
            else {
                if ([string]::IsNullOrWhiteSpace($gitRepository)) {
                    Write-Host "Git Remote is not Set!"
                }
                else {
                    if ([string]::IsNullOrWhiteSpace($MSG)) {
                        git add . 
                        git commit -m "Automatically pushed!"
                        git remote add origin "$gitRepository" 
                        if ($Release) {
                            $tempVer = SemVer
                            git tag -a $tempVer -m "Releasing version $tempVer"
                            git push -u origin master --tags
                        }
                        else {
                            git push -u origin master
                        }
                    }
                    else {
                        git add . 
                        git commit -m $MSG
                        git remote add origin "$gitRepository" 
                        if ($Release) {
                            $tempVer = SemVer
                            git tag -a $tempVer -m "Releasing version $tempVer"
                            git push -u origin master --tags
                        }
                        else {
                            git push -u origin master
                        }
                    }
                }
            }
        }
        else {
            $doNow = Read-Host "Git repository not initialized. Would you like to initialize it now? (Y)"
            if (([string]::IsNullOrWhiteSpace($doNow)) -OR ($doNow -eq "Y")) {
                Write-Host "Initializing Git Repository"
                git init
                if ([string]::IsNullOrWhiteSpace($gitRepository)) {
                    Write-Host "Git Remote is not Set!"                    
                }
                else {
                    if ([string]::IsNullOrWhiteSpace($MSG)) {
                        git add . 
                        git commit -m "Automatically pushed!" 
                        git remote add origin "$gitRepository" 
                        if ($Release) {
                            $tempVer = SemVer
                            git tag -a $tempVer -m "Releasing version $tempVer"
                            git push -u origin master --tags
                        }
                        else {
                            git push -u origin master
                        }
                    }
                    else {
                        git add . 
                        git commit -m $MSG
                        git remote add origin "$gitRepository" 
                        if ($Release) {
                            $tempVer = SemVer
                            git tag -a $tempVer -m "Releasing version $tempVer"
                            git push -u origin master --tags
                        }
                        else {
                            git push -u origin master
                        }
                    }
                }
            }
        }
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        Write-Host "Git is not installed!"
    }
}

function UpdateProjectVersion {
    param (
        [Parameter(Mandatory = $false)]    
        [Switch]$Minor,
        [Parameter(Mandatory = $false)]    
        [Switch]$Patch
    )

    # Get Project Info and convert to PS Object
    $projectInfo = GetProjectInfo

    if ($Reset) {
        $projectInfo = SetProjectInfo
    }
    else {
        if ($Minor) {
            $projectInfo.version = SemVer -Minor -Bump                        
        }
        elseif ($Patch) {
            $projectInfo.version = SemVer -Patch -Bump
        }
        else {
            $projectInfo.version = SemVer -Major -Bump            
        }
    }

    $projectInfo.title = $projectInfo.title -replace '\s', ''

    $projectInfo.PsObject.properties | % {
        $projectInfo | Add-Member -MemberType $_.MemberType -Name $_.Name -Value $_.Value -Force
    }

    # Convert Project Info to JSON Object file
    $projectInfo | ConvertTo-Json -Depth 100 | Out-File "$scriptPath\projectInfo.json"
}

function GetProjectInfo {

    # Reads current projectInfo.json
    if (Test-Path -Path "$scriptPath\projectInfo.json") {
        $projectInfo = Get-Content -Raw -Path "$scriptPath\projectInfo.json" | ConvertFrom-Json 
        if ($GetInfo) {
            $projectInfo
            exit
        }
        # Convert Project Info to JSON Object file
        $projectInfo | ConvertTo-Json -Depth 100 | Out-File "$scriptPath\projectInfo.json"
        return $projectInfo
    }
    else {
        $createNewInfo = Read-Host -Prompt "The project info has not yet been initialized. Would you like to initialize it now? (Y/N)"
        if ($createNewInfo -eq "Y") {
            $projectInfo = InitProjectInfo
            if ($GetInfo) {
                $projectInfo
                $saveInfoJson = Read-Host -Prompt "Would you like to save this projects info? (Y/N)"
                if ($saveInfoJson -eq "Y") {
                    # Convert Project Info to JSON Object file
                    $projectInfo | ConvertTo-Json -Depth 100 | Out-File "$scriptPath\projectInfo.json"
                }
                exit
            }
            # Convert Project Info to JSON Object file
            $projectInfo | ConvertTo-Json -Depth 100 | Out-File "$scriptPath\projectInfo.json"
            return $projectInfo
        }
        # else {
        #     $projectInfo = InitProjectInfo -SilentInit
        #     if ($GetInfo) {
        #         $projectInfo
        #         $saveInfoJson = Read-Host -Prompt "Would you like to save this projects info? (Y/N)"
        #         if ($saveInfoJson -eq "Y") {
        #             # Convert Project Info to JSON Object file
        #             $projectInfo | ConvertTo-Json -Depth 100 | Out-File "$scriptPath\projectInfo.json"
        #         }
        #         exit
        #     }
        #     # Convert Project Info to JSON Object file
        #     $projectInfo | ConvertTo-Json -Depth 100 | Out-File "$scriptPath\projectInfo.json"
        #     return $projectInfo
        # }
    }
}

function SetProjectInfo {
    if (Test-Path -Path "$scriptPath\projectInfo.json") {
        $projectInfo = Get-Content -Raw -Path "$scriptPath\projectInfo.json" | ConvertFrom-Json 

        $tempProjectTitle = $projectInfo.title
        $projectInfo.title = Read-Host -Prompt "What is the title of this project? ($($projectInfo.title))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.title)) {
            $projectInfo.title = $tempProjectTitle
        }

        $tempProjectDescription = $projectInfo.description
        $projectInfo.description = Read-Host -Prompt "What does this project do? ($($projectInfo.description))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.description)) {
            $projectInfo.description = $tempProjectDescription
        }

        if ($Reset) {
            $projectInfo.version = "1.0.0"
        }
        else {
            $tempProjectVersion = $projectInfo.version
            $projectInfo.version = Read-Host -Prompt "What is the project's version? ($($projectInfo.version))"
            if ([string]::IsNullOrWhiteSpace($projectInfo.version)) {
                $projectInfo.version = $tempProjectVersion
            }
        }

        $tempProjectAuthor = $projectInfo.author
        $projectInfo.author = Read-Host -Prompt "Who is the author of this project? ($($projectInfo.author))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.author)) {
            $projectInfo.author = $tempProjectAuthor
        }

        $tempProjectGitRepo = $projectInfo.gitRepo
        $projectInfo.gitRepo = Read-Host -Prompt "What is the git remote repo? ($($projectInfo.gitRepo))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.gitRepo)) {
            $projectInfo.gitRepo = $tempProjectGitRepo
        }

        $tempProjectMain = $projectInfo.main
        $projectInfo.main = Read-Host -Prompt "What is the project path of your project? ($($projectInfo.main))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.main)) {
            $projectInfo.main = $tempProjectMain
        }

        $tempProjectLicense = $projectInfo.license
        $projectInfo.license = Read-Host -Prompt "What is this project licensed under? ($($projectInfo.license))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.license)) {
            $projectInfo.license = $tempProjectLicense
        }

        # Convert Project Info to JSON Object file
        $projectInfo | ConvertTo-Json -Depth 100 | Out-File "$scriptPath\projectInfo.json"
        return $projectInfo
    } 
    else {
        Write-Host "Project Info JSON DNE"
        $projectInfo = @"
{
    "title":  null,
    "description":  null,
    "version":  "1.0.0",
    "author":  null,
    "gitRepo":  null,
    "main":  null,
    "license":  null
}
"@ | ConvertFrom-Json

        $tempProjectTitle = $projectInfo.title
        $projectInfo.title = Read-Host -Prompt "What is the title of this project? ($($projectInfo.title))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.title)) {
            $projectInfo.title = $tempProjectTitle
        }

        $tempProjectDescription = $projectInfo.description
        $projectInfo.description = Read-Host -Prompt "What does this project do? ($($projectInfo.description))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.description)) {
            $projectInfo.description = $tempProjectDescription
        }

        if ($Reset) {
            $projectInfo.version = "1.0.0"
        }
        else {
            $tempProjectVersion = $projectInfo.version
            $projectInfo.version = Read-Host -Prompt "What is the project's version? ($($projectInfo.version))"
            if ([string]::IsNullOrWhiteSpace($projectInfo.version)) {
                $projectInfo.version = $tempProjectVersion
            }
        }

        $tempProjectAuthor = $projectInfo.author
        $projectInfo.author = Read-Host -Prompt "Who is the author of this project? ($($projectInfo.author))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.author)) {
            $projectInfo.author = $tempProjectAuthor
        }

        $tempProjectGitRepo = $projectInfo.gitRepo
        $projectInfo.gitRepo = Read-Host -Prompt "What is the git remote repo? ($($projectInfo.gitRepo))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.gitRepo)) {
            $projectInfo.gitRepo = $tempProjectGitRepo
        }

        $tempProjectMain = $projectInfo.main
        $projectInfo.main = Read-Host -Prompt "What is the project path of your project? ($($projectInfo.main))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.main)) {
            $projectInfo.main = $tempProjectMain
        }

        $tempProjectLicense = $projectInfo.license
        $projectInfo.license = Read-Host -Prompt "What is this project licensed under? ($($projectInfo.license))"
        if ([string]::IsNullOrWhiteSpace($projectInfo.license)) {
            $projectInfo.license = $tempProjectLicense
        }

        # Convert Project Info to JSON Object file
        $projectInfo | ConvertTo-Json -Depth 100 | Out-File "$scriptPath\projectInfo.json"
        return $projectInfo
    }
}

function InitProjectInfo {
    param (
        [Parameter(Mandatory = $false)]    
        [Switch]$SilentInit
    )

    $projectInfo = @"
{
    "title":  null,
    "description":  null,
    "version":  "1.0.0",
    "author":  null,
    "gitRepo":  null,
    "main":  null,
    "license":  null
}
"@ | ConvertFrom-Json
    if ($SilentInit) {
        return $projectInfo
    }
    else {
        $projectInfo = SetProjectInfo

        # Clear-Host
        if ($Init) {
            # Convert Project Info to JSON Object file
            $projectInfo | ConvertTo-Json -Depth 100 | Out-File "$scriptPath\projectInfo.json"
        }
        return $projectInfo
    }
}

function BuildProject {
    $projectInfo = GetProjectInfo
    Write-Host "Received Project info"

    # Create releases
    $releaseVersion = SemVer
    $projectDirName = [string]$projectInfo.title

    Remove-Item -Path "C:\temp\v$releaseVersion\$projectDirName" -Recurse -Force -ErrorAction Ignore
    New-Item -Path "C:\temp\v$releaseVersion\" -Name "$projectDirName" -ItemType "directory" -Force | Out-Null
    New-Item -Path $releasesPath -Name "v$releaseVersion" -ItemType "directory" -Force | Out-Null

    # Packge project into a zip
    Copy-Item "$scriptPath\*" -Destination "C:\temp\v$releaseVersion\$projectDirName" -Recurse -Force
    Remove-Item -Path "C:\temp\v$releaseVersion\$projectDirName\releases" -Recurse -ErrorAction Ignore
    Remove-Item -Path "C:\temp\v$releaseVersion\$projectDirName\.git" -Recurse -ErrorAction Ignore
    Remove-Item -Path "C:\temp\v$releaseVersion\$projectDirName\$ScriptName" -ErrorAction Ignore
    Compress-Archive -Path "C:\temp\v$releaseVersion\$projectDirName\*" -DestinationPath "$releasesPath\v$releaseVersion\$projectDirName" -Force
    Remove-Item -Path "C:\temp\v$releaseVersion" -Recurse -Force -ErrorAction Ignore

    Write-Host "Updating Project Info Version"

    PublishProject "Publising Build Version $releaseVersion" -Release

    # Increment Project Version
    UpdateProjectVersion
}

function SemVer {
    param (
        [Parameter(Mandatory = $false)]    
        [Switch]$Major,
        [Parameter(Mandatory = $false)]    
        [Switch]$Minor,
        [Parameter(Mandatory = $false)]    
        [Switch]$Patch,
        [Parameter(Mandatory = $false)]    
        [Switch]$Reset,
        [Parameter(Mandatory = $false)]    
        [Switch]$Bump,
        [Parameter(Mandatory = $false)]    
        [Switch]$Drop
    )

    $projectInfo = GetProjectInfo

    $releaseVersion = [string]$projectInfo.version
    $semVer = $releaseVersion.Split(".")

    # Converts a regular version to Semantic Version Array
    if ($semVer.Length -ne 3) {
        $newSemVer = @()
        $newSemVer += ($semVer[0] -as [int])
        $newSemVer += 0
        $newSemVer += 0
        $semVer = $newSemVer
    }
    else {
        $newSemVer = @()
        $newSemVer += ($semVer[0] -as [int])
        $newSemVer += ($semVer[1] -as [int])
        $newSemVer += ($semVer[2] -as [int])        
        $semVer = $newSemVer
    }

    
    if ($Reset) {
        $semVer = @("0", "0", "0")
    }
    elseif ($Major) {
        if ($Bump) {
            $semVer[0] = $semVer[0] + 1
        }
        elseif ($Drop) {
            $semVer[0] = $semVer[0] - 1
        }
        else {
            Write-Host "Project Patch Version: $($semVer[0])"            
        }
    }
    elseif ($Minor) {
        if ($Bump) {
            $semVer[1] = $semVer[1] + 1
        }
        elseif ($Drop) {
            $semVer[1] = $semVer[1] - 1
        }
        else {
            Write-Host "Project Patch Version: $($semVer[1])"            
        }
    }
    elseif ($Patch) {
        if ($Bump) {
            $semVer[2] = $semVer[2] + 1
        }
        elseif ($Drop) {
            $semVer[2] = $semVer[2] - 1
        }
        else {
            Write-Host "Project Patch Version: $($semVer[2])"            
        }
    }
    else {
        return $semVer -join '.'
    }
    return $semVer -join '.'
}

function Develop {
    param (
        [Parameter(Position = 0, Mandatory = $false)]    
        [String]$scriptArgs = ""
    )

    iex ((new-object net.webclient).DownloadString("http://bit.ly/Install-PsWatch"))
    
    Import-Module pswatch
    # cls
    
    $MainProjectScript = "$scriptPath\$((GetProjectInfo).main) $scriptArgs"
    $MainProjectScript
    
    Start-Process -FilePath powershell -ArgumentList @("-NoExit", "'$MainProjectScript'")
    watch "." | % {
        Start-Process -FilePath powershell -ArgumentList @("-NoExit", "'$MainProjectScript'")
    }
}

if ($Build) {
    BuildProject
}
elseif ($Reset) {
    UpdateProjectVersion
}
elseif ($Publish) {
    PublishProject($ARGorSTRING)
}
elseif ($Flush) {
    FlushProjectReleases
}
elseif ($Init) {
    InitProjectInfo
}
elseif ($GetInfo) {
    GetProjectInfo
}
elseif ($SetInfo) {
    SetProjectInfo
}
elseif ($SemVer) {
    SemVer
}
elseif ($Develop) {
    Develop($ARGorSTRING)
}
else {
    Write-Host "usage: .\ManageProject.ps1 [-Build] [-Reset] [-Publish] [-Flush] [-Init] [-GetInfo] [-SetInfo]

       .\ManageProject.ps1 -Build # Packages project and increments version number
       .\ManageProject.ps1 -Reset # Resets project's info
       .\ManageProject.ps1 -Publish `"Sample Commit Message`" # Pushes this repository to remote git repo
       .\ManageProject.ps1 -Flush # Clears 'releases' folder
       .\ManageProject.ps1 -Init # Initializes projectinfo config file for the project
       .\ManageProject.ps1 -GetInfo # Returns the current information of project
       .\ManageProject.ps1 -SetInfo # Sets information of project
       .\ManageProject.ps1 -SemVer # Returns the current Semantic Version
       .\ManageProject.ps1 -Develop `"Arguments for main script`" # Runs application in development mode"
}
