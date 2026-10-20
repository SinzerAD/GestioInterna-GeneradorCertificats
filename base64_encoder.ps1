<#
.SYNOPSIS
Codifica en Base64 un certificat .pfx.
.DESCRIPTION
Si no s'indica -PfxPath, es demana la ruta per pantalla.
El resultat es desa al costat del .pfx (<nom>.base64.txt) i es copia al porta-retalls.
.EXAMPLE
.\base64_encoder.ps1 -PfxPath .\sortida\ElMeuCertificat.pfx
#>
Param(
    [Parameter(Mandatory = $false)]
    [string]$PfxPath
)

# Funció per validar l'existència d'un fitxer
function Validate-FilePath {
    param(
        [string]$FilePath
    )
    if ([string]::IsNullOrWhiteSpace($FilePath) -or -not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        Write-Host "Error: El fitxer '$FilePath' no existeix. Torneu a introduir una ruta vàlida." -ForegroundColor Red
        return $false
    }
    return $true
}

# Accepta rutes enganxades amb cometes ("Copia com a camí" de l'Explorador)
if ($PfxPath) {
    $PfxPath = $PfxPath.Trim().Trim('"')
}

# Demanar la ruta del fitxer PFX a l'usuari si no s'ha indicat o no és vàlida
while (-not (Validate-FilePath -FilePath $PfxPath)) {
    $PfxPath = (Read-Host "Introduïu la ruta del fitxer PFX (ex. C:\ruta\a\fitxer.pfx)").Trim().Trim('"')
}

$pfxFullPath = (Resolve-Path -LiteralPath $PfxPath).Path

# Llegir el fitxer PFX com un array de bytes i codificar-lo a Base64
$pfxBytes = [System.IO.File]::ReadAllBytes($pfxFullPath)
$base64Encoded = [Convert]::ToBase64String($pfxBytes)

# Mostrar el certificat en Base64
Write-Host "Certificat PFX codificat en Base64:"
Write-Host $base64Encoded

# Guardar el certificat Base64 al costat del .pfx
$base64Path = Join-Path -Path (Split-Path -Path $pfxFullPath -Parent) -ChildPath "$([System.IO.Path]::GetFileNameWithoutExtension($pfxFullPath)).base64.txt"
$base64Encoded | Out-File -FilePath $base64Path -Encoding ascii
Write-Host "Certificat Base64 guardat a: $base64Path" -ForegroundColor Green

try {
    Set-Clipboard -Value $base64Encoded
    Write-Host "També s'ha copiat al porta-retalls." -ForegroundColor Green
} catch {
    # El porta-retalls és només una comoditat
}
