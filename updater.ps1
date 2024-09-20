# Import the necessary modules
Import-Module ActiveDirectory
Import-Module PSWindowsUpdate

# Define a list of remote servers with their computer names
$servers = @("THOKJE-DC01", "THOKJE-WS01")

# Function to check the status of installed services
function Check-Services {
    param (
        [string]$serverName
    )
    try {
        Write-Host "Checking services on $serverName..."
        $services = Get-Service -ComputerName $serverName
        foreach ($service in $services) {
            Write-Host "Service: $($service.DisplayName), Status: $($service.Status)"
        }
    } catch {
        Write-Error ("An error occurred while checking services on {0}: {1}" -f $serverName, $_.Exception.Message)
    }
}

# Function to install software updates if W32Time service is running
function Install-Updates {
    param (
        [string]$serverName
    )
    try {
        Write-Host "Checking W32Time service status on $serverName..."
        $w32TimeStatus = (Get-Service -Name "W32Time" -ComputerName $serverName).Status

        if ($w32TimeStatus -eq "Running") {
            Write-Host "W32Time service is running on $serverName. Installing software updates..."

            Invoke-WUJob -ComputerName $serverName -Script {
                if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
                    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
                    Install-Module -Name PSWindowsUpdate -Force
                }
                Import-Module PSWindowsUpdate
                Install-WindowsUpdate -AcceptAll -AutoReboot
            } -RunNow -Confirm:$false
        } else {
            Write-Host "W32Time service is not running on $serverName. Skipping updates."
        }
    } catch {
        Write-Error ("An error occurred while installing updates on {0}: {1}" -f $serverName, $_.Exception.Message)
    }
}

# Function to reboot the server, with an option to schedule the reboot
function Reboot-Server {
    param (
        [string]$serverName,
        [switch]$Schedule,
        [string]$RebootTime
    )
    try {
        if ($Schedule) {
            Write-Host "Scheduling a reboot on $serverName at $RebootTime..."
            # Create a scheduled task for the reboot
            $action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/r /t 0"
            $trigger = New-ScheduledTaskTrigger -At $RebootTime -Once
            Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Scheduled Reboot" -Description "Scheduled reboot for maintenance" -ComputerName $serverName
        } else {
            Write-Host "Rebooting $serverName now..."
            Restart-Computer -ComputerName $serverName -Force -Confirm:$false
        }
    } catch {
        Write-Error ("An error occurred while rebooting {0}: {1}" -f $serverName, $_.Exception.Message)
    }
}

# Function to create a scheduled task that runs this script weekly
function Schedule-WeeklyTask {
    param (
        [string]$taskName,
        [string]$scriptPath
    )
    try {
        Write-Host "Creating a scheduled task to run weekly..."

        # Check if the task already exists
        if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
            Write-Host "Scheduled task '$taskName' already exists. Updating the task."
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        }

        # Define the action to run the PowerShell script
        $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`" -ExecutionPolicy Bypass"
        
        # Define the trigger to run the task weekly
        $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 3AM
        
        # Register the scheduled task
        Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -Description "Weekly server maintenance task"
        
        Write-Host "Scheduled task '$taskName' created successfully."
    } catch {
        Write-Error ("An error occurred while creating the scheduled task: {0}" -f $_.Exception.Message)
    }
}

# Iterate through the list of servers
foreach ($server in $servers) {
    Check-Services -serverName $server
    Install-Updates -serverName $server

    # Check if the server requires a reboot
    $updatesInstalled = Get-HotFix -ComputerName $server | Where-Object { $_.InstalledOn -gt (Get-Date).AddDays(-1) }
    if ($updatesInstalled) {
        Write-Host "$server requires a reboot."
        # Prompt user for scheduling reboot
        $rebootOption = Read-Host "Do you want to reboot $server now? (Y/N)"
        if ($rebootOption -eq "Y") {
            Reboot-Server -serverName $server
        } else {
            $scheduleReboot = Read-Host "Do you want to schedule the reboot for later? (Y/N)"
            if ($scheduleReboot -eq "Y") {
                $rebootTime = Read-Host "Enter the reboot time (e.g., '09/20/2024 02:00 AM'):"
                Reboot-Server -serverName $server -Schedule -RebootTime $rebootTime
            }
        }
    }
}

# Schedule the weekly task (adjust the path to this script)
$taskName = "WeeklyServerMaintenance"
$scriptPath = "C:\Scripts\ServerMaintenance.ps1"
Schedule-WeeklyTask -taskName $taskName -scriptPath $scriptPath
