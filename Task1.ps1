<#
    Script description.

    Some notes.
#>
param (
    [Parameter(Mandatory=$false)]  
    # name of the output image
    [string]$nameoffile
    [string]$Domainname
)

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$nameoffile = "test.csv"
If((Test-Path -Path $PSScriptRoot\$nameoffile -PathType Leaf) -eq $true)
{
    #$csv = Import-Csv desktop\4test.csv -Delimiter ';'
    $csv = Import-Csv $PSScriptRoot\$nameoffile -Delimiter ';'
    foreach ($csvi in $csv)
    {
        If ($csvi.AccountName.Length -gt 21)
        {
            $result = [System.Windows.Forms.MessageBox]::Show("To much letter in AccountName: " + $csvi.AccountName + "`r`Do you want to skip and continiue import?" , "Warning" , 4)
            if ($result -ne 'Yes') 
            {
                break
            }
            else 
            {
               continue
            }
        }
        $EmailRegex = '^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$'
        if ($csvi.Email -notmatch $EmailRegex) 
        {
            $result = [System.Windows.Forms.MessageBox]::Show("The email address is incorret: " + $csvi.Email + "`r`Do you want to skip and continiue import?" , "Warning" , 4)
            if ($result -ne 'Yes') 
            {
                break
            }
            else 
            {
               continue
            }
        }
        Write-host $csvi.email
        #New-ADUser -SamAccountName $csvi.AccountName -ChangePasswordAtLogon $True -DisplayName $csvi.DisplayNameee -UserPrincipalName $AccountName+@+$Domainname -EmailAddress $csvi.Email
    } 
}
else 
    {
        [System.Windows.MessageBox]::Show("It is not correct file: " + "$PSScriptRoot\$nameoffile")
        break;
    }