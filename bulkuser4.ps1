# Import the Active Directory module
Import-Module ActiveDirectory

# Path to CSV file
$csvPath = "C:\Users\thor.kjelsrud\Documents\Userscurrent3.csv"

# Default password for all users
$defaultPassword = "Passord123"

# Function to handle non-standard letters (normalize æ, ø, å)
function Convert-SpecialCharacters {
    param ($string)
    if ($string) {
        $string = $string -replace "å", "a"
        $string = $string -replace "ø", "o"
        $string = $string -replace "æ", "e"
        $string = $string -replace "Å", "A"
        $string = $string -replace "Ø", "O"
        $string = $string -replace "Æ", "E"
        # Force the string into pure ASCII encoding to strip non-ASCII characters
        $string = [System.Text.Encoding]::ASCII.GetString([System.Text.Encoding]::ASCII.GetBytes($string))
    }
    return $string
}

# Import users from CSV using UTF-8 encoding
$users = Import-Csv -Path $csvPath -Delimiter ";" -Encoding UTF8

# List to track duplicate usernames
$usernames = @{}

# Map departments to OUs
$departmentOUMap = @{
    "Utviklings" = "OU=Utvikling,OU=MainOU,DC=fsi-thokje,DC=com"
    "HR" = "OU=HR,OU=MainOU,DC=fsi-thokje,DC=com"
    "Slags" = "OU=Salg,OU=MainOU,DC=fsi-thokje,DC=com"
    "IT" = "OU=IT,OU=MainOU,DC=fsi-thokje,DC=com"
    "Kunde Support" = "OU=KundeSupport,OU=MainOU,DC=fsi-thokje,DC=com"
    "Administrasjon" = "OU=Administrasjon,OU=MainOU,DC=fsi-thokje,DC=com"
    # Add other department to OU mappings as needed
}
$departmentCNMap = @{
    "Utviklings" = "CN=g_Utvikling,OU=Groups,OU=MainOU,DC=fsi-thokje,DC=com"
    "HR" = "CN=g_HR,OU=Groups,OU=MainOU,DC=fsi-thokje,DC=com"
    "Slags" = "CN=g_Salg,OU=Groups,OU=MainOU,DC=fsi-thokje,DC=com"
    "IT" = "CN=g_IT,OU=Groups,OU=MainOU,DC=fsi-thokje,DC=com"
    "Kunde Support" = "CN=g_KundeSupport,OU=Groups,OU=MainOU,DC=fsi-thokje,DC=com"
    "Administrasjon" = "CN=g_Administrasjon,OU=Groups,OU=MainOU,DC=fsi-thokje,DC=com"
}
# Loop through each user in the CSV
foreach ($user in $users) {
    # Normalize names for username creation
    Write-Host "Navn: - $($user.Fornavn) $($user.'Midt initial') $($user.Etternavn)"
    $normalizedFirstName = Convert-SpecialCharacters -string $user.'Fornavn'
    $normalizedLastName = Convert-SpecialCharacters -string $user.'Etternavn'
    $normalizedInitials = Convert-SpecialCharacters -string $user.'Midt initial'

    Write-Host "Normalized names for user: $normalizedFirstName $normalizedLastName $normalizedInitials"

    # Create username: lowercase, full name, separated by periods
    $username = "$($normalizedFirstName.ToLower()).$($normalizedLastName.ToLower())"
    Write-Host "Generated username: $username"

    # Check for duplicate usernames
    if ($usernames.ContainsKey($username)) {
        # If duplicate, add middle initial to username
        $username = "$($normalizedFirstName.ToLower()).$($normalizedInitials.ToLower()).$($normalizedLastName.ToLower())"
        Write-Host "Generated username with initial: $username"
    }

    # Track username to handle duplicates
    $usernames[$username] = $true

    # Find the correct OU for the user's department
    $department = $user.'Avdeling'
    $ou = $departmentOUMap[$department]
    $group =$departmentCNMap[$department]

    if (-not $ou) {
        Write-Host "No OU mapping found for department '$department'. Skipping user creation."
        continue
    }

    if (-not $group) {
        Write-Host "Group $group does not exist. Skipping group addition..."
        continue
    }
    

    # Create user object in AD in the correct OU
    New-ADUser `
        -Name "$($user.Fornavn) $($user.'Midt initial') $($user.Etternavn)" `
        -GivenName $($user.Fornavn) `
        -Initials $($user.'Midt initial') `
        -Surname $($user.Etternavn) `
        -SamAccountName $username `
        -UserPrincipalName "$username@fsi-thokje.com" `
        -Department $user.'Avdeling' `
        -OfficePhone $user.'mobiltelefon' `
        -AccountPassword (ConvertTo-SecureString $defaultPassword -AsPlainText -Force) `
        -PasswordNeverExpires $false `
        -ChangePasswordAtLogon $true `
        -Enabled $false `
        -Path $ou `
        -PassThru

    # Explicitly set ChangePasswordAtLogon after user creation
    Set-ADUser -Identity $username -ChangePasswordAtLogon $true -PasswordNeverExpires $false 
    Write-Host "Adding user $username to group $group"
    Add-ADGroupMember -Identity $group -Members $username
}
