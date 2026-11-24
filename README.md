# KnuMail

Buzón simple y seguro para **World of Warcraft: Forever** (1.60.1, `## Interface: 16001`).

**Estado:** 0.1.3-beta. Probado en el juego con correos de subasta; tests con `lua tests/run.lua`.

## Qué hace

- Abrir todo con filtros por tipo de correo, espacios libres reservados y resumen de oro. Los filtros están en el botón Opciones, al lado de Abrir todo.
- Saltea los correos con oro de desconocidos (ni alter, ni amigo, ni hermandad); si lo abrís desde las casillas o el clic derecho, pide confirmación.
- Casillas para abrir o devolver sólo lo marcado.
- Libreta de destinatarios (ícono junto a «Para:»): alters con nombre completo, recientes, amigos y hermandad.
- Clic derecho en una fila: tomar el contenido, devolverlo o marcar los de ese remitente.
- Con Enviar abierto, Alt-clic en un objeto de las bolsas lo adjunta.
- Al adjuntar un objeto, el asunto se completa con su nombre (y la cantidad si es una pila), salvo que ya hayas escrito uno.
- Tooltip de la bandeja con cada adjunto una sola vez.

## Documentos

- [Investigación previa](docs/investigacion.md): por qué correo, competencia y datos de la API de Forever.
- [Textos para CurseForge](docs/curseforge.md).

## Medios

`python tools/generar_media.py` regenera `media/*.tga` (juego) y `tools/preview/*.png`
(avatar 400×400 y banner 1200×400 para CurseForge). Misma identidad que KnuUI.

## Otros addons de KNU

**[KnuCompanion](https://companion.knunet.com)**: tus bolsas, banco, mapa y misiones en tu otro monitor. App de escritorio y addon ([CurseForge](https://www.curseforge.com/wow/addons/knucompanion)).

- [KnuUI](https://www.curseforge.com/wow/addons/knuui): layout compacto ámbar para ElvUI.
- [KnuJunk](https://www.curseforge.com/wow/addons/knujunk): marca y vende lo que no sirve, y repara solo.
- [KnuCast](https://www.curseforge.com/wow/addons/knucast): marca en las barras qué hechizos sirven contra el objetivo.

Todos los proyectos: https://www.curseforge.com/members/knupwns/projects

## Opiniones y errores

Si KnuMail te sirve, marcalo como favorito en CurseForge (la estrella) y dejá un comentario: así lo encuentran otros jugadores de Forever.

Si encontrás un error, abrí un issue en https://github.com/knupson/KnuMail/issues o dejá un comentario con el texto del error (BugSack lo copia) y qué estabas haciendo.

Las ideas y los pedidos, igual: en un comentario o en un issue.

### Other KNU addons (English)

**[KnuCompanion](https://companion.knunet.com)**: your bags, bank, map and quests on your other monitor. Desktop app plus addon ([CurseForge](https://www.curseforge.com/wow/addons/knucompanion)).

- [KnuUI](https://www.curseforge.com/wow/addons/knuui): compact amber layout for ElvUI.
- [KnuJunk](https://www.curseforge.com/wow/addons/knujunk): marks and sells junk, and repairs on its own.
- [KnuCast](https://www.curseforge.com/wow/addons/knucast): marks on your action bars which spells work against your target.

All projects: https://www.curseforge.com/members/knupwns/projects

### Feedback (English)

If KnuMail is useful to you, add it to your favorites on CurseForge (the star) and leave a comment. That is how other Forever players find it.

Found a bug? Open an issue at https://github.com/knupson/KnuMail/issues or leave a comment. Include the error text (BugSack copies it for you) and what you were doing.

Send ideas and requests the same way, as a comment or an issue.

## Licencia

MIT. Código propio: no contiene código de Postal ni de sus ports.
