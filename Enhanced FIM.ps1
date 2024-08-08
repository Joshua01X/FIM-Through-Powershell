Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Already-Exists($path) {
    $baselineFilePath = "$path\baseline.txt"
    $baselineExists = Test-Path -Path $baselineFilePath

    if ($baselineExists) {
        # Delete it
        Remove-Item -Path $baselineFilePath
    }
}

Function Create-New-Baseline($sourcePath, $baselinePath) {
    # Delete baseline.txt if it already exists
    Erase-Baseline-If-Already-Exists $baselinePath

    # Calculate Hash from the target files and store in baseline.txt
    $files = Get-ChildItem -Path $sourcePath -File

    # For each file, calculate the hash, and write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        "$($f.FullName)|$($hash.Hash)" | Out-File -FilePath "$baselinePath\baseline.txt" -Append
    }

    Write-Host "Baseline created at: $baselinePath"
}

Function Start-File-Scan($scanPath, $baselineFilePath) {
    $fileHashDictionary = @{}

    # Load file|hash from baseline.txt and store them in a dictionary
    $filePathsAndHashes = Get-Content -Path $baselineFilePath
    
    foreach ($f in $filePathsAndHashes) {
        $fileHashDictionary.Add($f.Split("|")[0], $f.Split("|")[1])
    }

    while ($true) {
        Start-Sleep -Seconds 1
        
        $files = Get-ChildItem -Path $scanPath -File

        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName

            # Notify if a new file has been created
            if ($fileHashDictionary[$f.FullName] -eq $null) {
                Write-Host "$($f.FullName) has been created!" -ForegroundColor Green
            }
            else {
                # Notify if a file has been changed
                if ($fileHashDictionary[$f.FullName] -eq $hash.Hash) {
                    # The file has not changed
                }
                else {
                    # File has been compromised, notify the user
                    Write-Host "$($f.FullName) has changed!!!" -ForegroundColor Yellow
                }
            }
        }

        foreach ($key in $fileHashDictionary.Keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists) {
                Write-Host "$($key) has been deleted!" -ForegroundColor DarkRed -BackgroundColor Gray
            }
        }
    }
}

Write-Host ""
Write-Host "What would you like to do?"
Write-Host ""
Write-Host "    A) Collect new Baseline?"
Write-Host "    B) Begin monitoring files with saved Baseline?"
Write-Host ""
$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host ""

if ($response -eq "A".ToUpper()) {
    $sourcePath = Read-Host -Prompt "Enter the source path to collect file data from"
    $baselinePath = Read-Host -Prompt "Enter the destination path to save the baseline"
    Create-New-Baseline $sourcePath $baselinePath

    $startScan = Read-Host -Prompt "Baseline creation complete. Do you want to start scanning now? (Yes/No)"
    if ($startScan -eq "Yes".ToUpper()) {
        Start-File-Scan $sourcePath $baselinePath\baseline.txt
    }

} elseif ($response -eq "B".ToUpper()) {
    $baselinePath = Read-Host -Prompt "Enter the destination path where baseline is stored"
    $baselineFilePath = "$baselinePath\baseline.txt"

    if (Test-Path -Path $baselineFilePath) {
        $scanPath = Read-Host -Prompt "Baseline exists. Enter the destination path to start scanning"
        Start-File-Scan $scanPath $baselineFilePath
    } else {
        $createBaseline = Read-Host -Prompt "No baseline exists. Do you want to create a new one? (Yes/No)"
        if ($createBaseline -eq "Yes".ToUpper()) {
            $sourcePath = Read-Host -Prompt "Enter the source path to collect file data from"
            $baselinePath = Read-Host -Prompt "Enter the destination path to save the new baseline"
            Create-New-Baseline $sourcePath $baselinePath
            $startScan = Read-Host -Prompt "Baseline creation complete. Do you want to start scanning now? (Yes/No)"
            if ($startScan -eq "Yes".ToUpper()) {
                Start-File-Scan $sourcePath $baselinePath\baseline.txt
            }
        }
    }
} else {
    Write-Host "Invalid selection. Please restart the script and choose 'A' or 'B'."
}
