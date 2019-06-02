<#
.SYNOPSIS
Utility to manage LogRhythm Archives files
.DESCRIPTION
DISCLAIMER: Deleting Inactive Archives is NOT advised, ever!

For storage or compliance reasons you may wish to automatically delete or move InactiveArchives after a certain period of time.   

This script should be run on all Data Processors and on the Platform Manager or some other host with write access to the backup location.
Since this script will be running on multiple hosts potentially accessing the same files at the same time - a simplistic (Non-bulletproof) locking system
has been implemented to accomodate for some of the issues regarding thread safety during file access operations.

A hidden file with name of the host and the extension '.lock' will be created for each system actively moving files. 
The system deleting files will wait for all locks to be removed before commencing the deletion procedure.

The script is designed to allow multiple simultanious "Movers" but only a single "Deleter".

The script assumes your Data Processors is set to "ArchiveByEntity".

Default values:
1. Files older than 7 days will be moved to the backup location.
2. Files older than 366 days will be deleted from the backup location.

.EXAMPLE
.\ArchiveManagement.ps1 -source "C:\LogRhythmArchives\Inactive" -destination "C:\BackupArchives"
.PARAMETER source
The path to the LogRhythm Inactive Archives folder
.PARAMETER destination
The path to the location where you want to move the inactive archives too
.PARAMETER deleteHost
The name of the host which will be responsible of deleting old backed up files from the backup location
.NOTES
Author: Mathias Nordahl
Revision: 1.0
.LINK
https://github.com/nullbytedk/LogRhythm-Utilities/ArchiveManagement
#>
param(
        [Parameter(Mandatory=$true)][string]$source,
        [Parameter(Mandatory=$true)][string]$destination,
        [Parameter(Mandatory=$true)][string]$deleteHost
)
function Util-Exit(){ #Function used to log a message before terminating the script (usually on errors)
    param(
        [Parameter(Mandatory=$true)][string]$message
    )
    Write-Host -ForegroundColor Red $message
    exit(1)
}
function Move-Archives(){ #Function to move files from one location to another which are older than a specified amount of days
    param(
        [Parameter(Mandatory=$true)][string]$source,
        [Parameter(Mandatory=$true)][string]$destination,
        [Parameter(Mandatory=$true)][int]$age
    )

    try{
        #Create lock file used for synchronization
        $lockfile = "$destination\$($env:COMPUTERNAME).lock" 
        New-Item -Path $lockfile | Out-Null
        (Get-Item $lockfile).Attributes = 'ReadOnly','Hidden' #Make the file hidden and readonly

        $olderthan = (Get-Date).AddDays(-$age).ToString("yyyMMdd") #Compute the date used to check if files are old and should be moved

        Get-ChildItem -Path $source -Directory | foreach { #Iterate the folders for each entity
            $sourceDirectoryFullName = $_.FullName
            $sourceDirectoryName = $_.Name
        
            if (-not (Test-Path -LiteralPath "$destination\$sourceDirectoryName")) { #If the folder does not exist on the backup location
                try {
                    New-Item -Path "$destination\$sourceDirectoryName" -ItemType Directory -ErrorAction Stop | Out-Null #Create a new folder
                    Write-Host -ForegroundColor Yellow "Successfully created directory '$destination\$sourceDirectoryName'."
                }
                catch {
                    Util-Exit -message "Unable to create directory '$destination\$sourceDirectoryName'. Error was: $($_.Exception.Message)"
                }
                
            }
        
            Get-ChildItem -Path $sourceDirectoryFullName | foreach { #For each archive folder under each entity
                if($_.Name.Split("_")[0] -lt $olderthan){ #Check if the file is too old and should be moved
                    Move-Item $_.FullName "$destination\$sourceDirectoryName\$($_.Name)" #Move the file
                    Write-Host -ForegroundColor Green "Moved File: $destination\$sourceDirectoryName\$($_.Name)"
                }
            }
        }
        Start-Sleep(1) #Sleep to avoid too fast exit if no files to move
        Remove-Item -Path $lockfile -Force #Remove the lock file
    }catch{
        Util-Exit -message "An unhandled error occurred '$($_.Exception.Message)'."
    }
}
function Delete-Archives(){
    param(
        [Parameter(Mandatory=$true)][string]$target,
        [Parameter(Mandatory=$true)][int]$age,
        [Parameter(Mandatory=$false)][int]$retries = 10,
        [Parameter(Mandatory=$false)][int]$retryInterval = 1,
        [Parameter(Mandatory=$false)][int]$lockGracePeriod = 10
    )
    try{
        $retryAttempts = $retries
        while($retryAttempts -ne 0){ #Retry mechanism in case a .lock file is found
            if((Get-ChildItem -Path $target -File -Filter "*.lock" -Force).Count -eq 0){ #Check for .lock files indicating a host is moving data to backup location
                Write-Host -ForegroundColor Yellow "No .lock file found - waiting 10 seconds before commencing 2nd check."
                Start-Sleep($lockGracePeriod) #If no .lock files were found, sleep 10 seconds to ensure a .lock file is not in the process of being created
                if((Get-ChildItem -Path $target -File -Filter "*.lock" -Force).Count -eq 0){ #ReCheck for .lock files indicating a host is moving data to backup location
                    Write-Host -ForegroundColor Yellow "No .lock file found - commencing file deletion."

                    $olderthan = (Get-Date).AddDays(-$age).ToString("yyyMMdd") #Compute the date used to check if files are old and should be deleted

                    Get-ChildItem -Path $target -Directory | foreach { #Iterate the folders for each entity
                        $targetDirectoryFullName = $_.FullName
                    
                        Get-ChildItem -Path $targetDirectoryFullName | foreach { #For each archive folder under each entity
                            if($_.Name.Split("_")[0] -lt $olderthan){ #Check if the file is too old and should be deleted
                                Remove-Item "$targetDirectoryFullName\$($_.Name)" -Recurse -Force #Delete the file
                            }
                        }
                    }
                    break;
                }else{
                    Write-Host -ForegroundColor Red "Second Check - Lock Found - Retries: $retryAttempts"
                    $retryAttempts--
                }
            }else{
                Write-Host -ForegroundColor Red "First Check - Lock Found - Retries: $retryAttempts"
                $retryAttempts--
            }
            Start-Sleep($retryInterval)
        }
        Write-Host -ForegroundColor Red "Aborting file deletion after $retries retries."
    }catch{
        Util-Exit -message "An unhandled error occurred '$($_.Exception.Message)'."
    }
}

if(-not ((Test-Path -LiteralPath $source) -or (Test-Path -LiteralPath $destination))){ #Verify that both the source and destination paths provided exists
    Util-Exit -message "Either the source or destination path is invalid. Please provide a valid path for both values." 
}

if((![string]::IsNullOrEmpty($deleteHost)) -and ($env:COMPUTERNAME.Equals($deleteHost))){ #If this is the deleting host, execute delete procedure
    Delete-Archives -target $destination -age 366
}else{ #else execute the move procedure
    Move-Archives -source $source -destination $destination -age 7
}