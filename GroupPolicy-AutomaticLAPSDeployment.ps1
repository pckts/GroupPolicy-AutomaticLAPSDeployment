# Deploys and configures LAPS in a domain enviornment
# Must be run on a DC

# Note: Non-functional due to GPO download source deletion.

#========#
# ^^^^^^ #
# README #
#========#

########################################################################################################################################################################################################################


#Detects if the script is run in admin context, if it is not, the script will exit after letting the user know.
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -eq $false)
{
    cls
    write-warning "Script needs to be run as admin."
    break
}

#Sets the TLS settings to allow downloads via HTTP
#Downloads, installs, and imports neccesary modules
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = "SilentlyContinue"
#====================================#
# Please add neccesary modules below #
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV #
#====================================#


#Import-module AdmPwd.PS
# is done later due to dependency issues

#install-module PSAppDeployToolkit
# Put in for use in later version.

#import-module PSAppDeployToolkit  
# Put in for use in later version.


#====================================#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #
# Please add neccesary modules above #
#====================================#

#Shows the startup banner main menu.
$MainMenu01 = 
{
    sleep 1
    cls
    write-host "";
    write-host "                                       " -BackGroundColor Black -NoNewLine; write-host "By packet" -ForeGroundColor Red -BackGroundColor Black -NoNewLine; write-host "                                     " -BackGroundColor Black
    write-host "         " -BackGroundColor Black -NoNewLine; write-host " █████╗ ██╗   ██╗████████╗ ██████╗ ██╗      █████╗ ██████╗ ███████╗" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "         " -BackGroundColor Black
    write-host "         " -BackGroundColor Black -NoNewLine; write-host "██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗██║     ██╔══██╗██╔══██╗██╔════╝" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "         " -BackGroundColor Black
    write-host "         " -BackGroundColor Black -NoNewLine; write-host "███████║██║   ██║   ██║   ██║   ██║██║     ███████║██████╔╝███████╗" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "         " -BackGroundColor Black
    write-host "         " -BackGroundColor Black -NoNewLine; write-host "██╔══██║██║   ██║   ██║   ██║   ██║██║     ██╔══██║██╔═══╝ ╚════██║" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "         " -BackGroundColor Black
    write-host "         " -BackGroundColor Black -NoNewLine; write-host "██║  ██║╚██████╔╝   ██║   ╚██████╔╝███████╗██║  ██║██║     ███████║" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "         " -BackGroundColor Black
    write-host "         " -BackGroundColor Black -NoNewLine; write-host "╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝" -ForeGroundColor Darkyellow -BackGroundColor Black -NoNewLine; write-host "         " -BackGroundColor Black
    write-host "                                                                                     " -BackGroundColor Black
    write-host "+---FUNCTIONS------------------------+" -BackGroundColor Black -NoNewLine; write-host "---README-------------------------------------+" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|1. (Deploy) Deploy LAPS             |" -BackGroundColor Black -NoNewLine; write-host " This script deploys or removes Microsoft LAPS|" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|                                    |" -BackGroundColor Black -NoNewLine; write-host " across an organisations domain.              |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|------------------------------------|" -BackGroundColor Black -NoNewLine; write-host "                                              |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|2. (Remove) Removes LAPS deployments|" -BackGroundColor Black -NoNewLine; write-host "                                              |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "|            made with this script   |" -BackGroundColor Black -NoNewLine; write-host "                             (CTRL+C to exit) |" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host "+------------------------------------+" -BackGroundColor Black -NoNewLine; write-host "----------------------------------------------+" -ForeGroundColor DarkGray -BackGroundColor Black
    write-host ""
    $MainMenuFunction01 = read-host "Select function (1/2)"
    
    #If neither function 1 or function 2 is selected, the user is returned to the main menu. This forces the user to make a valid choice.
    if ($MainMenuFunction01 -ne "1" -and $MainMenuFunction01 -ne "2")
    {
        &@MainMenu01
    }

    #If function 2 is selected, everything generated by function 1 will be removed:
    if ($MainMenuFunction01 -eq "2")
    {
        #Detects Group policies that follow the scripts naming convention
        $ExistingLAPS01 = Get-GPO -All | Where-Object {$_.displayname -like "Parceu_AutoLAPS_*"}
        
        #If any are found, they will be removed
        if ($ExistingLAPS01 -ne $null)
        {
            Remove-GPO -Name Parceu_AutoLAPS_DeviceInstallation
            Remove-GPO -Name Parceu_AutoLAPS_Configuration
        }

        #If none are found, a variable will be set for later
        else
        {
            $ExistingLAPSResult01 = $false
        }

        #Detects the generated folder
        $ExistingLAPS02 = Test-Path -Path C:\Parceu_AutoLAPS\

        #If found, it will be removed
        if ($ExistingLAPS02 -eq $true)
        {
            Remove-Item –path C:\Parceu_AutoLAPS\ –recurse -Force
        }

        #If not found, a variable will be set for later
        else
        {
            $ExistingLAPSResult02 = $false
        }

        #If neither any GPOs or the folder is found, it will let the user know and then return to main menu.
        if ($ExistingLAPSResult01 -eq $false -and $ExistingLAPSResult02 -eq $false)
        {
            cls
            write-host ""
            write-host "No existing deployment by this script detected" -ForegroundColor Red
            write-host "Returning to main menu..."
            write-host ""
            sleep 1
            &@MainMenu01
        }
        #If either is found and therefor removed, it will let the user know and then return to the main menu.
        cls
        write-host ""
        write-host "Existing deployment has now been removed" -ForegroundColor Green
        write-warning "Any existing installations of the LAPS software will NOT be automatically uninstalled anywhere"
        pause
        cls
        &@MainMenu01
    }
    #If function 1 is selected, the code breaks out of the main menu and will continue from the below point.
}
&@MainMenu01
cls
#Function 1 starts here
#===================================#
# Please add functional code  below #
# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV #
#===================================#

