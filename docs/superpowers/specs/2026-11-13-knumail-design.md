# KnuMail: diseño (versión 1, núcleo)

Fecha: 2026-11-13 · Estado: listo para aprobación (revisado por un constructor independiente) · Nombre provisorio

## 1. Para qué y por qué

Addon de buzón para **WoW Forever** (cliente 1.60.1.70938, `## Interface: 16001`), escrito desde cero y publicado en CurseForge, que compite con **Posty Forever** (24,6K descargas al 2026-11-13).

- **Por qué hay lugar:** Posty se declara un port de Postal 4.3.4 («Posty brings Postal... It is a full port of Postal v4.3.4») bajo la licencia de Postal, «All Rights Reserved». Los otros (Postmester, Postal Forever, Glass Mail, Postage) tienen entre 28 y 5,3K descargas.
- **Qué valoran los usuarios** (comentarios en CurseForge, leídos el 2026-11-13): que sea **simple** («All the other mail add-ons out there are trying way too hard»), que funcione «sólo oro» y que el autor arregle rápido.
- **Quejas abiertas de la competencia:**
  - Posty muestra los adjuntos duplicados en el tooltip cuando un correo trae más de uno.
  - Posty juntó los botones de adjuntar rápido por tipo de material en uno solo.
  - En Postmester, la selección de una página se arrastra a la siguiente y se abren correos de las dos.

## 2. Objetivos, no objetivos y anti-objetivos

**Objetivos (v1):**
1. **Abrir todo con filtros:** elegir qué tipos de correo abrir, «sólo oro», reservar espacios libres en las bolsas y mostrar un resumen del oro cobrado.
2. **Selección por casillas:** abrir o devolver sólo los correos marcados, con una selección que nunca se arrastra entre páginas.
3. **Libreta de destinatarios:** alters, recientes, amigos y hermandad, con nombre completo (nombre y apellido).
4. **Atajos de clic:** Shift-clic toma, Ctrl-clic devuelve, Alt-clic adjunta desde las bolsas.
5. **Tooltip de la bandeja:** cada adjunto aparece una sola vez.

**No objetivos (v1):** reenviar, copiar texto (CarbonCopy), adjuntar rápido por material (va primero en la v2), envío masivo, bloquear comercio, perfiles, skin propio y otros idiomas además de inglés y castellano.

