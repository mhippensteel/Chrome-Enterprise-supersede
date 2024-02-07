
$chrome64Path = "C:\Program Files\Google\Chrome\Application\chrome.exe"

if( test-path $chrome64Path ){

    $fileVersion = ( get-command $chrome64Path ).FileVersionInfo.FileVersion
    if($fileVersion -ge [System.Version]"121.0.6167.140"){
        Write-Output "INFO -- Chrome.exe (x64) $fileVersion was detected -- EXIT 0"; exit 0
    }

    # Write-Output "$chrome64Path was detected but out-of-date version $fileVersion -- EXIT 1"
    exit 1
}

# Write-Output "WARN -- $chrome64Path was detected but out-of-date version $fileVersion -- EXIT 1"
exit 1