# Generador de certificats

Eines per crear el certificat autosignat d'una aplicació d'Entra ID i connectar-se a SharePoint Online amb PnP.PowerShell sense usuari ni contrasenya.

El procés té tres passos:

1. **Generar** el certificat: es creen un `.pfx` (amb la clau privada) i un `.cer` (només la part pública).
2. **Pujar** el `.cer` a l'aplicació d'Entra ID.
3. **Comprovar** que la connexió a SharePoint funciona amb el `.pfx`.

## Requisits

- Windows amb permisos d'administrador local (per generar el certificat).
- L'aplicació ja registrada a Entra ID, amb els permisos de SharePoint que calguin.
- Per comprovar la connexió:
  - PowerShell 7.2 o superior: `winget install Microsoft.PowerShell`
  - El mòdul PnP.PowerShell: `Install-Module PnP.PowerShell -Scope CurrentUser`

## Ús ràpid: l'assistent

Feu doble clic a **`Inicia.cmd`**. Demanarà permisos d'administrador i obrirà aquest menú:

```
=== Generador de certificats ===

  1. Generar un certificat (.pfx i .cer)
  2. Codificar un .pfx en Base64
  3. Comprovar la connexió a SharePoint
  4. Obrir la carpeta de sortida
  0. Sortir
```

Tots els fitxers es desen a la carpeta **`sortida`**, dins d'aquesta mateixa carpeta.

### 1. Generar el certificat

Demana:

- **Nom del certificat**: per exemple, el nom de l'aplicació (`LaMevaAplicacio`).
- **Data d'inici** i **data de final**, en format `AAAA-MM-DD`. Per defecte, avui i d'aquí a un any.
- **Contrasenya**: si la deixeu buida, no caldrà indicar-la en connectar-vos. Si en poseu una, caldrà indicar-la cada cop.

Es creen `sortida\<nom>.pfx` i `sortida\<nom>.cer`.

### 2. Pujar el `.cer` a Entra ID

Al [portal d'Azure](https://portal.azure.com):

1. **Microsoft Entra ID** → **App registrations** → obriu l'aplicació.
2. **Manage** → **Certificates & secrets** → pestanya **Certificates**.
3. **Upload certificate** i trieu el fitxer `.cer`.

Apunteu-vos, de la pàgina **Overview** de l'aplicació, l'**Application (client) ID** i el **Directory (tenant) ID**: els necessitareu per comprovar la connexió.

### 3. Comprovar la connexió

L'opció 3 del menú demana l'Application (client) ID, el tenant, la URL del site i el `.pfx` (per defecte, el darrer generat). Si tot és correcte veureu:

```
Connexió correcta al site: https://<tenant>.sharepoint.com/sites/<site> (<títol del site>)
```

### Codificar en Base64 (opcional)

Algunes aplicacions demanen el certificat com a text en Base64 en lloc del fitxer `.pfx`. L'opció 2 del menú el genera, el desa a `sortida\<nom>.base64.txt` i el copia al porta-retalls.

## Ús des de la consola

Els scripts també es poden fer servir sols, des d'una consola de PowerShell oberta a aquesta carpeta.

```powershell
# Com a administrador
.\Create-SelfSignedCertificate.ps1 -CommonName LaMevaAplicacio -StartDate 2026-01-01 -EndDate 2027-01-01 -OutputPath .\sortida

.\base64_encoder.ps1 -PfxPath .\sortida\LaMevaAplicacio.pfx

# Amb PowerShell 7.2 o superior
.\check-connection.ps1 -ClientId <application-id> -Tenant <tenant-id> -SiteUrl https://<tenant>.sharepoint.com/sites/<site> -PfxPath .\sortida\LaMevaAplicacio.pfx
```

Si el certificat té contrasenya, afegiu `-Password (Read-Host -AsSecureString)` a `check-connection.ps1`. També accepta `-Base64Path` en lloc de `-PfxPath`.

Amb `Get-Help .\<script>.ps1 -Full` es veuen tots els paràmetres.

## Seguretat

- El `.pfx` i el `.base64.txt` contenen la **clau privada**: qui els tingui pot connectar-se com l'aplicació. Guardeu-los en un lloc segur (per exemple, un Key Vault o el gestor de contrasenyes de l'empresa) i esborreu-los de `sortida` quan ja no els necessiteu.
- **No poseu mai certificats, AppIds, tenants ni URLs de clients dins dels scripts**: passeu-los com a paràmetres.
- El `.gitignore` impedeix pujar `sortida\`, `*.pfx`, `*.cer` i `*.base64.txt` al repositori.
- Si un certificat s'ha compartit per error, elimineu-lo de **Certificates & secrets** de l'aplicació i genereu-ne un de nou.

## Problemes habituals

| Missatge | Solució |
|---|---|
| `...cannot be loaded because running scripts is disabled...` | Obriu-ho amb `Inicia.cmd`, o executeu `powershell -ExecutionPolicy Bypass -File .\<script>.ps1`. Si heu descarregat el repositori en un `.zip`, feu `Get-ChildItem *.ps1, *.cmd \| Unblock-File`. |
| `Ja hi ha un o més certificats amb el mateix nom...` | Feu servir un altre nom o afegiu `-Force` per substituir el certificat del magatzem local. |
| `Aquest script necessita PowerShell 7.2 o superior` | `winget install Microsoft.PowerShell` i torneu a obrir `Inicia.cmd`. |
| `No es troba el mòdul PnP.PowerShell` | `Install-Module PnP.PowerShell -Scope CurrentUser` |
| Error d'autenticació en connectar | Comproveu que el `.cer` pujat és el del mateix `.pfx`, que l'AppId i el tenant són correctes, que el certificat no ha caducat i que l'aplicació té permisos de SharePoint amb consentiment d'administrador. |