**Anti-objetivos** (fracasa aunque funcione si...):
- Abre correos que el jugador no pidió, en especial oro de desconocidos (riesgo de ban por RMT, [hilo 2375119](https://us.forums.blizzard.com/en/wow/t/2375119)) o contra reembolso.
- Rompe el botón nativo o deja la interfaz con errores (*taint*).
- Necesita configuración antes del primer uso.
- Comparte código con Postal o Posty.

## 3. Restricciones verificadas (código de Forever, rama `forever` de Gethe/wow-ui-source, 1.60.1.70938)

| Hecho | Fuente |
|---|---|
| La bandeja se actualiza con el método `InboxFrame:Update()` (mixin `InboxMixin`). No existe la función global `InboxFrame_Update` | `Blizzard_MailFrame/MailFrame.lua:316` |
| Hay botón nativo «Abrir todo» (`OpenAllMailMixin`): un objeto cada 0,15 s, saltea GM y contra reembolso, usa `C_Mail.SetOpeningAll` y el evento `MAIL_OPEN_ALL_CANCELED` | `MailFrame.lua:1515-1680` |
| La UI propia de Forever llama a `GetInboxNumItems`, `GetInboxHeaderInfo`, `GetInboxItem`, `TakeInboxItem`, `TakeInboxMoney`, `AutoLootMailItem`, `ReturnInboxItem`, `DeleteInboxItem`, `CheckInbox`, `GetInboxInvoiceInfo`, `ClickSendMailItemButton`, `SetSendMailMoney` | conteo de llamadas en `MailFrame.lua` |
| `C_Mail`: `CanCheckInbox`, `HasInboxMoney`, `IsCommandPending`, `SetOpeningAll`. Eventos `MAIL_SHOW`, `MAIL_CLOSED`, `MAIL_INBOX_UPDATE`, `MAIL_SUCCESS`, `MAIL_FAILED`, `MAIL_SEND_SUCCESS`, `MAIL_LOCK/UNLOCK_SEND_ITEMS` | `MailInfoDocumentation.lua` |
| `SendMail` tiene `HasRestrictions = true`. KnuMail no envía correos por su cuenta: sólo completa campos | `SecureTransferDocumentation.lua:91` |
| `UnitFullName` existe. `RegionalUniqueNamesEnabled` existe. Forever no separa servidores | `UnitDocumentation.lua:1224`, `:536`; foro |
| `UIDropDownMenu` está en la familia Mainline y `MenuUtil` también existe | `Blizzard_SharedXML/Mainline/`, `Blizzard_SharedXML.toc:216-219` |

**Sin verificar** (se prueba en el juego antes de construir encima; lección de KnuHelm, donde `ShowCloak` estaba documentada y no hacía nada):
- Si `UnitName("player")` devuelve el apellido como segundo valor (Posty dice que sí; la documentación dice «unitServer»).
- Si `UIDropDownMenu` funciona para addons en Forever (Posty dice que no y armó la suya).
- Si se puede cambiar el comportamiento del botón nativo sin *taint*, o hay que poner uno propio al lado.

### 3.1 Prueba en el juego antes de construir (paso 1 del plan)
El dueño tiene el cliente de Forever y corre las pruebas que le pasemos con `/dump` o `/run` (así se probó KnuHelm el 2026-11-13). El plan empieza con esta prueba, y el código se arma en capas intercambiables por si alguna sale mal:
1. `UnitName("player")` y `UnitFullName("player")`: qué devuelve cada una.
2. Formato del remitente en `GetInboxHeaderInfo` frente a la lista de amigos (`C_FriendList.GetFriendInfoByIndex`) y la hermandad (`GetGuildRosterInfo`): ¿nombre de pila, nombre y apellido, con servidor?
3. Si existen y qué dicen `AUCTION_EXPIRED_MAIL_SUBJECT`, `AUCTION_REMOVED_MAIL_SUBJECT`, `AUCTION_OUTBID_MAIL_SUBJECT`, `AUCTION_SOLD_MAIL_SUBJECT` y `AUCTION_WON_MAIL_SUBJECT`. No están en el código de la UI publicado, así que hay que verlos en el juego.
4. Un menú con `UIDropDownMenu` y otro con `MenuUtil` creados por un addon: cuál abre sin errores.
5. Ocultar el botón nativo `OpenAllMail` y usar uno propio: ¿aparece el aviso de *taint* o «Interface action blocked»?

## 4. Enfoques considerados

| Enfoque | A favor | En contra |
|---|---|---|
| **A. Independiente, sin librerías** (elegido) | Liviano, sin dependencias, mismo estilo que KnuUI (textos con `Locales.lua`, el inglés como clave) | Hay que escribir a mano la base de datos guardada y el menú de opciones |
| B. Con Ace3 (AceAddon/AceDB/AceLocale), como Postal | Perfiles y localización resueltos | +100 KB de librerías; el usuario valora lo simple |
| C. Módulo dentro de KnuUI | Reusa la infraestructura | Exige ElvUI: deja afuera a la mayoría del público |

Elegido **A** (decisión de Claude, no discutida). Motivo: el público premia lo simple, y C achica el mercado.

## 5. Diseño de la v1

### 5.1 Abrir todo con filtros
- **Botón:** «Abrir todo» propio junto al nativo. Si la prueba de *taint* sale bien, reemplazar el nativo; si no, se oculta el nativo y queda el propio.
- **Menú del botón** (flecha al costado), con valores por defecto:
  - Ventas de subasta: sí.
  - Subastas ganadas: sí.
  - Expiradas: sí.
  - Canceladas: sí.
  - Superado en la puja: sí.
  - Otros con adjuntos: sí.
  - **Correos con oro de jugadores que no son alters ni amigos ni de la hermandad: no** (anti-objetivo RMT; regla completa en 5.8a).
  - Reservar espacios libres en las bolsas: 0.
- **Siempre se saltean:** contra reembolso y GM (igual que el nativo).
- **«Sólo oro»:** Alt-clic en el botón, o una opción fija.
- **Ritmo:** un objeto por vez. Se espera a `MAIL_SUCCESS` o `MAIL_INBOX_UPDATE` y a que `C_Mail.IsCommandPending()` dé falso, con un mínimo de 0,15 s entre objetos (el valor del nativo).
- **Corta cuando:**
  - Quedan sólo los espacios reservados.
  - El juego avisa que las bolsas están llenas (`UI_ERROR_MESSAGE` con el error de inventario lleno).
  - Se cierra el buzón.
  - Aparece `MAIL_OPEN_ALL_CANCELED`.
  - El jugador vuelve a hacer clic.
- **Bandeja de más de 50 correos:** al terminar, pide `CheckInbox()` cuando `C_Mail.CanCheckInbox()` lo permite y sigue con los nuevos.
- **Resumen en el chat:** oro total cobrado, cantidad de correos abiertos y cuántos se saltearon y por qué.

### 5.2 Selección por casillas
- Una casilla por fila con el número de correo. **La selección se guarda por identidad del correo** (remitente, asunto, oro y la hora del envío calculada al recibirlo; su construcción queda para el constructor), no por posición en la página. Así se evita el bug de Postmester.
- **Atajos:** Shift-clic marca el rango entre dos casillas; Ctrl-clic marca todo lo de ese remitente.
- **Botones** «Abrir marcados» y «Devolver marcados». Devolver nunca toca los correos que el juego no permite devolver (de subasta y de GM).

### 5.3 Libreta de destinatarios
- Menú junto al campo «Para» con 4 listas:
  - **Alters:** se registran al entrar con cada personaje; nombre completo, nivel y clase.
  - **Recientes:** los últimos 20.
  - **Amigos.**
  - **Hermandad.**
- ~~Autocompletar mientras se escribe~~: descartado el 2026-11-13 en la prueba en el juego. Forever ya trae autocompletado en «Para:» (`AutoCompleteEditBoxTemplate`, `MailFrame.xml:593`) y el propio se pisaba con ese; decisión del dueño: sacarlo.
- Opción «recordar último destinatario», apagada por defecto.

### 5.4 Atajos de clic
- **En la bandeja:** Shift-clic toma todo el correo; Ctrl-clic lo devuelve.
- **Con la pestaña de envío abierta:** Alt-clic sobre un objeto de las bolsas lo adjunta.

### 5.5 Tooltip
- Al pasar el mouse por un correo de la bandeja: lista de adjuntos con cantidades, cada uno una vez, y oro y contra reembolso si hay.

### 5.6 Datos guardados
- `KnuMailDB` (por cuenta): `alts[nombreCompleto] = {class, level, faction}`, `recent = {...}` (máx. 20) y `settings`.
- Los alters se guardan por nombre completo, porque en Forever dos personajes pueden compartir el nombre de pila.

### 5.7 Textos
- Inglés como clave y castellano (esES/esMX), igual que KnuUI. El resto, en v2.

### 5.8a Correos de desconocidos (decidido por el dueño, 2026-11-13)
- «Abrir todo» **saltea entero** cualquier correo de un desconocido (ni alter, ni amigo, ni de la hermandad, ni de la subasta) que traiga oro. No toma ni el oro ni los objetos de ese correo.
- Los correos de desconocidos **sólo con objetos se abren** normalmente.
- Lo marcado con casillas se abre siempre, porque el jugador lo eligió, salvo los contra reembolso, que el juego exige confirmar a mano.
- El resumen del chat informa cuántos correos de desconocidos con oro quedaron sin abrir.

### 5.8 Reglas de detalle (decisiones de Claude tras la revisión; el dueño puede cambiarlas)
- **Clasificación de tipos:**
  - Ventas y compras de subasta: por `GetInboxInvoiceInfo` (`invoiceType` = `seller` o `buyer`; así lo usa Forever en `MailFrame.lua:576` y `:790`).
  - Expiradas, canceladas y superadas: por el asunto, comparado con las cadenas globales del cliente (prueba 3.1.3), nunca con texto fijo. Así funciona en cualquier idioma.
- **Comparación de nombres:** se normaliza todo a un mismo formato según la prueba 3.1.2. Sólo amigos del personaje y amigos de Battle.net que estén conectados en Forever; si el formato no se puede igualar, el remitente cuenta como desconocido (falla del lado seguro).
- **Atajos sobre la fila**, no sobre el ícono del adjunto: Shift-clic toma y Ctrl-clic devuelve, como Postal. El Ctrl-clic sobre íconos (vista previa) queda como está.
- **Casillas:** Shift-clic marca rangos sólo dentro de la página visible. Ctrl-clic marca todo lo del remitente en toda la bandeja. Si dos correos tienen la misma identidad, se desempata por su orden en la bandeja.
- **Alt-clic en «Abrir todo»:** «sólo oro» por esa vez. La opción fija del menú lo deja siempre así.
- **Dónde vive:** repo `E:\Repositorios\Personal\KnuMail` (convenciones de `E:\Repositorios\Personal\KnuUI`: `Locales.lua`, `tests/`, `.pkgmeta`, licencia MIT). La v1 se entrega con `.pkgmeta`; la ficha de CurseForge va aparte, cuando el dueño decida publicar.

## 6. Lo que queda para el constructor
- Distribución exacta de botones y casillas en `InboxFrame` (respetando su tamaño; no tapar los botones de página, que es la queja visual que tuvo Postmester).
- Cómo construir la identidad estable de cada correo.
- Si usa `UIDropDownMenu`, `MenuUtil` o un menú propio, según la prueba en el juego.
- Estructura de archivos y pruebas fuera del juego. KnuUI tiene `tests/verificar.lua`, que corre con Lua 5.1; en esta PC no hay Lua instalado, sólo se comprobó la sintaxis con `luaparse`.

## 7. Decisiones abiertas para el dueño
- **Nombre definitivo:** «KnuMail» no aparece en CurseForge (búsqueda del 2026-11-13).
- **Licencia:** MIT, como KnuUI (propuesta).
