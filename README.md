# FIM-Through-Powershell

> still under construction... please wait...

## Objective
This PowerShell script is designed to facilitate file integrity monitoring (FIM). It achieves this by allowing users to create a baseline of file hashes and monitor files for any changes against this baseline. 
### The script supports two primary operations:
<b>Creating a new baseline</b>: Calculates and stores file hashes from a specified source path.<br>
<b>Monitoring files</b>: Compares current file hashes against a stored baseline to detect any changes, deletions, or new files.

## Technologies Employed

- PowerShell: A scripting language and shell used for automating administrative tasks and configuration management.
- SHA-512: A cryptographic hash function used to generate file hashes for integrity checking.

## Script Breakdown
### Hash Calculation Function

> Function Calculate-File-Hash($filepath) { <br>
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512 <br>
    return $filehash
}

- Purpose: Computes the SHA-512 hash of a file, which serves as a unique fingerprint for file integrity verification.

### Baseline Management Functions

> Function Erase-Baseline-If-Already-Exists($path) { <br>
    $baselineFilePath = "$path\baseline.txt" <br>
    $baselineExists = Test-Path -Path $baselineFilePath <br>
    if ($baselineExists) { <br>
        Remove-Item -Path $baselineFilePath <br>
    } <br> 
} <br>
Function Create-New-Baseline($sourcePath, $baselinePath) { <br> 
    Erase-Baseline-If-Already-Exists $baselinePath <br> 
    $files = Get-ChildItem -Path $sourcePath -File <br> 
    foreach ($f in $files) { <br>  
        $hash = Calculate-File-Hash $f.FullName <br> 
        "$($f.FullName)|$($hash.Hash)" | Out-File -FilePath "$baselinePath\baseline.txt" -Append <br> 
    } <br> 
    Write-Host "Baseline created at: $baselinePath" <br>
}

- Erase-Baseline-If-Already-Exists: Deletes an existing baseline file to avoid conflicts.
- Create-New-Baseline: Calculates hashes for all files in the specified source directory and writes them to a baseline file.

### User Interaction

> Write-Host "" <br>
Write-Host "What would you like to do?" <br>
Write-Host "" <br>
Write-Host "    A) Collect new Baseline?" <br>
Write-Host "    B) Begin monitoring files with saved Baseline?" <br>
Write-Host "" <br>
$response = Read-Host -Prompt "Please enter 'A' or 'B'" <br>
Write-Host "" <br>
if ($response -eq "A".ToUpper()) { <br>
    $sourcePath = Read-Host -Prompt "Enter the source path to collect file data from" <br>
    $baselinePath = Read-Host -Prompt "Enter the destination path to save the baseline" <br>
    Create-New-Baseline $sourcePath $baselinePath <br>
    $startScan = Read-Host -Prompt "Baseline creation complete. Do you want to start scanning now? (Yes/No)" <br>
    if ($startScan -eq "Yes".ToUpper()) { <br>
        Start-File-Scan $sourcePath $baselinePath\baseline.txt <br>
    } <br>
} elseif ($response -eq "B".ToUpper()) { <br>
    $baselinePath = Read-Host -Prompt "Enter the destination path where baseline is stored" <br>
    $baselineFilePath = "$baselinePath\baseline.txt" <br>
    if (Test-Path -Path $baselineFilePath) { <br>
        $scanPath = Read-Host -Prompt "Baseline exists. Enter the destination path to start scanning" <br>
        Start-File-Scan $scanPath $baselineFilePath <br>
    } else { <br>
        $createBaseline = Read-Host -Prompt "No baseline exists. Do you want to create a new one? (Yes/No)" <br>
        if ($createBaseline -eq "Yes".ToUpper()) { <br>
            $sourcePath = Read-Host -Prompt "Enter the source path to collect file data from" <br>
            $baselinePath = Read-Host -Prompt "Enter the destination path to save the new baseline" <br>
            Create-New-Baseline $sourcePath $baselinePath <br>
            $startScan = Read-Host -Prompt "Baseline creation complete. Do you want to start scanning now? (Yes/No)" <br>
            if ($startScan -eq "Yes".ToUpper()) { <br>
                Start-File-Scan $sourcePath $baselinePath\baseline.txt <br>
            }<br>
        }<br>
    }<br>
} else {<br>
    Write-Host "Invalid selection. Please restart the script and choose 'A' or 'B'." <br>
}

