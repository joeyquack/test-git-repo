# Import the required module for Active Directory
Import-Module ActiveDirectory

# Define the path to the CSV file
$csvPath = "C:\path\to\your\usernames.csv"

# Read the usernames from the CSV document
$usernames = Import-Csv -Path $csvPath

# Iterate through each username and check for the -a account in Active Directory
foreach ($username in $usernames) {
    $accountName = $username.Username
    $accountNameA = $accountName + "-a"

    # Try to get the -a account from Active Directory
    $accountA = Get-ADUser -Filter "SamAccountName -eq '$accountNameA'" -Properties Enabled -ErrorAction SilentlyContinue

    if ($accountA) {
        # Check if the account is enabled
        if ($accountA.Enabled) {
            # Account is active, mark it green
            Write-Host "$accountNameA is active." -ForegroundColor Green
        } else {
            # Account is disabled, mark it red
            Write-Host "$accountNameA is disabled." -ForegroundColor Red
        }
    } else {
        # Account does not exist
        Write-Host "No -a account present for $accountName." -ForegroundColor Yellow
    }
}
