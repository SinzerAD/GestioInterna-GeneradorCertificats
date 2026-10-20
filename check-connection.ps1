<#
.SYNOPSIS
Comprova que es pot connectar a un site de SharePoint Online amb el certificat d'una aplicació (PnP.PowerShell).
.DESCRIPTION
Cal PowerShell 7.2 o superior i el mòdul PnP.PowerShell.
Indiqueu el certificat amb -PfxPath (fitxer .pfx) o amb -Base64Path (fitxer .txt generat per base64_encoder.ps1).
.EXAMPLE
.\check-connection.ps1 -ClientId <id-aplicacio> -Tenant <id-tenant> -SiteUrl https://<tenant>.sharepoint.com/sites/<site> -PfxPath .\sortida\ElMeuCertificat.pfx
.EXAMPLE
.\check-connection.ps1 -ClientId <id-aplicacio> -Tenant <id-tenant> -SiteUrl https://<tenant>.sharepoint.com/sites/<site> -Base64Path .\sortida\ElMeuCertificat.base64.txt -Password (Read-Host -AsSecureString)
#>
Param(
    [Parameter(Mandatory = $true, HelpMessage = "Application (client) ID de l'aplicació a Entra ID")]
    [string]$ClientId,

    [Parameter(Mandatory = $true, HelpMessage = "Directory (tenant) ID o domini del tenant")]
    [string]$Tenant,

    [Parameter(Mandatory = $true, HelpMessage = "URL del site de SharePoint")]
    [string]$SiteUrl,

    [Parameter(Mandatory = $false)]
    [string]$PfxPath,

    [Parameter(Mandatory = $false)]
    [string]$Base64Path,

    [Parameter(Mandatory = $false, HelpMessage = "Contrasenya del certificat, si en té")]
    [SecureString]$Password
)

if ($PSVersionTable.PSVersion -lt [Version]"7.2") {
    Write-Host "Aquest script necessita PowerShell 7.2 o superior (ara: $($PSVersionTable.PSVersion)). Instal·leu-lo amb: winget install Microsoft.PowerShell" -ForegroundColor Red
    exit 1
}

if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Host "No es troba el mòdul PnP.PowerShell. Instal·leu-lo amb: Install-Module PnP.PowerShell -Scope CurrentUser" -ForegroundColor Red
    exit 1
}

if (-not $PfxPath -and -not $Base64Path) {
    Write-Host "Indiqueu el certificat amb -PfxPath o amb -Base64Path." -ForegroundColor Red
    exit 1
}

$connectParams = @{
    ClientId    = $ClientId
    Tenant      = $Tenant
    Url         = $SiteUrl
    ErrorAction = 'Stop'
}

if ($PfxPath) {
    if (-not (Test-Path -LiteralPath $PfxPath)) {
        Write-Host "Error: el fitxer '$PfxPath' no existeix." -ForegroundColor Red
        exit 1
    }
    $connectParams.CertificatePath = (Resolve-Path -LiteralPath $PfxPath).Path
} else {
    if (-not (Test-Path -LiteralPath $Base64Path)) {
        Write-Host "Error: el fitxer '$Base64Path' no existeix." -ForegroundColor Red
        exit 1
    }
    $connectParams.CertificateBase64Encoded = (Get-Content -LiteralPath $Base64Path -Raw).Trim()
}

if ($Password) {
    $connectParams.CertificatePassword = $Password
}

try {
    Import-Module PnP.PowerShell -ErrorAction Stop
    Connect-PnPOnline @connectParams
    $web = Get-PnPWeb -ErrorAction Stop

    Write-Host "Connexió correcta al site: $SiteUrl ($($web.Title))" -ForegroundColor Green
    Disconnect-PnPOnline
}
catch {
    Write-Host "No s'ha pogut connectar al site. Error: $_" -ForegroundColor Red
    exit 1
}
