﻿<#
.SYNOPSIS
EasyPeasyZippingScript.ps1 - Easy script zipping files.

.DESCRIPTION 
Easy script for wrapping files into the archive older than given period deleting them from the source folder and saving the .zip file into the destination folder.

.OUTPUTS
Output is the .zip file with name that is set by curent date/time.

.EXAMPLE
.\EasyPeasyZippingScript.ps1 -Age_Of_Backuped_Data 90 -Search_Folder D:\Search_here -Destination_Folder D:\Archives_here -Staging_Folder D:\Staging_here -LogFile logfile.log
Moves items from "D:\Search_here" to staging folder in "D:\Staging_here", zips that staging folder. Moves archive to "D:\Archives_here" and clears the "D:\Staging_here."

.LINK
https://paweljarosz.wordpress.com/2016/05/02/easy-peasy-zipping-powershell-script

.NOTES
Written by: Paweł Jarosz (aka. zaicnupagadi)

Find me on:
* My Blog:	https://paweljarosz.wordpress.com/
* LinkedIn:	https://www.linkedin.com/in/paweljarosz2
* GoldenLine: 	http://www.goldenline.pl/pawel-jarosz2/
* Github:	https://github.com/zaicnupagadi


Change Log:
V1.00, 01/05/2016 - Initial version

#>

param(
	[Parameter(Mandatory=$True)]
    [int]$Age_Of_Backuped_Data,

	[Parameter(Mandatory=$True)]
    [string]$Search_Folder,

	[Parameter(Mandatory=$True)]
    [string]$Destination_Folder,

	[Parameter(Mandatory=$True)]
    [string]$Staging_Folder,
    
    [Parameter(Mandatory=$True)]
    [string]$LogFile
    
    )

if ($Age_Of_Backuped_Data -and $Search_Folder -and $Destination_Folder -and $Staging_Folder) {

$nowfile = Get-Date -format "dd-MM-yyyy_HH_mm_ss"
$nowlog = Get-Date -format "dd-MM-yyyy HH:mm:ss"

$DllLocation = "Drive_Or_ShareName\Path\To\The\System.IO.Compression.FileSystem.dll"



if ($Search_Folder.Substring($Search_Folder.Length-1,1) -ne "\"){
$Search_Folder = $Search_Folder+"\"
}

if ($Destination_Folder.Substring($Destination_Folder.Length-1,1) -ne "\"){
$Destination_Folder = $Destination_Folder+"\"
}

if ($Staging_Folder.Substring($Staging_Folder.Length-1,1) -ne "\"){
$Staging_Folder = $Staging_Folder+"\"
}

<#$Age_Of_Backuped_Data = 90
$Search_Folder = "Drive_Or_ShareName\Path\To\The\Search_Folder\"
$Staging_Folder = "Drive_Or_ShareName\Path\To\The\Staging_Folder\"
$Destination_Folder = "Drive_Or_ShareName\Path\To\The\DestinationFolder\"
$LogFile = "Drive_Or_ShareName\Path\To\The\Backup.log"
#>

function ZipFiles( $zipfilename, $sourcedir )
{
     Add-Type -path $DllLocation 
     $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
     [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir, 
                                                          $zipfilename,
                                                          $compressionLevel, 
                                                          $false)
}


$FilesToBackup = (Get-ChildItem $Search_Folder | ? {$_.CreationTime -lt (Get-Date).AddDays(-$Age_Of_Backuped_Data)})

if ($FilesToBackup){
    ForEach ($File in $FilesToBackup) {
    Move-item "$Search_Folder$File" "$Staging_Folder"
    "$nowlog INFO: File $Search_Folder$File has been moved to staging area" >> $LogFile
    }


    if (Get-ChildItem $Staging_Folder){
    zipfiles "$Destination_Folder$nowfile.zip" "$Staging_Folder"
    "$nowlog INFO: Zip file $Destination_Folder$nowfile.zip is being created" >> $LogFile
    
        if (Test-Path ("$Destination_Folder$nowfile.zip")) {
        Remove-Item "$Staging_Folder*"
        "$nowlog INFO: ZIP file has been created - staging Folder has been cleared" >> $LogFile
        } else {
        "$nowlog ERROR: ZIP file has not been created, Administrative action required" >> $LogFile
        }

    } else {
    "$nowlog WARNING: Staging Area is Empty, no files older than 90 days" >> $LogFile
    }

} else {
Write-Host "You need to give all parameters"
}
