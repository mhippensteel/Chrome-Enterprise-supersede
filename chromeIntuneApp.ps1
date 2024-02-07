
$logFile = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\Chrome64Install$(get-date -f "yyyyMMdd").log"
Start-Transcript -Path $logFile -Force

function Uninstall-Chrome32 {
    $chrome32Path = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

    # GUARD FOR UNINSTALL
    if( -not (test-path $chrome32Path) ){
        Write-Output "Chrome (x32) doesn't exist"
        return $true
    }

    Write-Output "$($env:COMPUTERNAME) Chrome 32 Exists -- $chrome32Path -- Version $((Get-Command $chrome32Path).FileVersionInfo.FileVersion)";

    # retrieve the Google Chrome Product Code to Uninstall
    $wmiInstance = Get-CimInstance -Query "SELECT * from Win32_Product WHERE name = 'Google Chrome'"
    
    # if there are two associated objects with the app, something is still wrong probably in the registry, so return false
    if($wmiInstance.GetType().isArray){ return $false }

    if($null -ne $wmiInstance){

        write-output "Uninstalling Chrome x32"
        try{  
            $p1 = Start-Process msiexec.exe -ArgumentList "/x", $wmiInstance.IdentifyingNumber, "/qn" -Wait -PassThru
            $p1.WaitForExit()

            if( $p1.HasExited -and ($p1.ExitCode -eq 0) -and -not (test-path $chrome32Path) ){
                Write-Output "$($env:COMPUTERNAME) -- Google Chrome x32 has been uninstalled"
                get-item "C:\users\*\OneDrive - Pennoni\Desktop\Google Chrome.lnk" | remove-item -force | Out-Null
                return $true
            }
        }catch{
            Write-Output "Process failure"; return $false
        }
    }else{ Write-Output "WARN -- WMI QUERY FAILED WITH VALUE OF NULL" }

    return $false
}

function Install-Chrome64{
    $chrome64Path = "C:\Program Files\Google\Chrome\Application\chrome.exe"

    # GUARD FOR REINSTALL
    if(test-path $chrome64Path){
        Write-Output "Chrome (x64) exist"
        return $true
    }

    $fileName = "googlechromestandaloneenterprise64.msi"
    $uri = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7BD824B8BA-BF17-7279-79CE-F8877F2FB71A%7D%26lang%3Den%26browser%3D5%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_0%26brand%3DGCGK/dl/chrome/install/googlechromestandaloneenterprise64.msi"

    try{
        Invoke-WebRequest -Uri $uri -OutFile $fileName -ErrorAction Stop
    }catch{
        Write-Output "Failed to download $fileName"; return $false
    }

    $p = Start-Process msiexec.exe -ArgumentList "/i",$fileName,"/qn" -Wait -PassThru -ErrorAction SilentlyContinue
    $p.WaitForExit()

    if($p.HasExited -and ($p.ExitCode -eq 0)){

        if(test-path $chrome64Path){
            Write-Output "$($env:COMPUTERNAME) -- Google Chrome x64 has been installed"
            remove-item $fileName -Force > $null
            return $true
        }
    }
    return $false
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

