# Import the Active Directory module
Import-Module ActiveDirectory

# Define the Sales department groups
$salesGroup = "g_Salg"
$salesManagerGroup = "g_Salgssjef"
$salesRepsGroup = "g_Salgsrepresentanter"

# 1. Ensure nested groups exist inside the Sales department group

# Check and create 'g_Salgssjef' group if it doesn't exist
$groupCheck = Get-ADGroup -Filter { Name -eq $salesManagerGroup } -ErrorAction SilentlyContinue
if (-not $groupCheck) {
    Write-Host "Creating group 'g_Salgssjef' under Sales."
    New-ADGroup -Name "g_Salgssjef" -GroupScope Global -Path "OU=Groups,OU=MainOU,DC=fsi-thokje,DC=com" -GroupCategory Security
} else {
    Write-Host "'g_Salgssjef' already exists."
}

# Check and create 'g_Salgsrepresentanter' group if it doesn't exist
$groupCheck = Get-ADGroup -Filter { Name -eq $salesRepsGroup } -ErrorAction SilentlyContinue
if (-not $groupCheck) {
    Write-Host "Creating group 'g_Salgsrepresentanter' under Sales."
    New-ADGroup -Name "g_Salgsrepresentanter" -GroupScope Global -Path "OU=Groups,OU=MainOU,DC=fsi-thokje,DC=com" -GroupCategory Security
} else {
    Write-Host "'g_Salgsrepresentanter' already exists."
}

# 2. Add the Sales groups to the Sales parent group (nested group)
$salesGroupDN = (Get-ADGroup -Filter { Name -eq $salesGroup }).DistinguishedName
$salesManagerGroupDN = (Get-ADGroup -Filter { Name -eq $salesManagerGroup }).DistinguishedName
$salesRepsGroupDN = (Get-ADGroup -Filter { Name -eq $salesRepsGroup }).DistinguishedName

if ($salesGroupDN -and $salesManagerGroupDN -and $salesRepsGroupDN) {
    Write-Host "Ensuring 'g_Salgssjef' and 'g_Salgsrepresentanter' are nested under 'g_Salg'."
    Add-ADGroupMember -Identity $salesGroupDN -Members $salesManagerGroupDN, $salesRepsGroupDN -ErrorAction SilentlyContinue
} else {
    Write-Host "One or more Sales groups could not be found. Skipping nesting."
}

# 3. Move existing users to the 'g_Salgsrepresentanter' group
$salesRepsMembers = @("erik.johansen", "per.pedersen", "bjorn.a.olsen")
foreach ($member in $salesRepsMembers) {
    # Check if the user exists in AD
    $user = Get-ADUser -Filter { SamAccountName -eq $member } -ErrorAction SilentlyContinue
    if ($user) {
        Write-Host "Adding $member to the 'g_Salgsrepresentanter' group."
        Add-ADGroupMember -Identity $salesRepsGroupDN -Members $member -ErrorAction SilentlyContinue
    } else {
        Write-Host "User $member not found in Active Directory. Skipping..."
    }
}
