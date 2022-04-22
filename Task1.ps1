<#
    Description: Script which helps import AD users from CSV file.
    Assumpions: The csv file is in the script folder and user enter filename with extension. OU is default Users.
    Prerequsite: Powershell AD module.
    Date of creation: 21.04.2022
    Version: 1.0
    Author: Pawel Kudyba
#>
param (
    [Parameter(Mandatory=$true)]  
    #Filename mandatory parameter
    [string]$Filename,
    [Parameter(Mandatory=$true)]
    #Domainname mandatory parameter
    [string]$Domainname
)

#Load Windows Forms for MessageBox
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

#Test existance of file
If((Test-Path -Path $PSScriptRoot\$Filename -PathType Leaf) -eq $true)
{
    #Import data from csv
    $Csv = Import-Csv $PSScriptRoot\$Filename -Delimiter ';'
    foreach ($Csvi in $Csv)
    {
        #Check account name length
        If ($Csvi.AccountName.Length -ge 21 -OR $Csvi.AccountName.Length -eq 0)
        {
            #MessageBox with error about account name length
            $Result = [System.Windows.Forms.MessageBox]::Show("To much letter in AccountName: " + $Csvi.AccountName + "`r`Do you want to skip and continiue import?" , "Warning" , 4)
            if ($Result -ne 'Yes') 
            {
                break
            }
            else 
            {
               continue
            }
        }
        #Address email name convention
        $Emailregex = '^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$'
        #Check email corrent format
        if ($Csvi.Email -notmatch $Emailregex ) 
        {
            #MessageBox with error about wrong email format
            $Result = [System.Windows.Forms.MessageBox]::Show("The email address is incorret: " + $Csvi.Email + "`r`Do you want to skip and continiue import?" , "Warning" , 4)
            if ($Result -ne 'Yes') 
            {
                break
            }
            else 
            {
               continue
            }
        }
        #Trying to add new AD user
        try{
        New-ADUser -Name $Csvi.AccountName -DisplayName $Csvi.DisplayName -UserPrincipalName ($Csvi.AccountName + "@" + $Domainname) -EmailAddress $Csvi.Email
        Write-Host "New user imported" -ForegroundColor Green
        Write-Host "Name: " $Csvi.AccountName -ForegroundColor Green
        Write-Host "DisplayName: " $Csvi.DisplayName -ForegroundColor Green
        Write-Host "UserPrincipalName: " ($Csvi.AccountName + "@" + $Domainname) -ForegroundColor Green
        Write-Host "Email:" $Csvi.Email -ForegroundColor Green
        Write-Host ""
        }
        #Catch formula for errors from AD
        catch
        {
        Write-Host "Can't import user: " $_ -ForegroundColor Red
        Write-Host "Name: " $Csvi.AccountName -ForegroundColor Red
        Write-Host "DisplayName: " $Csvi.DisplayName -ForegroundColor Red
        Write-Host "UserPrincipalName: " ($Csvi.AccountName + "@" + $Domainname) -ForegroundColor Red
        Write-Host "Email:" $Csvi.Email -ForegroundColor Red
        Write-Host ""
        }
    } 
}
else 
    {
        #MessageBox with error about wrong file
        [System.Windows.MessageBox]::Show("It is not correct file: " + "$PSScriptRoot\$Filename")
        break;
    }