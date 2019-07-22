 <#
.SYNOPSIS
    GUI program for analysing LPS logfiles from LogRhythm Mediators, that enables you to easily find the statistics you are looking for.
.DESCRIPTION
    The program loads the "lps_detail_snapshot.log" from the LogRhythm Mediator and provides a nice graphical way of interacting with the statistics.
.NOTES
    Author: Mathias Nordahl Rasmussen
    Date:   May 15, 2019   
    Revision: 1.0 
.LINK
    https://github.com/nullbytedk/LogRhythm-Utilities/blob/master/LPS%20Parser/LPS-Parser-GUI.ps1
#>

$global:statistics = $null

#----------------------------------GUI STUFF BEGIN---------------------------------------------
Function Get-File{ #Funtion to display filepicker dialog
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = Get-Location
    $OpenFileDialog.filter = "LOG (*.log)| *.log" #Regex matching file types to look for
    $OpenFileDialog.Title = "Choose LPS Logfile" #Window text
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename #The value returned from the function
}

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$CenterScreen = [System.Windows.Forms.FormStartPosition]::CenterScreen;

$Form                               = New-Object system.Windows.Forms.Form
$Form.ClientSize                    = '885,622'
$Form.text                          = "LPS Parser"
$Form.MinimumSize                   = [System.Drawing.Size]::new(900,600)
$Form.TopMost                       = $false
$Form.StartPosition                 = $CenterScreen

$InfoDialog                         = New-Object system.Windows.Forms.Form
$InfoDialog.Text                    = "File Information"
$InfoDialog.StartPosition           = $CenterScreen


$MenuBar = New-Object System.Windows.Forms.MenuStrip
$MenuBar.BackColor = [System.Drawing.Color]::White

$FileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$OpenMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$InfoMenu = New-Object System.Windows.Forms.ToolStripMenuItem

$FileMenu.Text = "&File"
$OpenMenu.Text = "Open"
$InfoMenu.Text = "Information"

$OpenMenu.Add_Click({
    $filelocation = Get-File
    Invoke-ParseStatistics -file $filelocation
})
$InfoMenu.Add_Click({
    $InfoDialog.ShowDialog()
})

$MenuBar.Items.Add($FileMenu) | Out-Null
$FileMenu.DropDownItems.Add($OpenMenu) | Out-Null
$FileMenu.DropDownItems.Add($InfoMenu) | Out-Null

$ComboLogsourceType                 = New-Object system.Windows.Forms.ComboBox
$ComboPolicy                        = New-Object system.Windows.Forms.ComboBox
$DatagridRules                      = New-Object system.Windows.Forms.DataGridView
$LabelTotalCompares                 = New-Object System.Windows.Forms.Label
$LabelMPS                           = New-Object System.Windows.Forms.Label
$LabelLicense                       = New-Object System.Windows.Forms.Label
$LabelMediator                      = New-Object System.Windows.Forms.Label
$LabelKnowledge                     = New-Object System.Windows.Forms.Label
$LabelStart                         = New-Object System.Windows.Forms.Label
$LabelEnd                           = New-Object System.Windows.Forms.Label
$LabelTime                          = New-Object System.Windows.Forms.Label

$ComboLogsourceType.text            = "Logsource Type"
$ComboPolicy.text                   = "Policy"
$LabelTotalCompares.Text            = "Total Compares: "
$LabelMPS.Text                      = "Average MPS: "
$LabelLicense.Text                  = "License ID: N/A"
$LabelMediator.Text                 = "Mediator Version: N/A"
$LabelKnowledge.Text                = "KB Version: N/A"
$LabelStart.Text                    = "Start Date: N/A"
$LabelEnd.Text                      = "End Date: N/A"
$LabelTime.Text                     = "Total Time: N/A"

