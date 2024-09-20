### `README.md`

```markdown
# Active Directory Automation Scripts

This repository contains PowerShell scripts designed to automate common Active Directory (AD) tasks such as user management, group membership, and reporting. The scripts included in this repository are designed to help IT administrators efficiently manage AD users and groups.

## Scripts

### 1. `addtogroups.ps1`
This script is designed to add users to specific groups in Active Directory, especially focusing on nested group structures. It creates groups if they don't already exist and ensures that users are assigned to the correct groups.

#### Features:
- Ensures the creation of nested groups under a parent group (such as Sales).
- Moves specific users to designated subgroups (e.g., sales representatives).
- Provides verbose output indicating the progress and any errors encountered.

#### Usage:
1. Modify the script with the appropriate group names and user accounts.
2. Run the script with an account that has permissions to modify Active Directory group memberships.

#### Example:
To add users to the `g_Salgsrepresentanter` group:

```bash
# Example user list
$salesRepsMembers = @("erik.johansen", "per.pedersen", "bjorn.a.olsen")
```

### 2. `bulkuser4.ps1`
This script automates the bulk creation of Active Directory users based on a CSV file input. It normalizes non-standard characters in usernames and ensures that the correct Organizational Units (OUs) and groups are used for the users being created.

#### Features:
- Reads user data from a CSV file.
- Normalizes non-standard letters (e.g., `æ`, `ø`, `å`).
- Automatically assigns users to the correct OU based on their department.
- Ensures that users are added to appropriate groups after creation.
- Implements error handling to catch potential issues during user creation.

#### CSV File Format:
The script expects a CSV file with the following columns:
- `Fornavn` (First Name)
- `Midt initial` (Middle Initial)
- `Etternavn` (Last Name)
- `User login name`
- `Avdeling` (Department)
- `Passord` (Password)
- `mobiltelefon` (Phone number)

#### Usage:
1. Ensure the CSV file is properly formatted.
2. Set the appropriate file path in the script:
   ```bash
   $csvPath = "C:\path\to\your\Userscurrent3.csv"
   ```
3. Run the script as an administrator.

### 3. `userreport.ps1`
This script generates a comprehensive report of all users in Active Directory, including their name, department, phone number, email address, and last login time. The report is exported to a CSV file for further analysis or record-keeping.

#### Features:
- Retrieves user details from AD such as name, department, phone number, email, and last login time.
- Exports the user data to a CSV file.
- Implements error handling to catch any problems during execution.

#### Usage:
1. Modify the export path in the script if necessary:
   ```bash
   $exportPath = "C:\Reports\UsersReport.csv"
   ```
2. Run the script to generate the report.
3. The report will be saved as a CSV file, which can be opened in Excel or any other spreadsheet program.

## Requirements
- PowerShell 5.0 or above.
- Active Directory module for Windows PowerShell (Import-Module ActiveDirectory).
- Appropriate permissions to create, update, and report on Active Directory users and groups.

## Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/ADAutomationScripts.git
   ```
2. Modify the scripts as necessary to fit your Active Directory environment.
3. Run the scripts with sufficient permissions (domain admin or delegated rights) to manage AD users and groups.

## Usage
Each script can be run individually by launching PowerShell as an administrator and running the respective script file. Ensure that you have the necessary prerequisites installed and configured on the system running these scripts.

```bash
# Example of running bulkuser4.ps1
.\bulkuser4.ps1
```

## Error Handling
All scripts implement error handling using `try...catch` blocks to ensure that any issues encountered during execution are logged and handled gracefully.

## Contributing
Feel free to fork this repository and submit pull requests for any improvements or additional features you'd like to see.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.
```

### Key Points in the README:
1. **Overview**: Explains what each script does, giving an idea of the automation tasks they handle.
2. **Instructions**: Provides step-by-step instructions on how to use each script, including any modifications needed.
3. **Usage Examples**: Shows how to run each script with appropriate permissions.
4. **Error Handling**: Mentions the inclusion of error handling to deal with unexpected issues.
5. **Export and Output**: Explains the export functionality for reports and user data.

Let me know if you'd like to make further adjustments or if there’s anything specific you'd like to include in the README!