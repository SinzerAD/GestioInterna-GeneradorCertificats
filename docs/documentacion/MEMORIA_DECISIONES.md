# Memòria de decisions

Entrades més recents primer.

## 2026-10-20 · Preparar el repositori per a ús intern sense dades confidencials

- **Context:** els scripts venien d'un projecte de client. `check-connection.ps1` tenia incrustats un certificat `.pfx` en Base64 (amb clau privada), l'AppId, el tenant i la URL del site. La guia `DocuGenerarCertificats.docx` té captures amb dades reals del client (certificat en Base64, AppId, site, compte d'administrador).
- **Decisió (aprovada per l'usuari):**
  - Els scripts no contenen cap dada de client: tot es passa per paràmetre.
  - La guia `.docx` no es versiona (`.gitignore`); el `README.md` la substitueix, sense captures.
  - Els fitxers generats van a `sortida/`, i `*.pfx`, `*.cer` i `*.base64.txt` s'ignoren.
  - S'afegeix un assistent amb menú (`Inicia.cmd` / `Inicia.ps1`) que s'eleva a administrador.
  - La lògica de generació del certificat de `Create-SelfSignedCertificate.ps1` no es modifica; només s'hi afegeixen `-OutputPath`, la validació de dates i missatges en català.
  - El repositori només té `main`; el treball es fa en una branca des de `main`, sense crear `pre`/`pro`.
- **Motiu:** que qualsevol persona de l'empresa ho pugui fer servir sense editar codi i sense risc de publicar secrets.
- **Impacte:** `check-connection.ps1` canvia d'interfície (paràmetres obligatoris `-ClientId`, `-Tenant`, `-SiteUrl` i `-PfxPath` o `-Base64Path`). `base64_encoder.ps1` desa el resultat al costat del `.pfx` amb el nom `<nom>.base64.txt`, en lloc de `Certificat-Base64.txt` a la carpeta de l'script.
- **Validació:** anàlisi sintàctica sense errors a PowerShell 7.5 i 5.1; `base64_encoder.ps1` provat amb una ruta entre cometes i amb espais (el Base64 i el porta-retalls coincideixen); `check-connection.ps1` provat en els casos sense certificat, amb un fitxer inexistent i amb PowerShell 5.1.
- **Validació de l'usuari (2026-10-20):** l'assistent i la connexió funcionen correctament.
- **Pendent:** revocar a Entra ID els certificats que estaven incrustats o capturats, perquè s'havien compartit fora del repositori.
