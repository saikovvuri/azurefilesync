<#
#>

Param(
    [string]$Subscription = $env:AZURE_SUBSCRIPTION,
    [string]$ResourceGroupName = $env:AZURE_GROUP,
    [string]$Location = $env:AZURE_LOCATION,
    [string]$FileSyncServerLogin,
    [string]$fileSyncLoginPassword
)

if ( !$Subscription) { throw "Subscription Required" }
if ( !$ResourceGroupName) { throw "ResourceGroupName Required" }
if ( !$Location) { throw "Location Required" }
if ( !$FileSyncServerLogin) { throw "File Sync server login is required"}
if ( !$FileSyncServerLoginPassword) {throw "File Sync server login password is required"}

function Write-Color([String[]]$Text, [ConsoleColor[]]$Color = "White", [int]$StartTab = 0, [int] $LinesBefore = 0, [int] $LinesAfter = 0, [string] $LogFile = "", $TimeFormat = "yyyy-MM-dd HH:mm:ss") {
    # version 0.2
    # - added logging to file
    # version 0.1
    # - first draft
    #
    # Notes:
    # - TimeFormat https://msdn.microsoft.com/en-us/library/8kb3ddd4.aspx
  
    $DefaultColor = $Color[0]
    if ($LinesBefore -ne 0) {  for ($i = 0; $i -lt $LinesBefore; $i++) { Write-Host "`n" -NoNewline } } # Add empty line before
    if ($StartTab -ne 0) {  for ($i = 0; $i -lt $StartTab; $i++) { Write-Host "`t" -NoNewLine } }  # Add TABS before text
    if ($Color.Count -ge $Text.Count) {
      for ($i = 0; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
    }
    else {
      for ($i = 0; $i -lt $Color.Length ; $i++) { Write-Host $Text[$i] -ForegroundColor $Color[$i] -NoNewLine }
      for ($i = $Color.Length; $i -lt $Text.Length; $i++) { Write-Host $Text[$i] -ForegroundColor $DefaultColor -NoNewLine }
    }
    Write-Host
    if ($LinesAfter -ne 0) {  for ($i = 0; $i -lt $LinesAfter; $i++) { Write-Host "`n" } }  # Add empty line after
    if ($LogFile -ne "") {
      $TextToFile = ""
      for ($i = 0; $i -lt $Text.Length; $i++) {
        $TextToFile += $Text[$i]
      }
      Write-Output "[$([datetime]::Now.ToString($TimeFormat))]$TextToFile" | Out-File $LogFile -Encoding unicode -Append
    }
  }


function LoginAzure() {
    Write-Color -Text "Logging in and setting subscription..." -Color Green
    if ([string]::IsNullOrEmpty($(Get-AzContext).Account)) {
      if ($env:AZURE_TENANT) {
        Connect-AzAccount -TenantId $env:AZURE_TENANT
      }
      else {
        Connect-AzAccount
      }
    }
    Set-AzContext -SubscriptionId ${Subscription} | Out-null
  
  }

function CreateResourceGroup([string]$ResourceGroupName, [string]$Location) {
    # Required Argument $1 = RESOURCE_GROUP
    # Required Argument $2 = LOCATION
  
    Get-AzResourceGroup -Name $ResourceGroupName -ev notPresent -ea 0 | Out-null
  
    if ($notPresent) {
  
      Write-Host "Creating Resource Group $ResourceGroupName..." -ForegroundColor Yellow
      New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    }
    else {
      Write-Color -Text "Resource Group ", "$ResourceGroupName ", "already exists." -Color Green, Red, Green
    }
}

LoginAzure
CreateResourceGroup $ResourceGroupName $Location

$SecureFileSyncPassword = ConvertTo-SecureString $FileSyncServerLoginPassword -AsPlainText -Force

New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile .\azuredeploy.json `
    -TemplateParameterFile .\azuredeploy.parameters.json `
    -fileSyncServerAdminUserName $FileSyncServerLogin `
    -fileSyncServerAdminPassword $SecureFileSyncPassword
    