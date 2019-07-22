# LogRhythm LPS Log Parser
## LPS-Parser-GUI.ps1

### COMPATABILITY
LogRhythm 7.4.6

### SYNOPSIS
GUI program for analysing LPS logfiles from LogRhythm Mediators, that enables you to easily find the statistics you are looking for.

### DESCRIPTION
The program loads the "lps_detail_snapshot.log" from the LogRhythm Mediator and provides a nice graphical way of interacting with the statistics.

When you launch the program, choose "File" in the upper lefthand menu and choose "Open" to select your snapshot file.
This will parse the file and load statistics for each LPS into memory. Once the loading is finished (typically a few seconds) you can use the dropdowns to select your logsource type and which of your LPS policies you want to view the statistics for.

DISCLAIMER:
No particular care has been taken to error handling.