$ComboLogsourceType.width           = 455
$ComboPolicy.width                  = 300
$DatagridRules.width                = 775
$LabelTotalCompares.Width           = 300
$LabelMPS.Width                     = 300
$LabelLicense.Width                 = 300
$LabelMediator.Width                = 300
$LabelKnowledge.Width               = 300
$LabelStart.Width                   = 300
$LabelEnd.Width                     = 300
$LabelTime.Width                    = 300

$ComboLogsourceType.height          = 30
$ComboPolicy.height                 = 30
$DatagridRules.height               = 435
$LabelTotalCompares.Height          = 25
$LabelMPS.Height                    = 25
$LabelLicense.Height                = 18
$LabelMediator.Height               = 18
$LabelKnowledge.Height              = 18
$LabelStart.Height                  = 18
$LabelEnd.Height                    = 18
$LabelTime.Height                   = 18

$ComboLogsourceType.location        = New-Object System.Drawing.Point(62,40)
$ComboPolicy.location               = New-Object System.Drawing.Point($($ComboLogsourceType.Right+20),40)
$DatagridRules.location             = New-Object System.Drawing.Point(60,140)
$LabelTotalCompares.location        = New-Object System.Drawing.Point(60,80)
$LabelMPS.location                  = New-Object System.Drawing.Point(400,80)
$LabelLicense.location              = New-Object System.Drawing.Point(10,30)
$LabelMediator.location             = New-Object System.Drawing.Point(10,60)
$LabelKnowledge.location            = New-Object System.Drawing.Point(10,90)
$LabelStart.location                = New-Object System.Drawing.Point(10,120)
$LabelEnd.location                  = New-Object System.Drawing.Point(10,150)
$LabelTime.location                 = New-Object System.Drawing.Point(10,180)

$ComboLogsourceType.Font            = 'Microsoft Sans Serif,10'
$ComboPolicy.Font                   = 'Microsoft Sans Serif,10'
$LabelTotalCompares.Font            = 'Microsoft Sans Serif,12'
$LabelMPS.Font                      = 'Microsoft Sans Serif,12'
$LabelTotalCompares.Font            = [System.Drawing.Font]::new($LabelTotalCompares.Font, [System.Drawing.FontStyle]::Bold)
$LabelMPS.Font                      = [System.Drawing.Font]::new($LabelMPS.Font, [System.Drawing.FontStyle]::Bold)
$LabelLicense.Font                  = 'Microsoft Sans Serif,10'
$LabelMediator.Font                 = 'Microsoft Sans Serif,10'
$LabelKnowledge.Font                = 'Microsoft Sans Serif,10'
$LabelStart.Font                    = 'Microsoft Sans Serif,10'
$LabelEnd.Font                      = 'Microsoft Sans Serif,10'
$LabelTime.Font                     = 'Microsoft Sans Serif,10'

$ComboLogsourceType.anchor          = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
$ComboPolicy.anchor                 = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
$DatagridRules.anchor               = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom


$DatagridRules.ReadOnly             = $true
$DatagridRules.AllowUserToAddRows   = $false


$Form.controls.AddRange(@($ComboLogsourceType,$ComboPolicy,$DatagridRules,$MenuBar,$LabelTotalCompares))
$InfoDialog.Controls.AddRange(@($LabelLicense,$LabelMediator, $LabelKnowledge, $LabelStart, $LabelEnd, $LabelTime))


