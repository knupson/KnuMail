local function mail(subject, money, items)
    ns.db.alts['Alter Apellido'] = {}
    return {sender='Alter Apellido', subject=subject, money=money or 0, items=items or {}, itemCount=#(items or {})}
end
local function run(opts) ns.OpenAll.Start(opts); FAKE.Advance(10) end
local function click(row) row.KnuMailCheck:GetScript('OnClick')(row.KnuMailCheck) end
local function pages()
    for i=1,14 do FAKE.inbox[i]=mail('Carta '..i,1) end
    FAKE.Fire('MAIL_SHOW'); InboxFrame:Update()
    return ns.Inbox.Snapshot()
end
test('spoofed_auction_gold_is_strangerGold',function()
    FAKE.inbox={{sender='Extraño', subject=string.format(AUCTION_WON_MAIL_SUBJECT,'Piedra'), canReply=true, money=100}}
    local m=ns.Inbox.Read(1); eq(m.kind,'other')
    local a,r=ns.Rules.Decide(m,ns.db.settings.openAll,false); eq(a,'skip'); eq(r,'strangerGold')
    run(); eq(#FAKE.calls,0); eq(ns.OpenAll.Summary().skipped.strangerGold,1)
end)
test('trusted_auction_requires_system_or_invoice',function()
    FAKE.inbox={{sender='Subastas',subject=string.format(AUCTION_WON_MAIL_SUBJECT,'Piedra'),canReply=false,money=2},
        {sender='Subastas',invoiceType='seller',canReply=true,money=3}}
    run(); eq(ns.OpenAll.Summary().gold,5)
    local a,r=ns.Rules.Decide({kind='ahWon',money=2},ns.db.settings.openAll,false); eq(a,'skip'); eq(r,'strangerGold')
end)
test('explicit_stranger_gold_requires_acceptance',function()
    FAKE.inbox={{sender='Extraño',subject=string.format(AUCTION_WON_MAIL_SUBJECT,'Piedra'),canReply=true,money=100}}
    run({only={[ns.Inbox.Snapshot()[1].id]=true}}); eq(ns.OpenAll.Summary().gold,0)
    FAKE.RespondPopup(true); FAKE.Advance(10); eq(ns.OpenAll.Summary().gold,100)
end)
test('page_change_clears_selection_and_anchor',function()
    pages(); click(MailItem1); InboxFrame.pageNum=2; InboxFrame:Update(); eq(ns.Selection.Count(),0)
    FAKE.shift=true; click(MailItem3); eq(ns.Selection.Count(),1)
end)
test('ctrl_sender_selects_visible_page',function()
    pages(); FAKE.ctrl=true; click(MailItem1); eq(ns.Selection.Count(),7)
end)
test('open_selected_limits_initial_visible_page',function()
    local m=pages(); ns.Selection.Toggle(m[1].id); ns.Selection.Toggle(m[8].id)
    for _,f in ipairs(FAKE.frames) do if f:GetText()==ns.L['Open selected'] then f:GetScript('OnClick')(); break end end
    FAKE.Advance(5); eq(#FAKE.calls,1); eq(FAKE.calls[1].index,1)
end)
test('return_selected_limits_initial_visible_page',function()
    local m=pages(); ns.Selection.Toggle(m[1].id); ns.Selection.Toggle(m[8].id)
    ns.Selection.ReturnSelected(); FAKE.Advance(5); eq(#FAKE.returns,1)
end)
test('snapshot_preserves_unknown_sender_and_real_rows',function()
    FAKE.inbox={mail('Primero',0),mail('Segundo',9)}; FAKE.inbox[1].sender=nil
    local m=ns.Inbox.Snapshot(); eq(m[1].sender,UNKNOWN); eq(m[2].index,2)
    FAKE.Fire('MAIL_SHOW'); InboxFrame:Update(); eq(MailItem2.KnuMailCheck.mail.index,2)
    FAKE.shift=true; MailItem2:GetScript('OnMouseUp')(MailItem2,'LeftButton'); FAKE.Advance(1); eq(FAKE.calls[1].index,2)
end)
test('mail_failed_skips_slot_and_itemID_then_continues',function()
    FAKE.inbox={mail('A',0,{{id=42,fail=true},{id=7}}),mail('B',0,{{id=42},{id=8}})}
    run(); eq(#FAKE.calls,3); eq(ns.OpenAll.Summary().skipped.failed,2); eq(ns.OpenAll.Summary().opened,2)
    eq(FAKE.calls[2].slot,2); eq(FAKE.calls[3].slot,2); eq(ns.OpenAll.IsRunning(),false)
end)
test('mail_failed_without_itemID_skips_only_failed_slot',function()
    FAKE.deferTicks=2
    FAKE.inbox={mail('A',0,{{fail=true},{id=9}}),mail('B',4)}
    run(); eq(#FAKE.calls,3); eq(ns.OpenAll.Summary().skipped.failed,1)
    eq(ns.OpenAll.Summary().gold,4); eq(ns.OpenAll.IsRunning(),false)
end)
test('return_selected_cancels_on_page_change',function()
    local m=pages(); ns.Selection.Toggle(m[1].id); ns.Selection.Toggle(m[2].id)
    ns.Selection.ReturnSelected(); eq(#FAKE.returns,1)
    InboxFrame.pageNum=2; InboxFrame:Update(); FAKE.Advance(1)
    eq(#FAKE.returns,1); eq(ns.Selection.Count(),0); eq(ns.Selection.IsReturning(),false)
end)
test('selected_cod_and_gm_never_issue_commands',function()
    FAKE.inbox={mail('COD',5,{{id=1}}),mail('GM',5,{{id=2}})}
    FAKE.inbox[1].cod=1; FAKE.inbox[2].isGM=true
    local selected={}; for _,m in ipairs(ns.Inbox.Snapshot()) do selected[m.id]=true end
    run({only=selected}); eq(#FAKE.calls,0); eq(ns.OpenAll.Summary().skipped.cod,1); eq(ns.OpenAll.Summary().skipped.gm,1)
end)
test('identity_ignores_days_and_includes_itemCount',function()
    local a=mail('A',1,{{}}); local id=ns.Inbox.Identity(a,1); a.daysLeft=29.5; eq(ns.Inbox.Identity(a,1),id)
    a.itemCount=2; ok(ns.Inbox.Identity(a,1)~=id)
end)
test('refresh_prunes_missing_selected_ids',function()
    local m=pages(); ns.Selection.Toggle(m[1].id); ns.Selection.Toggle(m[2].id)
    table.remove(FAKE.inbox,1); InboxFrame:Update(); eq(ns.Selection.Count(),1); ok(ns.Selection.IsSelected(m[2].id))
end)
test('native_autocomplete_left_alone',function()
    -- Forever's own AutoCompleteEditBoxTemplate handles "To:" (MailFrame.xml:593); KnuMail must not rewrite the text.
    FAKE.Fire('MAIL_SHOW'); ns.db.alts['Alfa Apellido']={}
    local e=SendMailNameEditBox
    e.text='Al'; e:GetScript('OnTextChanged')(e,true); eq(e:GetText(),'Al')
end)
test('uncached_attachment_uses_HasInboxItem',function()
    FAKE.inbox={mail('A',0,{{id=4,uncached=true,link='item:4',count=3}})}
    local old=GetInboxItemLink; GetInboxItemLink=function(i,s) return old(i,s) or 'stale' end
    local lines=ns.Tooltip.Lines(1); GetInboxItemLink=old; eq(#lines,1); eq(lines[1].count,3)
    run(); eq(#FAKE.calls,1); eq(#FAKE.inbox,0)
end)
test('nil_header_itemCount_is_zero',function()
    FAKE.inbox={mail('A',0,{{}})}; FAKE.inbox[1].nilItemCount=true; FAKE.inbox[1].itemCount=nil
    eq(ns.Inbox.Read(1).itemCount,0); run(); eq(#FAKE.calls,0)
end)
test('checkinbox_fetches_every_batch_and_respects_cooldown',function()
    FAKE.inbox={mail('A',1)}; FAKE.total=3; FAKE.canCheck=false; FAKE.checkSeconds=1
    FAKE.onCheck=function()
        FAKE.inbox={mail('Nueva '..FAKE.checks,2)}; FAKE.Fire('MAIL_INBOX_UPDATE')
    end
    ns.OpenAll.Start(); FAKE.Advance(0.5); eq(FAKE.checks,0)
    FAKE.canCheck=true; FAKE.Advance(10); eq(FAKE.checks,2); eq(ns.OpenAll.Summary().gold,5); eq(ns.OpenAll.IsRunning(),false)
end)
test('stub_total_decreases_when_mail_is_removed',function()
    FAKE.inbox={mail('A',1)}; FAKE.total=3; TakeInboxMoney(1)
    local shown,total=GetInboxNumItems(); eq(shown,0); eq(total,2)
end)
test('free_slots_excludes_special_bags',function()
    FAKE.inbox={mail('A',0,{{}})}; FAKE.freeSlots=0; FAKE.specialFree=20; run(); eq(#FAKE.calls,0)
end)
test('free_slots_fallback_excludes_special_bags',function()
    FAKE.inbox={mail('A',0,{{}})}; FAKE.freeSlots=0; FAKE.specialFree=20
    local old=C_Container.CalculateTotalNumberOfFreeBagSlots; C_Container.CalculateTotalNumberOfFreeBagSlots=nil
    run(); C_Container.CalculateTotalNumberOfFreeBagSlots=old; eq(#FAKE.calls,0)
end)
test('summary_english_reason_texts',function()
    local old=FAKE.locale; FAKE.locale='enUS'; local en={}; assert(loadfile('Locales.lua'))('KnuMail',en); FAKE.locale=old
    for _,key in ipairs({'cod','gm','strangerGold','filter','empty','failed'}) do ok(en.L[key]~=key,key) end
end)
test('opened_retained_mail_is_not_skipped_empty',function()
    FAKE.inbox={mail('A',5)}; FAKE.inbox[1].keep=true; run()
    eq(ns.OpenAll.Summary().opened,1); eq(ns.OpenAll.Summary().skipped.empty,nil)
end)
test('openall_waits_for_deferred_money_and_items',function()
    FAKE.deferTicks=4; FAKE.inbox={mail('A',5,{{id=1},{id=2}})}
    ns.OpenAll.Start(); FAKE.Advance(0.45); eq(#FAKE.calls,1); eq(FAKE.inbox[1].money,5); ok(C_Mail.IsCommandPending())
    FAKE.Advance(5); eq(#FAKE.calls,3); eq(ns.OpenAll.Summary().gold,5); eq(ns.OpenAll.Summary().opened,1); eq(#FAKE.inbox,0)
end)
