# Define the list of DHCP servers
$DhcpServers = @("THOKJE-DC01", "THOKJE-DC02") 

# Define the output CSV file path
$CsvFilePath = "C:\dhcp_leases.csv" 

# Import DHCP module (if not already imported)
Import-Module DhcpServer

# Initialize an empty array to hold lease information
$AllLeases = @()

# Loop through each DHCP server
foreach ($DhcpServer in $DhcpServers) {
    # Retrieve all DHCP scopes from the current server
    $Scopes = Get-DhcpServerv4Scope -ComputerName $DhcpServer

    # Loop through each scope and retrieve leases
    foreach ($Scope in $Scopes) {
        $Leases = Get-DhcpServerv4Lease -ComputerName $DhcpServer -ScopeId $Scope.ScopeId
        # Add the DHCP server name to each lease record
        foreach ($Lease in $Leases) {
            $Lease | Add-Member -MemberType NoteProperty -Name "DhcpServer" -Value $DhcpServer
        }
        $AllLeases += $Leases
    }
}

# Select required fields and export to CSV
$AllLeases | Select-Object `
    @{Name="DhcpServer";Expression={$_.DhcpServer}}, `
    @{Name="ScopeId";Expression={$_.ScopeId}}, `
    @{Name="IPAddress";Expression={$_.IPAddress}}, `
    @{Name="HostName";Expression={$_.HostName}}, `
    @{Name="ClientID";Expression={$_.ClientId}}, `
    @{Name="AddressState";Expression={$_.AddressState}} `
    | Export-Csv -Path $CsvFilePath -NoTypeInformation -Delimiter ";"