Function Update-Datagrid {
    param(
        [Parameter(Mandatory=$true)][psobject]$items
    )

    $DatagridRules.Rows.Clear()
    $DatagridRules.ColumnCount = 18
    $DatagridRules.ColumnHeadersVisible = $true
    $DatagridRules.Columns[0].Name = "Name"
    $DatagridRules.Columns[1].Name = "Sort Order"
    $DatagridRules.Columns[2].Name = "Forward Events"
    $DatagridRules.Columns[3].Name = "Sort Type"
    $DatagridRules.Columns[4].Name = "Sub Rules"
    $DatagridRules.Columns[5].Name = "Attempts"
    $DatagridRules.Columns[6].Name = "Match %"
    $DatagridRules.Columns[7].Name = "Total Match %"
    $DatagridRules.Columns[8].Name = "LPS Regex Total"
    $DatagridRules.Columns[9].Name = "LPS Regex Match"
    $DatagridRules.Columns[10].Name = "LPS Regex No Match"
    $DatagridRules.Columns[11].Name = "LPS Rule Total"
    $DatagridRules.Columns[12].Name = "LPS Rule Match"
    $DatagridRules.Columns[13].Name = "LPS Rule No Match"
    $DatagridRules.Columns[14].Name = "Total Match EWMA %"
    $DatagridRules.Columns[15].Name = "LPS Rule No Match EWMA"
    $DatagridRules.Columns[16].Name = "Rule ID"
    $DatagridRules.Columns[17].Name = "Regex ID"

    $policy = @($items) | Where-Object {($_."logSourceType" -match $ComboLogsourceType.SelectedValue) -and ($_."mpePolicy" -match $ComboPolicy.SelectedValue)}
    $policy.rules | ForEach-Object {
        $DatagridRules.Rows.Add($_."name",$_."sort_order",$_."forward_events",$_."sort_type",$_."sub_rule_count",$_."attempts",$_."match_percentage",$_."total_match_percentage",$_."logs_per_second_regex_total"
        ,$_."logs_per_second_regex_match",$_."logs_per_second_regex_no_match",$_."logs_per_second_rule_total",$_."logs_per_second_rule_match",$_."logs_per_second_rule_no_match",$_."total_match_ewma_percentage"
        ,$_."logs_per_second_rule_no_match_ewma",$_."mpe_rule_id",$_."regex_id") | Out-Null
    }
    $DatagridRules.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill
    $DatagridRules.ColumnHeadersDefaultCellStyle.Font = [System.Drawing.Font]::new($DatagridRules.Font, [System.Drawing.FontStyle]::Bold)
    $DatagridRules.Columns | ForEach-Object { $_.SortMode = [System.Windows.Forms.DataGridViewColumnSortMode]::NotSortable}

    Write-Host $policy
    $LabelTotalCompares.Text = "Total Compares: $($policy.totalCompares)"
}

Function Update-Policy {
    param(
        [Parameter(Mandatory=$true)][psobject]$items
    )
    $policies = @($items) | Where-Object {$_."logSourceType" -match $ComboLogsourceType.SelectedValue}

    $ComboPolicy.DataSource=@($policies | Select -ExpandProperty mpePolicy)
    $ComboPolicy.DisplayMember='mpePolicy'
}

Function Update-GUI {
    Update-Policy -items $global:statistics.policies
    Update-Datagrid -items $global:statistics.policies
}


$ComboLogsourceType.Add_SelectedValueChanged({ 
    if($global:statistics -ne $null){
        Update-GUI
    }
})

$ComboPolicy.Add_SelectedValueChanged({ 
    if($global:statistics -ne $null){
        Update-Datagrid -items $global:statistics.policies
    }
})
#----------------------------------GUI STUFF END---------------------------------------------