#Creates the folder where the LAPS files will be stored
New-Item -ItemType "directory" -Path "C:\Parceu_AutoLAPS"

#Creates the folder where the LAPS GPO files will be temporarily stored
New-Item -ItemType "directory" -Path "C:\Parceu_AutoLAPSInstall"

#Downloads the LAPS MSI installer to the previously generated AutoLAPS folder
Invoke-WebRequest -Uri https://download.microsoft.com/download/C/7/A/C7AAD914-A8A6-4904-88A1-29E657445D03/LAPS.x64.msi -OutFile C:\Parceu_AutoLAPS\LAPS.x64.msi

#Downloads the AutoLAPS GPOs to the temporary AutoLAPS folder
$GPOURL = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("aHR0cHM6Ly9naXRodWIuY29tL3Bja3RzL1ByaW50TmlnaHRtYXJlV29ya2Fyb3VuZC9yYXcvbWFpbi9HUE9zLnppcA=="))
Invoke-WebRequest -Uri $GPOURL -OutFile C:\Parceu_AutoLAPSInstall\GPOs.zip
sleep 1
 
#Installs LAPS including the management tools
msiexec.exe /i C:\Parceu_AutoLAPS\LAPS.x64.msi ADDLOCAL=CSE,Management,Management.UI,Management.PS,Management.ADMX /quiet

#Makes the AutoLAPS folder shared and allowing everyone to have read access. The only content of this folder is the publicly-available LAPS msi installer file.
New-SmbShare -Name LAPS -Path C:\Parceu_AutoLAPS | Grant-SmbShareAccess -AccountName Everyone -AccessRight Read

#Imports the LAPS module for powershell. This isn't done until this point due to being dependent on an installation of the management tools.
Import-module AdmPwd.PS

#Updates the AD Schema to make the newly installed LAPS features available.
Update-AdmPwdADSchema

#Imports the GPOs and links them at domain root and every inheritence blocked OU.
#The links will also be enforced.
$Partition01 = Get-ADDomainController | Select DefaultPartition
$GPOSource01 = "C:\Parceu_AutoLAPS\"
import-gpo -BackupId 6A1B280F-82A9-484D-AE16-3D278EDD65E7 -TargetName Parceu_AutoLAPS_DeviceInstallation -path $GPOSource01 -CreateIfNeeded
import-gpo -BackupId FA0E159B-5892-4D0B-B6A1-90FABC0ED38B -TargetName Parceu_AutoLAPS_Configuration -path $GPOSource01 -CreateIfNeeded
Get-GPO -Name "Parceu_AutoLAPS_Configuration" | New-GPLink -Target $Partition01.DefaultPartition
Get-GPO -Name "Parceu_AutoLAPS_DeviceInstallation" | New-GPLink -Target $Partition01.DefaultPartition
$Blocked01 = Get-ADOrganizationalUnit -Filter * | Get-GPInheritance | Where-Object {$_.GPOInheritanceBlocked} | select-object Path 
Foreach ($B01 in $Blocked01) 
{
    New-GPLink -Name "Parceu_AutoLAPS_Configuration" -Target $B01.Path
    New-GPLink -Name "Parceu_AutoLAPS_DeviceInstallation" -Target $B01.Path
    Set-GPLink -Name "Parceu_AutoLAPS_Configuration" -Enforced Yes -Target $B01.Path
    Set-GPLink -Name "Parceu_AutoLAPS_DeviceInstallation" -Enforced Yes -Target $B01.Path
}

#Sets permissions so that Domain Admins can read the password computers that LAPS is deployed to.
cls
write-host "Do you have multiple or custom OUs that contain computers?"
$MoreComputers = read-host -Prompt 'Yes/No?'
if ($MoreComputers = "yes" -or "y")
{
    $ComputerRAWs = Get-ADComputer -filter * | Select-Object DistinguishedName
    foreach ($ComputerRAW in $ComputerRAWs)
    {
        $ComputerOU = $ComputerRAW | ForEach-Object{($_ -split "," | Select-Object -Skip 1) -join ","}
        $ComputerDN = $ComputerOU.Substring(0,$ComputerOU.Length-1)
        $PermsGiven = Find-AdmPwdExtendedRights -Identity "$ComputerDN"
        if ($PermsGiven = "")
        {
            Set-AdmPwdComputerSelfPermission $ComputerDN
            Set-AdmPwdReadPasswordPermission $ComputerDN -AllowedPrincipals "Domain Admins"
            cls
        }
    }
}
else
{
    Set-AdmPwdComputerSelfPermission CN=Computers,$domainDN
    Set-AdmPwdComputerSelfPermission OU=Domain Controllers,$domainDN
    Set-AdmPwdReadPasswordPermission CN=Computers,$domainDN -AllowedPrincipals "Domain Admins"
    Set-AdmPwdReadPasswordPermission OU=Domain Controllers,$domainDN -AllowedPrincipals "Domain Admins"
    cls
}

#===================================#
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #
# Please add functional code  above #
#===================================#
