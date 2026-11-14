local function knownMail(subject, money, count)
    ns.db.alts['Alter Apellido'] = {}
    local m = {sender='Alter Apellido',subject=subject,money=money or 0,itemCount=count or 0,items={}}
    for i=1,count or 0 do m.items[i]={link='item:'..i,count=1} end
    return m
end
local function run(opts) ns.OpenAll.Start(opts); FAKE.Advance(10) end
test('openall_takes_known_mail',function()
    FAKE.inbox={knownMail('A',500,2)}; run(); eq(#FAKE.calls,3); eq(ns.OpenAll.Summary().gold,500); eq(ns.OpenAll.Summary().opened,1)
end)
test('openall_index_shift',function()
    FAKE.inbox={knownMail('A',1),knownMail('B',2),knownMail('C',3)}; run(); eq(#FAKE.inbox,0); eq(ns.OpenAll.Summary().opened,3)
end)
test('openall_skips_stranger_gold_and_counts_it',function()
    FAKE.inbox={{sender='Extraño Apellido',money=100,itemCount=1,items={{link='item:1'}}}}; run()
    eq(#FAKE.calls,0); eq(ns.OpenAll.Summary().skipped.strangerGold,1)
end)
test('openall_stops_on_full_bags',function()
    FAKE.inbox={knownMail('A',0,2)}; FAKE.inventoryError=true
    ns.OpenAll.Start(); FAKE.freeSlots=0; FAKE.Advance(10)
    eq(ns.OpenAll.IsRunning(),false); eq(#FAKE.calls,1)
end)
test('openall_keeps_free_slots',function()
    FAKE.inbox={knownMail('A',0,1)}; ns.db.settings.openAll.keepFree=2; FAKE.freeSlots=2; run(); eq(#FAKE.calls,0)
end)
test('openall_stops_on_mail_closed',function()
    FAKE.inbox={knownMail('A',10,2)}; ns.OpenAll.Start(); FAKE.Fire('MAIL_CLOSED'); FAKE.Advance(10)
    eq(ns.OpenAll.IsRunning(),false); eq(#FAKE.calls,1)
    for _, timer in ipairs(FAKE.timers) do ok(timer.cancelled) end
end)
test('openall_respects_min_delay',function()
    FAKE.inbox={knownMail('A',5,3)}; run()
    for i=2,#FAKE.calls do ok(FAKE.calls[i].time-FAKE.calls[i-1].time>=0.15-0.000001) end
end)
test('openall_only_selected',function()
    FAKE.inbox={knownMail('A',1),knownMail('B',2)}; local id=ns.Inbox.Snapshot()[2].id
    run({only={[id]=true}}); eq(#FAKE.calls,1); eq(ns.OpenAll.Summary().gold,2)
end)
test('openall_selected_duplicate_survives_identity_change',function()
    FAKE.inbox={knownMail('A',5,2),knownMail('A',5,2)}; local id=ns.Inbox.Snapshot()[2].id
    run({only={[id]=true}}); eq(#FAKE.calls,3); eq(#FAKE.inbox,1); eq(FAKE.inbox[1].money,5)
end)
test('openall_waits_for_pending_command',function()
    FAKE.inbox={knownMail('A',1)}; FAKE.pending=true; ns.OpenAll.Start(); FAKE.Advance(1); eq(#FAKE.calls,0)
    FAKE.pending=false; FAKE.Advance(1); eq(#FAKE.calls,1)
end)
test('openall_fetches_overflow',function()
    FAKE.inbox={knownMail('A',1)}; FAKE.total=2
    FAKE.onCheck=function() FAKE.inbox={knownMail('B',2)}; FAKE.total=1; FAKE.Fire('MAIL_INBOX_UPDATE') end
    run(); eq(FAKE.checks,1); eq(ns.OpenAll.Summary().gold,3)
end)
test('openall_gold_only_leaves_items',function()
    FAKE.inbox={knownMail('A',3,2)}; run({goldOnly=true}); eq(#FAKE.calls,1); eq(FAKE.inbox[1].itemCount,2)
end)
test('openall_failed_command_continues',function()
    FAKE.inbox={knownMail('A',0,2)}; FAKE.deferTicks=2
    FAKE.inbox[1].items[1].id=42; FAKE.inbox[1].items[1].fail=true
    run(); eq(#FAKE.calls,2); eq(ns.OpenAll.Summary().skipped.failed,1)
end)
test('openall_cancel_stops',function()
    FAKE.inbox={knownMail('A',0,2)}; ns.OpenAll.Start(); FAKE.Fire('MAIL_OPEN_ALL_CANCELED'); FAKE.Advance(10); eq(#FAKE.calls,1)
end)
test('openall_consumes_selection_without_selecting_duplicate',function()
    FAKE.inbox={knownMail('A',5),knownMail('A',5)}
    local id=ns.Inbox.Snapshot()[1].id; ns.Selection.Toggle(id)
    run({only=ns.Selection.Ids()}); eq(ns.Selection.Count(),0); eq(#FAKE.inbox,1)
end)