Function Format-Policy {   
    param(
        [Parameter(Mandatory=$true)][string]$object
    )

    $lst_blob_lines = $object -split [environment]::NewLine

   
    if ($lst_blob_lines -Contains 'LogRhythm Log Processing Report') {
        # This blob contains general information, which we can pull out and work with, to determine interesting metadata
        <# 
        [0] LogRhythm Log Processing Report
        [1] Copyright 2013 LogRhythm, Inc.
        [2] Statistics Compiled on 08.16.2017 11:34 
        [3] LogRhythm Lic ID 1269111
        [4] KB Version       7.1.402.4
        [5] Mediator ID      1
        [6] Mediator Version 7.2.5.8006
        [7] Stat Collection Start 08.16.2017 08:42 
        [8] Stat Collection End   08.16.2017 11:34 
        #>
        if (-not $lst_blob_lines.Length -eq 11){
            throw [System.FormatException] "File header malformed. Expected 11 lines but found $($lines.Length)."
        }else{
            $global:licenceID = $lst_blob_lines[3].Split('ID')[-1].Trim()
            $global:kbVersion = $lst_blob_lines[4].Split('version')[-1].Trim()
            $global:mediatorVersion = $lst_blob_lines[6].Split('version')[-1].Trim()
            [DateTime]$global:logStart = $lst_blob_lines[7].Split('Start').Trim()[-1]
            [DateTime]$global:logEnd = $lst_blob_lines[8].Split('End').Trim()[-1]
            $global:totalSeconds = $(New-TimeSpan -Start $global:logStart -End $global:logEnd).TotalSeconds
            $global:totalDays = [math]::Round($($(New-TimeSpan -Start $global:logStart -End $global:logEnd).TotalDays), 2)	  
        }
        return $null
    }else{
        $ruleList = @()
        $mpe_policy = $lst_blob_lines[4].Split(':')[-1].Trim()
        $total_compares = $lst_blob_lines[5].Split(':')[-1].Trim().Replace(',', '').Replace("'", '').Replace('.','') #Total number of logs processed by the log source type. Includes all log sources of that log source type.
        $log_source_type = $lst_blob_lines[3].Split(':')[-1].Trim()

        if ([int]$total_compares -gt 0) {
            $average_MPS_for_log_source = [math]::Round($([int]$total_compares / [int]$global:totalSeconds), 2)
        } else {
            $average_MPS_for_log_source = 0
        }

        foreach ($rule in $lst_blob_lines[8..$lst_blob_lines.Length]) {
            # if the string is empty, or just spaces, move on
            if (-not $rule -or $rule -match '^\s+$' -or $rule -match '^\s*-+'){
                continue
            }else {

                $regexMatches = ($rule | Select-String '^(.*?)\s{3,}(\d+)\s+(\w+)\s+(\w+)\s+(\S+)\s+(\S+)\s+([^%\s]+)\s%\s+([^%\s]+)\s%\s+([^%\s]+)\s%\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)' -AllMatches).Matches[0]

                $rulename = $regexMatches.Groups[1].Value

                if($regexMatches.Groups.Count -eq 19){
                    $ruleObject = [PSCustomObject]@{
                        "name" = $regexMatches.Groups[1].Value; #MPE rule name
                        "sort_order" =  $regexMatches.Groups[2].Value; #Numerical sort order
                        "forward_events" = $regexMatches.Groups[3].Value; #Event forwarding enabled (True/False)
                        "sort_type" = $regexMatches.Groups[4].Value; #Whether a rule is auto-sorted (A), manually sorted (M), or has a sort-above (SAS)
                        "sub_rule_count" = $regexMatches.Groups[5].Value; #Number of active subrules
                        "attempts" = $regexMatches.Groups[6].Value; #Number of match attempts
                        "match_percentage" = $regexMatches.Groups[7].Value; #Percentage of remaining logs to be tested that matched a rule
                        "total_match_percentage" = $regexMatches.Groups[8].Value; #Percentage of all logs (from Total Compares) that matched a rule
                        "total_match_ewma_percentage" = $regexMatches.Groups[9].Value; #Exponentially Weighted Moving Average for Percentage Total Match Performance. Indicates what performance is currently (lower weight to historical)
                        "logs_per_second_regex_total" = $regexMatches.Groups[10].Value; #Total Logs Per Second Regular Expression  including Match and Non-Match performance
                        "logs_per_second_regex_match" = $regexMatches.Groups[11].Value; #Logs Per Second Regular Expression performance for matching logs
                        "logs_per_second_regex_no_match" = $regexMatches.Groups[12].Value; #Logs Per Second Regular Expression performance for non-matching logs
                        "logs_per_second_rule_total" = $regexMatches.Groups[13].Value; #Total Logs Per Second Rule performance, includes Regular Expression and Subrule match/non-match performance
                        "logs_per_second_rule_match" = $regexMatches.Groups[14].Value; #Logs Per Second Rule performance, includes Regular Expression and Subrule match performance
                        "logs_per_second_rule_no_match" = $regexMatches.Groups[15].Value; #Logs Per Second Rule performance, includes Regular Expression and Subrule non-match performance
                        "logs_per_second_rule_no_match_ewma" = $regexMatches.Groups[16].Value; #Exponentially Weighted Moving Average for Percentage Total Non-Match Performance. Indicates what performance is currently (lower weight to historical)
                        "mpe_rule_id" = $regexMatches.Groups[17].Value; #MPE rule ID
                        "regex_id" = $regexMatches.Groups[18].Value; #Regex ID
                    }

                    $ruleList += $ruleObject
                }else{
                    throw [System.FormatException] "An error occured parsing the MPE rule '$rulename'. The format of the rule statistics may be corrupted."
                }               
            }
        }

        $policy = [PSCustomObject]@{
            "logSourceType" = $log_source_type;
            "mpePolicy" = $mpe_policy;
            "averageMPS" = $average_MPS_for_log_source; 
            "totalCompares" = $total_compares;
            "rules" = $ruleList;
        }
        
        return $policy
    }
}

