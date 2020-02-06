# DeployBGInfo

This script is used to add information to existing backgrounds using the sysinternals tool BGInfo. 

## Getting Started

To get started enter the following command into powershell.

```powershell
# .\DeployBGInfo.ps1 "[Title]" "[Email Address]" "[Phone Number]"
.\DeployBGInfo.ps1 "IT Support Desk" "ticket@company.com" "1-855-555-5555"
```

## Maintaining Project

This project contains my ManageProject.ps1 script which is used to maintain this project during it's lifecycle. See the below commands:

```powershell
# Possible Commands
.\ManageProject.ps1 [-Build] [-Reset] [-Publish] [-Flush] [-Init] [-GetInfo] [-SetInfo]

.\ManageProject.ps1 -Build # Packages project and increments version number
.\ManageProject.ps1 -Reset # Resets project's info
.\ManageProject.ps1 -Publish "Sample Commit Message" # Pushes this repository to remote git repo
.\ManageProject.ps1 -Flush # Clears 'releases' folder
.\ManageProject.ps1 -Init # Initializes projectinfo config file for the project
.\ManageProject.ps1 -GetInfo # Returns the current information of project
.\ManageProject.ps1 -SetInfo # Sets information of project"
.\ManageProject.ps1 -SemVer # Returns the current Semantic Version
```

### Main Script

The main script, titled 'DeployBGInfo.ps1' example is where the project will be launched from.

### Sub Folders

The template contains included folders which each serve a purpose as defined below.

#### 'config' Folder

The 'config' folder should contain configuration files. For example a sample 'config' folder might contain config.cfg

#### 'installers' Folder

The 'installers' folder should contain installers and other executables. For example a sample 'installers' folder might contain Chrome.exe and Dropbox.exe

#### 'utils' Folder

The 'utils' folder should only contain scripts which can then be dot-sourced into the main powershell script.

#### 'releases' Folder

The 'releases' folder will contain the most recent build of the powershell deployment package. When changes are made to this repository, you can run the packaging utility to create a zip of the entire project.