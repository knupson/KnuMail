# CurseForge page

Text to paste into the CurseForge project, checked against the code on 2026-11-16.

Summary (max one line):

> A simple, safe mailbox for WoW Forever: open all with filters, tick the mails you want, an address book with your alts, and gold from strangers left alone.

---

## Description

![KnuMail](banner.png)

**KnuMail** makes the mailbox in **World of Warcraft: Forever** (1.60.1) faster and safer and keeps the default look. Everything it adds is on screen: buttons, checkboxes, tooltips and a right-click menu, so there are no hidden shortcuts to learn. English and Spanish.

### Features

- Open all, with filters. The Options button next to Open all picks which mail to open (auctions sold, won, expired, cancelled, outbid, and other mail), turns on gold only, and keeps 0, 2, 4 or 6 bag slots free. At the end you get one line in chat with the gold collected.
- Gold from strangers stays in the mailbox. Open all skips mail with gold from anyone who is not your alt, friend or guild member. If you open one of those on purpose, KnuMail asks first. Cash on delivery and GM mail are never opened by KnuMail.
- Checkboxes on every row. Tick the mails you want, then use Open selected or Return selected. Shift-click marks a range and Ctrl-click marks every mail from that sender on the page; the checkbox tooltip says so.
- Right-click a row to take its contents, return it to the sender, or mark all mail from that sender. When a mail can't be returned, the option is greyed out and says why (system mail, GM mail, already returned).
- Address book: a book icon next to "To:" lists your alts with full names, your last 20 recipients, friends and guild, and can remember the last recipient.
- With Send Mail open, Alt-click an item in your bags to attach it.
- Row tooltips list each attachment once, with gold and COD.
- `/knu mail` prints a short help in chat.

### Beta notes

This is the first beta. It was tested in game with auction mail. Two things haven't been checked in game yet: a stranger sending you gold, and opening mail with full bags. If you run into either, please open an issue.

### Notes

- Written from scratch for Forever. It contains no code from Postal or its ports.
- KnuMail never sends mail by itself. It only fills in fields for you.
- Source code and issues: https://github.com/knupson/KnuMail (MIT license).

---

## Descripción (castellano)

**KnuMail** hace que el buzón de **World of Warcraft: Forever** (1.60.1) sea más rápido y seguro, y conserva el aspecto de siempre. Todo lo que agrega está a la vista: botones, casillas, tooltips y un menú de clic derecho.

- Abrir todo con filtros: con el botón Opciones elegís qué tipos de correo abrir, si querés sólo el oro y cuántos espacios dejar libres en las bolsas. Al final ves una línea en el chat con lo cobrado.
- El oro de desconocidos queda en el buzón. Abrir todo lo saltea, y si lo abrís a propósito KnuMail te pregunta antes. Los contra reembolso y los de GM nunca los abre KnuMail.
- Casillas en cada fila para abrir o devolver sólo lo marcado.
- Clic derecho en una fila: tomar el contenido, devolverlo o marcar los de ese remitente.
- Libreta de destinatarios con tus alters, los últimos 20 destinatarios, amigos y hermandad.

Es la primera beta. Falta probar en el juego el oro de un desconocido y abrir correos con las bolsas llenas. Código propio, licencia MIT.

---

## Project settings

- Game version: **1.60.1** (Forever flavour)
- Category: Mail (secondary: Auction & Economy)
- License: MIT
- Avatar: `tools/preview/avatar.png` (400×400)
- Description image: `tools/preview/banner.png` (1200×400)
- Screenshots (to take before or after the first release):
  1. Inbox with checkboxes.
  2. Options menu.
  3. Right-click menu on a row.
  4. Address book.
