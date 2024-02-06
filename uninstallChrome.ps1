
# retrieve the Google Chrome Product Code to Uninstall
$wmiInstance = Get-CimInstance -Query "SELECT * from Win32_Product WHERE name = 'Google Chrome'"
$chrome64Path = "C:\Program Files\Google\Chrome\Application\chrome.exe"



if(($null -ne $wmiInstance) -and (test-path $chrome64Path)){
    write-output "Uninstalling Chrome"
    $p1 = Start-Process msiexec.exe -ArgumentList "/x", $wmiInstance.IdentifyingNumber, "/qn" -Wait -PassThru
    $p1.WaitForExit()

    if( $p1.HasExited -and ($p1.ExitCode -eq 0) -and -not (test-path $chrome64Path) ){
        Write-Output "$($env:COMPUTERNAME) -- Google Chrome has been uninstalled"
        get-item "C:\users\*\OneDrive - Pennoni\Desktop\Google Chrome.lnk" | remove-item -force | Out-Null
    }

}else{ Write-Output "No Chrome installation was found..." }



