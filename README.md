# KnuMail

Buzón simple y seguro para **World of Warcraft: Forever** (1.60.1, `## Interface: 16001`).

**Estado:** 0.1.0-beta. Probado en el juego con correos de subasta; tests con `lua tests/run.lua`.

## Qué hace

- Abrir todo con filtros por tipo de correo, espacios libres reservados y resumen de oro.
- Saltea los correos con oro de desconocidos (ni alter, ni amigo, ni hermandad); si lo abrís desde las casillas o el clic derecho, pide confirmación.
- Casillas para abrir o devolver sólo lo marcado.
- Libreta de destinatarios (ícono junto a «Para:»): alters con nombre completo, recientes, amigos y hermandad.
- Clic derecho en una fila: tomar el contenido, devolverlo o marcar los de ese remitente.
- Con Enviar abierto, Alt-clic en un objeto de las bolsas lo adjunta.
- Tooltip de la bandeja con cada adjunto una sola vez.

## Documentos

- [Investigación previa](docs/investigacion.md): por qué correo, competencia y datos de la API de Forever.
- [Diseño](docs/superpowers/specs/2026-11-13-knumail-design.md).
- [Plan de implementación](docs/superpowers/plans/2026-11-13-knumail.md).
- [Textos para CurseForge](docs/curseforge.md).

## Medios

`python tools/generar_media.py` regenera `media/*.tga` (juego) y `tools/preview/*.png`
(avatar 400×400 y banner 1200×400 para CurseForge). Misma identidad que KnuUI.

## Licencia

MIT. Código propio: no contiene código de Postal ni de sus ports.
