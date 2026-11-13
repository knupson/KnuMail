# Investigación previa (2026-11-13)

Cómo se llegó a KnuMail. Sale de una sesión de Claude Code del 2026-11-13. Todos los datos se leyeron ese día; con el ritmo de Forever (decenas de addons nuevos por semana) pueden envejecer rápido.

## 1. Búsqueda de huecos en Forever (descartada)

- **Fuentes:**
  - Foros oficiales: US «Forever General», «Beta» y «Bug Report»; EU «Forever General». Se consultaron con la API JSON de Discourse: `search.json` y `t/<id>.json`.
  - CurseForge, filtro Forever: `gameVersionTypeId=88568`.
- **Pedidos que ya tenían addon:**
  - Bloquear objetos (Item Lock Forever).
  - Notas sobre jugadores (iWillRemember).
  - Fragmentos de alma (Soul Shards Forever).
  - Medidor de amenaza (ForeverThreat).
  - Guardar barras por spec (ActionBarSaver: Reloaded).
  - Destellos de recursos (Forever Loot Sparkles).
  - Timer de raros: RareNet. Su descripción dice «back in 4h-7h» por layer.
  - Rueda de hechizos para gamepad (Improved Forever: Wheel).
  - Rastrear hierbas y minerales a la vez (Tracking Eye).
  - Mapas de mazmorras (Dungeon Lens, HiddenMaps).
  - Sellos de paladín (Seal Timers Forever).
  - Correo: 6 reemplazos de Postal.
- **Pedidos que la API no permite:**
  - **Ocultar casco/capa:** `ShowHelm`/`ShowCloak` están documentadas en 1.60.1.70938, pero probadas en el juego no hicieron nada. Así murió KnuHelm.
  - **Estadísticas en combate:** los valores de la hoja quedan bloqueados en combate.
  - **Combat log:** `COMBAT_LOG_EVENT_UNFILTERED` tiene `HasRestrictions = true`.
  - **Auras:** se ocultan cuando están restringidas (`SecretWhenUnitAuraRestricted`).
  - **Reemplazo de sonidos:** la carpeta de sonidos propios ya no funciona.
- **Lección:** que una función esté documentada no garantiza que funcione. Se prueba con `/run` en el juego antes de construir encima.

## 2. Elección de categoría

Medición de las 44 categorías de CurseForge para Forever, más una revisión a fondo de Camping, Correo y Profesiones:

| Categoría | Líder (descargas, antigüedad) | Por qué sí o no |
|---|---|---|
| Correo (elegida) | Posty Forever, 24,6K, 1 mes | Líder alcanzable; Posty es un port de Postal bajo «All Rights Reserved» |
| Camping | Happy Camper, 35,2K, 1 mes | Las quejas del foro son reglas o bugs de Blizzard; timers y mapa ya están cubiertos |
| Profesiones | Mastercraft, 533K, 1 mes | El líder es completo y está muy por delante |

## 3. La competencia en correo

| Addon | Descargas | Licencia | Notas |
|---|---|---|---|
| Posty Forever | 24,6K | All Rights Reserved | `.toc`: «Author: Xinhuan & Postal authors (Forever port: Daeler)». Diferencias con Postal 4.3.5 por módulo: Rake 4 líneas, Wire 8, Select 37, OpenAll 85, BlackBook 285 |
| Postmester Forever | 5,3K | MIT | Código propio, 9.029 líneas de Lua |
| Postal Forever | 5,0K | — | Correo entre alters |
| Glass Mail | 118 | — | Grilla de adjuntos, historial |
| Postage - Forever | 28 | — | — |

**Comentarios de usuarios** (CurseForge):
- Posty:
  - Lo eligen por simple: «All the other mail add-ons out there are trying way too hard».
  - Abierto: los adjuntos salen duplicados en el tooltip.
  - Abierto: juntaron en un solo botón los botones de adjuntar rápido por material.
  - Resuelto: pidieron «sólo oro».
  - Resuelto: sacaron el nombre de servidor.
- Postmester: la selección de una página se arrastra a la siguiente.

**Postal original:** v4.3.5, Retail 12.1.0, 35,7M descargas, «All Rights Reserved». No tiene versión para Forever. KnuMail no usa su código.

## 4. Datos técnicos de Forever

Fuente: rama `forever` de `github.com/Gethe/wow-ui-source`, build 1.60.1.70938, igual al cliente instalado.

- **Cliente:** el `.build.info` dice `1.60.1.70938 wowf`. `## Interface: 16001`. Carga la familia `Mainline` y el juego `Camelot`.
- **Bandeja:** `InboxMixin:Update()` (`Blizzard_MailFrame/MailFrame.lua:316`). No existe la función global `InboxFrame_Update`.
- **Botón nativo «Abrir todo»:** `OpenAllMailMixin` (`MailFrame.lua:1515-1680`). Abre un objeto cada 0,15 s y saltea GM y contra reembolso.
- **`C_Mail`:** `CanCheckInbox`, `HasInboxMoney`, `IsCommandPending`, `SetOpeningAll`. `SendMail` tiene `HasRestrictions = true`.
- **Sin probar en el juego:**
  - Si `UnitName` devuelve el apellido como segundo valor (Posty dice que sí; la documentación dice «unitServer»).
  - Si `UIDropDownMenu` sirve para addons (Posty dice que no; los archivos están en `Blizzard_SharedXML/Mainline/`).
- **Política del dueño ante el riesgo de ban por RMT** ([hilo 2375119](https://us.forums.blizzard.com/en/wow/t/2375119)): «Abrir todo» saltea los correos con oro de desconocidos.
