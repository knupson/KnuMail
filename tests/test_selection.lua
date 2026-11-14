local function inbox()
    for i=1,14 do FAKE.inbox[i]={sender=i%2==0 and 'Par Apellido' or 'Impar Apellido',subject='Carta '..i} end
    return ns.Inbox.Snapshot()
end
test('selection_clears_on_page_change',function()
    local mails=inbox(); FAKE.Fire('MAIL_SHOW'); ns.Selection.Toggle(mails[1].id); InboxFrame.pageNum=2; InboxFrame:Update(); eq(ns.Selection.Count(),0)
end)
test('selection_does_not_leak_to_other_page',function()
    local mails=inbox(); ns.Selection.Toggle(mails[1].id); InboxFrame.pageNum=2; InboxFrame:Update(); eq(ns.Selection.IsSelected(mails[8].id),false)
end)
test('selection_identity_tiebreak',function()
    FAKE.inbox={{sender='Igual Apellido',subject='A'},{sender='Igual Apellido',subject='A'}}
    local m=ns.Inbox.Snapshot(); ns.Selection.Toggle(m[1].id); eq(ns.Selection.IsSelected(m[2].id),false)
end)
test('selection_range_within_page',function()
    local mails=inbox(); local ids={}; for i=1,7 do ids[i]=mails[i].id end
    ns.Selection.Range(ids,ids[2],ids[5]); eq(ns.Selection.Count(),4)
    ns.Selection.Range(ids,ids[2],mails[10].id); eq(ns.Selection.Count(),4)
end)
test('selection_by_sender_whole_inbox',function()
    local mails=inbox(); ns.Selection.BySender('PAR Apellido',mails); eq(ns.Selection.Count(),7)
end)
test('selection_ui_absolute_number_and_close',function()
    inbox(); FAKE.Fire('MAIL_SHOW'); InboxFrame.pageNum=2; InboxFrame:Update()
    eq(MailItem1.KnuMailNumber:GetText(),'8'); MailItem1.KnuMailCheck:GetScript('OnClick')(MailItem1.KnuMailCheck)
    eq(ns.Selection.Count(),1); FAKE.Fire('MAIL_CLOSED'); eq(ns.Selection.Count(),0)
end)
test('selection_return_restrictions',function()
    FAKE.inbox={{sender='A B',subject='Ok'}, {sender='Subastas',invoiceType='seller'}, {sender='GM',isGM=true}, {sender='A B',canDelete=true}}
    for _,m in ipairs(ns.Inbox.Snapshot()) do ns.Selection.Toggle(m.id) end
    ns.Selection.ReturnSelected(); eq(#FAKE.returns,1); eq(FAKE.returns[1],1)
end)
test('selection_return_serializes_commands',function()
    inbox(); local mails=ns.Inbox.Snapshot()
    ns.db.alts['Impar Apellido']={}; ns.db.alts['Par Apellido']={}
    for _,mail in ipairs(FAKE.inbox) do mail.money=1 end
    mails=ns.Inbox.Snapshot()
    ns.Selection.Toggle(mails[1].id); ns.Selection.Toggle(mails[2].id); ns.Selection.ReturnSelected()
    eq(#FAKE.returns,1); ns.OpenAll.Start(); eq(ns.OpenAll.IsRunning(),false)
    FAKE.Advance(1); eq(#FAKE.returns,2); eq(ns.Selection.Count(),0)
end)
