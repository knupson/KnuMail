local function mail(fields)
    local m = {sender = 'Extraño Apellido', money = 0, cod = 0, itemCount = 1, kind = 'other'}
    for k, v in pairs(fields or {}) do m[k] = v end; return m
end
local function decide(m, known, explicit) return ns.Rules.Decide(m, ns.db.settings.openAll, known, explicit) end
test('rules_cod_always_skipped', function() local a, r = decide(mail({cod = 100}), false, true); eq(a, 'skip'); eq(r, 'cod') end)
test('rules_gm_skipped', function() local a, r = decide(mail({isGM = true}), true, true); eq(a, 'skip'); eq(r, 'gm') end)
test('rules_stranger_gold_with_items_skips_all', function() local a,r = decide(mail({money = 5000, itemCount = 2}), false); eq(a,'skip'); eq(r,'strangerGold') end)
test('rules_stranger_items_only_taken', function() eq(decide(mail(), false), 'take') end)
test('rules_known_gold_taken', function() eq(decide(mail({money = 5000}), true), 'take') end)
test('identity_tiebreak_by_occurrence', function() local m = mail({subject = 'Test', daysLeft = 30}); ok(ns.Inbox.Identity(m,1) ~= ns.Inbox.Identity(m,2)) end)
test('rules_filter_off_skips_kind', function() ns.db.settings.openAll.ahExpired = false; local a,r = decide(mail({kind = 'ahExpired'}),false); eq(a,'skip'); eq(r,'filter') end)
test('rules_explicit_ignores_stranger_rule', function() ns.db.settings.openAll.other = false; eq(decide(mail({money = 5000}),false,true),'take') end)
test('rules_gold_only', function() ns.db.settings.openAll.goldOnly = true; eq(decide(mail({money = 1}),true),'gold'); local a,r = decide(mail(),true); eq(a,'skip'); eq(r,'empty') end)
test('classify_invoice_seller', function() eq(ns.Classify.Kind('test','seller'), 'ahSold'); eq(ns.Classify.Kind('test','buyer'), 'ahWon') end)
test('classify_expired_by_subject', function() eq(ns.Classify.Kind('Subasta terminada: Piedra'), 'ahExpired') end)
test('classify_unknown_subject_is_other', function() eq(ns.Classify.Kind('hola'), 'other') end)
test('rules_stranger_setting_cannot_override_safety', function() ns.db.settings.openAll.strangerGold = true; eq(decide(mail({money=1}),false),'skip') end)
test('inbox_reads_header_and_invoice', function()
    FAKE.inbox = {{sender='Subastas', subject='Venta', money=100, invoiceType='seller', isGM=true, daysLeft=29.42}}
    local m=ns.Inbox.Read(1); eq(m.money,100); eq(m.kind,'ahSold'); eq(m.isGM,true); eq(m.daysLeft,29.42)
end)
test('classify_escapes_localized_patterns', function()
    eq(ns.Classify.Kind('Vencida (rara): [Piedra]',nil,{ahExpired='Vencida (rara): %s'}),'ahExpired')
end)
