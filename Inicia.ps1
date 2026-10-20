<#
.SYNOPSIS
Assistent amb menú per generar certificats, codificar-los en Base64 i comprovar la connexió a SharePoint.
.DESCRIPTION
Es pot obrir amb doble clic a Inicia.cmd. Demana permisos d'administrador perquè la generació de certificats els necessita.
Els fitxers generats es desen a la carpeta "sortida", que Git ignora.
#>

# Tornar-se a obrir com a administrador si cal
$identity = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $identity.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $shell = (Get-Process -Id $PID).Path
    Start-Process -FilePath $shell -Verb RunAs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
    exit
}

$root = $PSScriptRoot
$sortida = Join-Path $root 'sortida'

function Read-Valor {
    param(
        [string]$Pregunta,
        [string]$PerDefecte
    )
    $text = if ($PerDefecte) { "$Pregunta [$PerDefecte]" } else { $Pregunta }
    do {
        $valor = (Read-Host $text).Trim().Trim('"')
        if (-not $valor) { $valor = $PerDefecte }
    } until ($valor)
    return $valor
}

function Read-Data {
    param(
        [string]$Pregunta,
        [DateTime]$PerDefecte
    )
    while ($true) {
        $text = Read-Valor -Pregunta "$Pregunta (AAAA-MM-DD)" -PerDefecte $PerDefecte.ToString('yyyy-MM-dd')
        $data = [DateTime]::MinValue
        if ([DateTime]::TryParseExact($text, 'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::None, [ref]$data)) {
            return $data
        }
        Write-Host "Data no vàlida. Feu servir el format AAAA-MM-DD (ex. 2026-12-31)." -ForegroundColor Red
    }
}

function Get-DarrerPfx {
    if (Test-Path -LiteralPath $sortida) {
        $pfx = Get-ChildItem -LiteralPath $sortida -Filter *.pfx | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($pfx) { return $pfx.FullName }
    }
    return $null
}

function Read-Contrasenya {
    $password = Read-Host "Contrasenya del certificat (deixeu-la buida si no en té)" -AsSecureString
    if ($password.Length -eq 0) { return $null }
    return $password
}

function Invoke-Generar {
    $nom = Read-Valor -Pregunta "Nom del certificat (CommonName)"
    $inici = Read-Data -Pregunta "Data d'inici" -PerDefecte (Get-Date).Date
    $final = Read-Data -Pregunta "Data de final" -PerDefecte $inici.AddYears(1)

    & (Join-Path $root 'Create-SelfSignedCertificate.ps1') -CommonName $nom -StartDate $inici -EndDate $final -OutputPath $sortida

    Write-Host ""
    Write-Host "Següent pas: pugeu el fitxer .cer a Entra ID > App registrations > <aplicació> > Certificates & secrets > Certificates > Upload certificate." -ForegroundColor Cyan
}

function Invoke-Codificar {
    $pfx = Read-Valor -Pregunta "Ruta del fitxer .pfx" -PerDefecte (Get-DarrerPfx)
    & (Join-Path $root 'base64_encoder.ps1') -PfxPath $pfx
}

function Invoke-Comprovar {
    if ($PSVersionTable.PSVersion -lt [Version]"7.2") {
        Write-Host "La comprovació necessita PowerShell 7.2 o superior. Instal·leu-lo (winget install Microsoft.PowerShell) i torneu a obrir Inicia.cmd." -ForegroundColor Red
        return
    }
    $clientId = Read-Valor -Pregunta "Application (client) ID de l'aplicació"
    $tenant = Read-Valor -Pregunta "Directory (tenant) ID o domini del tenant"
    $siteUrl = Read-Valor -Pregunta "URL del site (ex. https://<tenant>.sharepoint.com/sites/<site>)"
    $pfx = Read-Valor -Pregunta "Ruta del fitxer .pfx" -PerDefecte (Get-DarrerPfx)
    $password = Read-Contrasenya

    $params = @{ ClientId = $clientId; Tenant = $tenant; SiteUrl = $siteUrl; PfxPath = $pfx }
    if ($password) { $params.Password = $password }
    & (Join-Path $root 'check-connection.ps1') @params
}

while ($true) {
    Clear-Host
    Write-Host "=== Generador de certificats ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  1. Generar un certificat (.pfx i .cer)"
    Write-Host "  2. Codificar un .pfx en Base64"
    Write-Host "  3. Comprovar la connexió a SharePoint"
    Write-Host "  4. Obrir la carpeta de sortida"
    Write-Host "  0. Sortir"
    Write-Host ""
    $opcio = Read-Host "Trieu una opció"

    try {
        switch ($opcio) {
            '1' { Invoke-Generar }
            '2' { Invoke-Codificar }
            '3' { Invoke-Comprovar }
            '4' {
                if (-not (Test-Path -LiteralPath $sortida)) { New-Item -ItemType Directory -Path $sortida | Out-Null }
                Invoke-Item -LiteralPath $sortida
            }
            '0' { exit }
            default { Write-Host "Opció no vàlida." -ForegroundColor Red }
        }
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }

    Write-Host ""
    Read-Host "Premeu Retorn per tornar al menú" | Out-Null
}
