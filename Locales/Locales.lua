local _, ns = ...
ns.L = LibStub('KnuLib-1.0'):NewLocale({
    ['Open all'] = 'Abrir todo', ['Open selected'] = 'Abrir marcados', ['Return selected'] = 'Devolver marcados',
    ['Auction sold'] = 'Ventas de subasta', ['Auction won'] = 'Subastas ganadas', ['Auction expired'] = 'Subastas vencidas',
    ['Auction cancelled'] = 'Subastas canceladas', ['Auction outbid'] = 'Pujas superadas', ['Other mail'] = 'Otros correos',
    ['Take gold from strangers'] = 'Cobrar oro de desconocidos', ['Keep %d bag slots free'] = 'Reservar %d espacios en las bolsas',
    ['Gold only'] = 'Sólo oro', ['Remember last recipient'] = 'Recordar último destinatario',
    ['Address book'] = 'Libreta', ['Alts'] = 'Alters', ['Recent'] = 'Recientes', ['Friends'] = 'Amigos', ['Guild'] = 'Hermandad',
    ['Gold'] = 'Oro', ['COD'] = 'Contra reembolso', ['cod'] = 'contra reembolso', ['gm'] = 'GM',
    ['strangerGold'] = 'desconocidos con oro', ['filter'] = 'filtro', ['empty'] = 'sin contenido', ['failed'] = 'adjuntos fallidos',
    ['Bags full'] = 'Bolsas llenas', ['Mail failed'] = 'Falló la operación de correo', ['Stopped'] = 'Detenido',
    ['Collected %s; opened %d mail(s).'] = 'Cobraste %s; abriste %d correo(s).',
    ['Skipped %d: %s.'] = 'Se saltearon %d: %s.',
    ['Not opened: %s.'] = 'No se abrió: %s.',
    ['This mail cannot be returned.'] = 'Ese correo no se puede devolver.',
    ['Take %s from %s?'] = '¿Cobrar %s de %s?',
    ['you took gold from a stranger (%s).'] = 'cobraste oro de un desconocido (%s).',
}, {cod='cash on delivery', gm='game master mail', strangerGold='gold from strangers',
    filter='filtered mail', empty='empty mail', failed='failed attachments'})
