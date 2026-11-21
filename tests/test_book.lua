test('book_recent_max_20',function()
    for i=1,25 do ns.Book.AddRecent('Nombre Apellido'..i) end
    eq(#ns.db.recent,20); eq(ns.db.recent[1],'Nombre Apellido25')
end)
test('book_recent_dedupes_and_moves_to_top',function()
    ns.Book.AddRecent('Uno Apellido'); ns.Book.AddRecent('Dos Apellido'); ns.Book.AddRecent('UNO Apellido-Servidor')
    eq(#ns.db.recent,2); eq(ns.Names.Normalize(ns.db.recent[1]),'uno apellido')
end)
test('book_lists_exclude_me',function()
    ns.Names.RegisterAlt(); ns.db.alts['Zeta Apellido']={}; ns.db.alts['Alfa Apellido']={}
    local lists=ns.Book.Lists(); eq(#lists.alts,2); eq(lists.alts[1],'Alfa Apellido')
end)
test('book_send_success_and_remember',function()
    FAKE.Fire('MAIL_SHOW'); SendMailNameEditBox:SetText('Destino Apellido'); FAKE.Fire('MAIL_SEND_SUCCESS')
    eq(ns.db.recent[1],'Destino Apellido'); ns.db.settings.rememberLast=true; SendMailNameEditBox:SetText(''); SendMailFrame:Show()
    eq(SendMailNameEditBox:GetText(),'Destino Apellido')
end)
test('book_send_success_after_native_reset',function()
    FAKE.Fire('MAIL_SHOW'); SendMailNameEditBox:SetText('Destino Apellido'); SendMailNameEditBox:SetText(''); FAKE.Fire('MAIL_SEND_SUCCESS')
    eq(ns.db.recent[1],'Destino Apellido')
end)
test('book_long_lists_scroll_short_ones_do_not',function()
    for i=1,40 do FAKE.guild[i]='Miembro'..i..' Apellido' end
    FAKE.friends={}; FAKE.Fire('MAIL_SHOW'); SendMailFrame:Show()
    local button
    for _,frame in ipairs(FAKE.frames) do if frame.parent==SendMailFrame and frame.scripts.OnClick then button=frame end end
    button.scripts.OnClick(button)
    local byLabel={}
    for _,entry in ipairs(FAKE.menu.buttons) do byLabel[entry.label]=entry end
    eq(byLabel[ns.L['Guild']].scroll,360); eq(#byLabel[ns.L['Guild']].children,40)
    eq(byLabel[ns.L['Friends']].scroll,nil)
end)
