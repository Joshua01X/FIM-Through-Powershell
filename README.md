# FIM-Through-Powershell

![FIM](https://github.com/user-attachments/assets/a56087cc-a55f-462b-a340-1b5ae92175be)

## Objective
This PowerShell script is designed to facilitate file integrity monitoring (FIM). It achieves this by allowing users to create a baseline of file hashes and monitor files for any changes against this baseline. 
### The script supports two primary operations:
<b>Creating a new baseline</b>: Calculates and stores file hashes from a specified source path.<br>
<b>Monitoring files</b>: Compares current file hashes against a stored baseline to detect any changes, deletions, or new files.

## Technologies Employed

- <b>PowerShell</b>: A scripting language and shell used for automating administrative tasks and configuration management.
- <b>SHA-512</b>: A cryptographic hash function used to generate file hashes for integrity checking.

## Script Breakdown
### Hash Calculation Function

![image](https://github.com/user-attachments/assets/63e8788f-d660-43c2-af9f-1ebf18f6f265)

<b>Purpose</b>: Computes the SHA-512 hash of a file, which serves as a unique fingerprint for file integrity verification.

### Baseline Management Functions

![image](https://github.com/user-attachments/assets/62d0ec9a-3edf-4ebf-9ba6-0abb9b60de39)

<b>Erase-Baseline-If-Already-Exists</b>: Deletes an existing baseline file to avoid conflicts.<br>
<b>Create-New-Baseline</b>: Calculates hashes for all files in the specified source directory and writes them to a baseline file.

### User Interaction

![image](https://github.com/user-attachments/assets/6cacdd76-7d5d-4c6c-a905-debba3af749d)

<b>Purpose</b>: Provides the user with options to create a baseline or start monitoring. Based on user input, it invokes the appropriate functions and handles the process accordingly.

### File Scanning Function

![image](https://github.com/user-attachments/assets/05917372-83d6-41f5-b650-7215f2256ecf)

<b>Purpose</b>: Monitors the specified path for changes by comparing current file hashes against the stored baseline. It notifies if files have been created, changed, or deleted.

## Documentation
### Initiating Scan With No Recorded Baseline Yet
The prompt will ask if the user wants to create a new baseline
![image](https://github.com/user-attachments/assets/a0e67ec3-229d-4aaa-8b8f-dc0ec4fbd099)

The prompt will initiate the scanning afterwards
![image](https://github.com/user-attachments/assets/9cd9e41f-33b2-4857-af24-ec67d35f4319)

### Initiating Scan With A New Baseline
The prompt will also ask the following query before scanning
![image](https://github.com/user-attachments/assets/efc296ab-edb8-4681-b2c8-0a893f0ff0bf)

The prompt will soon start the scanning afterwards
![image](https://github.com/user-attachments/assets/731526a0-995b-460c-a4ee-43cf7c636ed1)

### Proof Of Newly Created Baseline's Reliability
![image](https://github.com/user-attachments/assets/3d2d0e85-bc84-41b6-8a29-4163284bea30)

### Content Alteration Test
![image](https://github.com/user-attachments/assets/2a293724-d10f-4e2e-b2ed-208dd2da9fe5)

### File Removal Test
![image](https://github.com/user-attachments/assets/5c059b5f-29c0-4914-9cd4-cc24feb71574)

### File Creation Test
![image](https://github.com/user-attachments/assets/7490c83e-f02e-4c70-afaf-8334c686468a)

## Discussion
This script simplifies the process of file integrity monitoring by allowing users to:

<b>Create a Baseline</b>: Captures the state of files by hashing them and storing their hashes. This baseline can be used for future comparisons.<br>
<b>Monitor Files</b>: Compares the current state of files against the baseline to detect any changes, deletions, or new files.
The use of SHA-512 hashing ensures a high level of data integrity and security. The script is user-friendly, guiding users through the process with clear prompts and decisions.

## Conclusion
The File Integrity Monitoring script provides a robust solution for ensuring the integrity of files by comparing current file states against a known baseline. It combines practical scripting techniques with secure hashing algorithms to deliver an effective monitoring tool. This script can be a valuable addition to a cybersecurity toolkit, offering a straightforward method to track and respond to unauthorized file changes. For future improvements, I suggest further simplifying the code and revisiting certain sections to enhance overall efficiency and functionality. This could lead to more streamlined operations and better performance in practical applications.

