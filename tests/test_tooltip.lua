test('tooltip_merges_duplicate_links',function()
    FAKE.inbox={{sender='A B',items={{link='item:1',count=5},{link='item:1',count=3}},itemCount=2}}
    local lines=ns.Tooltip.Lines(1); eq(#lines,1); eq(lines[1].count,8); eq(lines[1].link,'item:1')
end)
test('tooltip_lists_money_and_cod',function()
    FAKE.inbox={{sender='A B',money=500,cod=200}}; local lines=ns.Tooltip.Lines(1); eq(lines.money,500); eq(lines.cod,200)
end)
test('express_shift_row_and_attachment_untouched',function()
    FAKE.inbox={{sender='Extraño Apellido',money=50}}; FAKE.Fire('MAIL_SHOW'); FAKE.shift=true
    MailItem1:GetScript('OnMouseUp')(MailItem1,'LeftButton'); FAKE.Advance(1); eq(#FAKE.calls,0)
    ok(FAKE.popups.KNUMAIL_STRANGER_GOLD); FAKE.RespondPopup(true); FAKE.Advance(1); eq(#FAKE.calls,1)
    eq(MailItem1Button:GetScript('OnClick'),FAKE.attachmentClick)
end)
test('express_ctrl_return_restrictions',function()
    FAKE.inbox={{sender='GM',isGM=true}}; FAKE.Fire('MAIL_SHOW'); FAKE.ctrl=true
    MailItem1:GetScript('OnMouseUp')(MailItem1,'LeftButton'); eq(#FAKE.returns,0)
    FAKE.inbox={{sender='A B'}}; MailItem1:GetScript('OnMouseUp')(MailItem1,'LeftButton'); eq(#FAKE.returns,1)
end)
test('express_alt_first_free_attachment',function()
    FAKE.Fire('MAIL_SHOW'); FAKE.alt=true; SendMailFrame:Show(); FAKE.sendItems[1]='Occupied'
    local item=CreateFrame('Button'); item.id=4; item.GetBagID=function() return 2 end
    item.OnModifiedClick=function() end
    EventRegistry:TriggerEvent('ContainerFrameItemButton.EnterButton',item)
    item:OnModifiedClick('LeftButton'); eq(FAKE.attached,2); eq(FAKE.pickup[1],2); eq(FAKE.pickup[2],4)
end)
test('tooltip_row_uses_lines_without_inbox_setter',function()
    FAKE.inbox={{sender='A B',items={{link='item:1',count=5}},itemCount=1}}; FAKE.Fire('MAIL_SHOW')
    local count=0; local old=GameTooltip.AddLine; GameTooltip.AddLine=function() count=count+1 end
    MailItem1:GetScript('OnEnter')(MailItem1); GameTooltip.AddLine=old; eq(count,1)
end)