Function Get-Statistics {
    param(
        [Parameter(Mandatory=$true)]
        [string]$lpsfile,
        [Parameter(Mandatory=$false)]
        [int]$lpsRuleMatchTotal = 1000,
        [Parameter(Mandatory=$false)]
        [int]$lpsRuleNoMatchTotal = 1000

    )
    # Confirm either default location, or prompt
    if (-Not (Test-Path $lpsfile)) {
        throw [System.ArgumentException] "No file was found using the specified path. Please provide a path to a valid LPS logfile."
    }   

    # Ensure file contains precisely one occurrence of the stats
    $occurrences = $(Select-String $lpsfile -Pattern 'LogRhythm Log Processing Report').Length
	if ($occurrences -ne 1) {
		throw [System.FormatException] "File '$lpsfile' does not appear to be a valid lps_detail.log"
	}

    # Split entire file into logsource policy blobs
    $lppList = (Get-Content $lpsfile -Raw) -split '(?=Base-rule)'


    $policyList = @()
    # Loop through lpp blobs, parse each to an object
    $index = 0
    foreach ($lpp in $lppList) {
        $lppObject = Format-Policy -object $lpp
        if($lppObject){
            $policyList += $lppObject
        }  
        $index++          
    }  	   	 

    $statistics = [PSCustomObject]@{
        "license_id" = $licenceID;
        "mediator_version" = $mediatorVersion;
        "knowledgebase_version" = $kbVersion;
        "start_date" = $logStart;
        "end_date" = $logEnd;
        "total_time" = "$totalSeconds Seconds ($totalDays Days)"
        "policies" = $policyList
    }

    return $statistics
}

Function Invoke-ParseStatistics {
    param(
        [Parameter(Mandatory=$true)][string]$file
    )

    $global:statistics = Get-Statistics -lpsfile $file

    if($statistics){
        $LabelLicense.Text                  = "License ID: $($global:statistics.license_id)"
        $LabelMediator.Text                 = "Mediator Version: $($global:statistics.mediator_version)"
        $LabelKnowledge.Text                = "KB Version: $($global:statistics.knowledgebase_version)"
        $LabelStart.Text                    = "Start Date: $($global:statistics.start_date)"
        $LabelEnd.Text                      = "End Date: $($global:statistics.end_date)"
        $LabelTime.Text                     = "Total Time: $($global:statistics.total_time)"


        $ComboLogsourceType.DataSource=($global:statistics.policies | Select -ExpandProperty logSourceType -Unique)
        $ComboLogsourceType.DisplayMember='logSourceType'
    }
}

# This script requires PowerShell 3.0 or higher
if ($PSVersionTable.PSVersion -lt [Version]"3.0") {
    write-output "PowerShell version " $PSVersionTable.PSVersion "not supported.  This script requires PowerShell 3.0 or greater."
    exit
}

[void]$Form.ShowDialog()