- Purpose: Provides the user with options to create a baseline or start monitoring. Based on user input, it invokes the appropriate functions and handles the process accordingly.

### File Scanning Function

> Function Start-File-Scan($scanPath, $baselineFilePath) { <br>
    $fileHashDictionary = @{} <br>
    $filePathsAndHashes = Get-Content -Path $baselineFilePath <br>
    foreach ($f in $filePathsAndHashes) { <br> 
        $fileHashDictionary.Add($f.Split("|")[0], $f.Split("|")[1]) <br> 
    } <br>
    while ($true) { <br> 
        Start-Sleep -Seconds 1 <br> 
        $files = Get-ChildItem -Path $scanPath -File <br>
        foreach ($f in $files) { <br> 
            $hash = Calculate-File-Hash $f.FullName <br>
            if ($fileHashDictionary[$f.FullName] -eq $null) { <br> 
                Write-Host "$($f.FullName) has been created!" -ForegroundColor Green <br> 
            } <br>
            else { <br>
                if ($fileHashDictionary[$f.FullName] -eq $hash.Hash) { <br>
                    # File has not changed <br>
                } <br>
                else { <br> 
                    Write-Host "$($f.FullName) has changed!!!" -ForegroundColor Yellow <br>
                } <br>
            } <br>
        } <br>
        foreach ($key in $fileHashDictionary.Keys) { <br>
            $baselineFileStillExists = Test-Path -Path $key <br>
            if (-Not $baselineFileStillExists) { <br>
                Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray <br>
            } <br>
        }<br>
    }<br>
}

- Purpose: Monitors the specified path for changes by comparing current file hashes against the stored baseline. It notifies if files have been created, changed, or deleted.

## Documentation
### Initiating Scanning With No Recorded Baseline Yet
The prompt will ask if the user wants to create a new baseline
![image](https://github.com/user-attachments/assets/a0e67ec3-229d-4aaa-8b8f-dc0ec4fbd099)

The prompt will initiate the scanning afterwards
![image](https://github.com/user-attachments/assets/9cd9e41f-33b2-4857-af24-ec67d35f4319)

### Initiating Scanning With A New Baseline
The prompt will also ask the following query before scanning
![image](https://github.com/user-attachments/assets/efc296ab-edb8-4681-b2c8-0a893f0ff0bf)

The prompt will soon start the scanning afterwards
![image](https://github.com/user-attachments/assets/731526a0-995b-460c-a4ee-43cf7c636ed1)

### Proof Of Newly Created Baseline's Reliability
![image](https://github.com/user-attachments/assets/3d2d0e85-bc84-41b6-8a29-4163284bea30)

## Discussion
This script simplifies the process of file integrity monitoring by allowing users to:

<b>Create a Baseline</b>: Captures the state of files by hashing them and storing their hashes. This baseline can be used for future comparisons.
<b>Monitor Files</b>: Compares the current state of files against the baseline to detect any changes, deletions, or new files.
The use of SHA-512 hashing ensures a high level of data integrity and security. The script is user-friendly, guiding users through the process with clear prompts and decisions.

## Conclusion
The File Integrity Monitoring script provides a robust solution for ensuring the integrity of files by comparing current file states against a known baseline. It combines practical scripting techniques with secure hashing algorithms to deliver an effective monitoring tool. This script can be a valuable addition to a cybersecurity toolkit, offering a straightforward method to track and respond to unauthorized file changes. For future improvements, I suggest further simplifying the code and revisiting certain sections to enhance overall efficiency and functionality. This could lead to more streamlined operations and better performance in practical applications.

