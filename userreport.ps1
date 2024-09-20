# Import the Active Directory module
Import-Module ActiveDirectory

try {
    # Define the path where the report will be saved
    $exportPath = "C:\Reports\UsersReport.csv"

    # Ensure the export directory exists
    $exportDirectory = Split-Path $exportPath
    if (-not (Test-Path $exportDirectory)) {
        New-Item -ItemType Directory -Path $exportDirectory | Out-Null
    }

    # Retrieve all users with specified properties
    $users = Get-ADUser -Filter * -Properties DisplayName, Department, TelephoneNumber, EmailAddress, LastLogonDate, SamAccountName

    # Create an array to store user information
    $userList = @()

    foreach ($user in $users) {
        # Prepare user information
        $userInfo = [PSCustomObject]@{
            UserName      = $user.SamAccountName
            Name          = $user.DisplayName
            Department    = $user.Department
            PhoneNumber   = $user.TelephoneNumber
            EmailAddress  = $user.EmailAddress
            LastLogonDate = $user.LastLogonDate
        }
        # Add user information to the list
        $userList += $userInfo
    }

    # Export the data to a CSV file
    $userList | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8

    Write-Host "User report has been successfully exported to $exportPath"

} catch {
    Write-Error "An error occurred: $_"
}
