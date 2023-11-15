function accountscript2 {

# Import the required module for Active Directory
Import-Module ActiveDirectory

# Define the path to the CSV file
$csvPath = "D:\Users\jshamoon\Desktop\scriptdocuments\usernames.csv"

# Read the usernames from the CSV document
$usernames = Import-Csv -Path $csvPath

# Define the group names
$adminGroup = "LSEG-DXD-DEV-ADMIN"
$standardGroup1 = "FUNC-BeyondTrust-StandardAccounts"
$standardGroup2 = "POL-BeyondTrust-Password-AutoApproval"

# Initialize a variable to keep track of the previous user processed
    $previousUser = $null

# Iterate through each username and check for the -a account in Active Directory
foreach ($username in $usernames) {
    $accountName = $username.usernames
    $accountNameA = $accountName + "-a"
    
   
   
    # If the current user is different from the previous one, add a blank line
        if ($previousUser -ne $accountName -and $previousUser -ne $null) {
       
            Write-Host "" 
        }

        # Update the previous user to the current one
        $previousUser = $accountName
        # Output the username being processed for clarity
        
        Write-Host "Processing $accountName and $accountNameA accounts:" -ForegroundColor Cyan
    
    # Try to get the -a account from Active Directory
    $accountA = Get-ADUser -Filter "SamAccountName -eq '$accountNameA'" -Properties Enabled -ErrorAction SilentlyContinue
    
    if ($accountA) {
        # Check if the account is enabled
        if ($accountA.Enabled) {
        
        # Check if the -A account is part of the LSEG-DXD-DEV-ADMIN group
            $groups = Get-ADPrincipalGroupMembership $accountA | Select-Object -ExpandProperty Name
            if ($adminGroup -in $groups) {
            Write-Host "$accountA is active and a member of $adminGroup." -ForegroundColor Green
            } else {
            Write-Host "$accountNameA is active but not a member of the $adminGroup." -ForegroundColor Yellow
            }
            } else {
            # Account is disabled, mark it red
            Write-Host "$accountNameA is DISABLED." -ForegroundColor Red


        }
    } else {
        # Account does not exist
        Write-Host "No -A Admin Account Present for $accountName. Raise Service Request" -ForegroundColor Red
    }




    # Check if the standard account is part of the required groups
    $standardAccount = Get-ADUser -Filter "SamAccountName -eq '$accountName'" -Properties Enabled -ErrorAction SilentlyContinue
  

    if ($standardAccount) {
    # Check if the Standard Account is Enabled
        if (-not $standardAccount.Enabled) {
        Write-Host "$accountName standard account is DISABLED." -ForegroundColor Red
        } else {
        # The account is enabled, proceed with group membership checks
        }
       
        $standardGroups = Get-AdPrincipalGroupMembership $standardAccount | Select-Object -ExpandProperty Name
          
        # Check for membership in FUNC-BEYONDTRUST-STANDARDACCOUNTS

        $group1Check = $standardgroup1 -in $standardGroups
        if ($group1Check) {
        Write-Host "$accountName is a member of $standardGroup1." -ForegroundColor Green
        } else {
            Write-Host "$accountName is not a member of $standardGroup1." -ForegroundColor Yellow
            }
            # Check for membership in POL-BEYONDTRUST-PASSWORD-ENFORCEDSESSION
            
            $group2Check = $standardGroup2 -in $standardGroups
            if ($group2Check) {
            Write-Host "$AccountName is a member of $standardGroup2." -ForegroundColor Green
            } else {
            Write-Host "$accountname is not a member of $standardGroup2." -ForegroundColor Yellow
            }
          
                    
                    } else {
                    Write-Host "Standard account for $accountName does not exist." -ForegroundColor Yellow

       

                    
                    }
                    }
                    }

                


