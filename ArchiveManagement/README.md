# LogRhythm Archive Management
## ArchiveManagement.ps1

### SYNOPSIS
Utility to manage LogRhythm Archives files

### DESCRIPTION
**DISCLAIMER: Deleting Inactive Archives is NOT advised, ever!**

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

### EXAMPLE
```
.\ArchiveManagement.ps1 -source "C:\LogRhythmArchives\Inactive" -destination "C:\BackupArchives"
```

### PARAMETER source
The path to the LogRhythm Inactive Archives folder

### PARAMETER destination
The path to the location where you want to move the inactive archives too

### PARAMETER deleteHost
The name of the host which will be responsible of deleting old backed up files from the backup location

### NOTES
Author: Mathias Nordahl
Revision: 1.0
