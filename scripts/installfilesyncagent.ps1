# Gather the OS version
$osver = [System.Environment]::OSVersion.Version

# Download the appropriate version of the Azure File Sync agent for your OS.
# Azure File Sync Version 11.1
# Windows Server 2019
if ($osver.Equals([System.Version]::new(10, 0, 17763, 0))) {
    Invoke-WebRequest `
        -UseBasicParsing `
        -Uri https://download.microsoft.com/download/1/8/D/18DC8184-E7E2-45EF-823F-F8A36B9FF240/StorageSyncAgent_WS2019.msi `
        -OutFile "StorageSyncAgent.msi" 
}
# Windows Server 2016
elseif ($osver.Equals([System.Version]::new(10, 0, 14393, 0))) {
    Invoke-WebRequest `
        -UseBasicParsing `
        -Uri https://download.microsoft.com/download/1/8/D/18DC8184-E7E2-45EF-823F-F8A36B9FF240/StorageSyncAgent_WS2016.msi `
        -OutFile "StorageSyncAgent.msi" 
}
# Windows Server 2012 R2
elseif ($osver.Equals([System.Version]::new(6, 3, 9600, 0))) {
    Invoke-WebRequest `
        -UseBasicParsing `
        -Uri https://download.microsoft.com/download/1/8/D/18DC8184-E7E2-45EF-823F-F8A36B9FF240/StorageSyncAgent_WS2012R2.msi `
        -OutFile "StorageSyncAgent.msi" 
}
else {
    throw [System.PlatformNotSupportedException]::new("Azure File Sync is only supported on Windows Server 2012 R2, Windows Server 2016, and Windows Server 2019")
}

# Install the MSI package in quiet mode
Start-Process -FilePath ".\StorageSyncAgent.msi" -ArgumentList "/quiet" -Wait