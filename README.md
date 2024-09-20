# Active Directory and Windows Server Automation Scripts

This repository contains PowerShell scripts designed to automate common Active Directory (AD) tasks and Windows Server maintenance. The scripts included in this repository help IT administrators efficiently manage AD users, groups, and perform routine maintenance on Windows servers.

## Scripts

### 1. `addtogroups.ps1`

This script is designed to add users to specific groups in Active Directory, focusing on nested group structures. It creates groups if they don't already exist and ensures that users are assigned to the correct groups.



### 2. `bulkuser4.ps1`

This script automates the bulk creation of Active Directory users based on a CSV file input. It normalizes non-standard characters in usernames and ensures that the correct Organizational Units (OUs) and groups are used for the users being created.


### 3. `userreport.ps1`

This script generates a comprehensive report of all users in Active Directory, including their name, department, phone number, email address, and last login time. The report is exported to a CSV file for further analysis or record-keeping.



### 4. `ServerMaintenance.ps1`

This script automates remote maintenance tasks on multiple Windows Servers. It checks the status of installed services, installs software updates if certain conditions are met, and reboots the servers if required. It also sets up a scheduled task to run the script weekly.



### 5. `updater.ps1`

This script is used for performing regular maintenance tasks on remote Windows servers, checking services, installing updates, and scheduling reboots.

#### Features:

- **Check Installed Services**: Retrieves the status of all installed services on specified remote servers.
- **Conditional Software Updates**: Installs software updates if the `W32Time` (Windows Time) service is running on the server.
- **Reboot Management**: Reboots the server immediately or schedules a reboot for a later time based on user input.
- **Error Handling**: Implements error handling using `try...catch` blocks to manage exceptions gracefully.
- **Scheduled Task Setup**: Automatically creates a scheduled task to run the script weekly.

#### Usage:

1. **Define Remote Servers**:

   Modify the `$servers` array in the script to include the names of your remote servers:

   ```powershell
   $servers = @("THOKJE-DC01", "THOKJE-WS01")
   ```

2. **Adjust Script Path**:

   Update the `$scriptPath` variable to point to the location where you will save the script:

   ```powershell
   $scriptPath = "C:\Scripts\updater.ps1"
   ```

3. **Run the Script**:

   Execute the script with administrative privileges:

   ```powershell
   .\updater.ps1
   ```

4. **Scheduled Task**:

   The script will create a scheduled task named `WeeklyServerMaintenance` that runs the script weekly at 3 AM on Mondays.  
   You can adjust the schedule by modifying the `New-ScheduledTaskTrigger` parameters in the `Schedule-WeeklyTask` function.

#### Requirements:

- **PowerShell Remoting**: Ensure that PowerShell Remoting is enabled on the remote servers (`Enable-PSRemoting`).
- **Firewall Settings**: Configure firewall settings to allow PowerShell Remoting (usually TCP port 5985 for HTTP).
- **Administrative Privileges**: You must run the script with an account that has administrative rights on the remote servers.
- **PSWindowsUpdate Module on Remote Servers**: The script attempts to install the `PSWindowsUpdate` module on remote servers if it's not already installed. Remote servers need internet access to download modules from the PowerShell Gallery.

---

## Installation

1. **Clone the Repository**:

   ```bash
   git clone https://github.com/yourusername/ADAutomationScripts.git
   ```

2. **Modify Scripts**: Adjust the scripts as necessary to fit your environment.

3. **Run Scripts**: Execute the scripts with appropriate permissions.

## Requirements

- **PowerShell 5.0 or Later**: Some cmdlets and parameters used in the scripts require PowerShell 5.0 or newer.
- **Active Directory Module**: Install the Active Directory module for Windows PowerShell.
- **PSWindowsUpdate Module**: Install the PSWindowsUpdate module to manage Windows Updates via PowerShell.

## Contributing

Feel free to fork this repository and submit pull requests for any improvements or additional features you'd like to see.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
```
