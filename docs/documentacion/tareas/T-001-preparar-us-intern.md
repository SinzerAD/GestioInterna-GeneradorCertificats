---
id: T-001
titulo: Preparar el repositori per a ús intern
estado: completada
asignada_a: agent principal
rama: chore/preparar-us-intern (integrada a main)
creada: 2026-10-20
actualizada: 2026-10-20
depende_de: []
bloqueo: null
---

## Objectiu

Que qualsevol persona de l'empresa pugui generar i comprovar certificats d'aplicació sense editar codi i sense publicar dades confidencials.

## Contracte

- **Escriptura:** scripts `*.ps1`, `Inicia.cmd`, `README.md`, `.gitignore`, `.gitattributes`, `docs/documentacion/`.
- **Prohibit:** versionar certificats, la guia `.docx` o qualsevol dada de client; canviar la lògica de generació del certificat.

## Acceptació i validació

- [x] Sense secrets ni dades de client als fitxers versionats.
- [x] Anàlisi sintàctica sense errors a PowerShell 7 i 5.1.
- [x] `base64_encoder.ps1` i les validacions de `check-connection.ps1` provats.
- [x] Generar un certificat amb `Inicia.cmd` com a administrador (validat per l'usuari el 2026-10-20).
- [x] Comprovar una connexió real a SharePoint (validat per l'usuari el 2026-10-20).

## Notes

Detall i motius a `docs/documentacion/MEMORIA_DECISIONES.md`.
