
$logFile = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Chrome64Install$(get-date -f "yyyyMMdd").log"
Start-Transcript -Path $logFile -Force

function Uninstall-Chrome32 {
    $chrome32Path = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
    $problemReg = "HKLM:\SOFTWARE\Classes\Installer\Products\CE2CFFCC165F1FE308833F06B8259F53"
    $uninstallSuccess = $false

    # remove the reg from the SCCM botched install
    if(Test-Path $problemReg){
        remove-item $problemReg -Recurse -Force > $null
    }

    # GUARD FOR UNINSTALL
    if( -not (test-path $chrome32Path) ){
        Write-Output "Chrome (x32) doesnt exist"
        return $true
    }

    Write-Output "$($env:COMPUTERNAME) Chrome 32 Exists -- $chrome32Path -- Version $((Get-Command $chrome32Path).FileVersionInfo.FileVersion)";

    # retrieve the Google Chrome Product Code to Uninstall
    $wmiInstance = Get-CimInstance -Query "SELECT * from Win32_Product WHERE name = 'Google Chrome'"
    
    # if there are two associated objects with the app, something is still wrong so fail
    if($wmiInstance.GetType().isArray){ return $false }

    # test for two 
    if($null -ne $wmiInstance){

        write-output "Uninstalling Chrome x32"
        $p1 = Start-Process msiexec.exe -ArgumentList "/x", $wmiInstance.IdentifyingNumber, "/qn" -Wait -PassThru
        $p1.WaitForExit()

        if( $p1.HasExited -and ($p1.ExitCode -eq 0) -and -not (test-path $chrome32Path) ){
            Write-Output "$($env:COMPUTERNAME) -- Google Chrome x32 has been uninstalled"
            get-item "C:\users\*\OneDrive - Pennoni\Desktop\Google Chrome.lnk" | remove-item -force | Out-Null
            $uninstallSuccess = $true
        }
    }else{ Write-Output "WARN -- WMI QUERY FAILED WITH VALUE OF NULL" }

    return $uninstallSuccess
}

function Install-Chrome64{
    $chrome64Path = "C:\Program Files\Google\Chrome\Application\chrome.exe"
    $isInstalled = $false

    # GUARD FOR REINSTALL
    if(test-path $chrome64Path){
        Write-Output "Chrome (x64) exist"
        return $true
    }

    $p = Start-Process msiexec.exe -ArgumentList "/i","googlechromestandaloneenterprise64.msi","/qn" -Wait -PassThru
    $p.WaitForExit()

    if($p.HasExited -and ($p.ExitCode -eq 0)){

        if(test-path $chrome64Path){
            Write-Output "$($env:COMPUTERNAME) -- Google Chrome x64 has been installed"
            $isInstalled = $true
        }
    }
    return $isInstalled
}

$remove32 = Uninstall-Chrome32

if($remove32){
    Write-Output "INFO -- GOOGLE CHROME 32 UNINSTALLED SUCCESSFULLY"

    $install64 = Install-Chrome64

    if($install64){
        Write-Output "INFO -- GOOGLE CHROME 64 INSTALLED SUCCESSFULLY"
    }else{
        Write-Output "WARN -- GOOGLE CHROME 64 FAILED TO INSTALL"
    }

}else{
    Write-Output "WARN -- GOOGLE CHROME 32 FAILED TO UNINSTALL"
}

Stop-Transcript

