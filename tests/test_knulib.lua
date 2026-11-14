test('knulib_print_prefix', function()
    eq(ns.KL, LibStub('KnuLib-1.0'))
    ns.Print('Mensaje de prueba')
    local prefix = '|cffecd9bdKNU|r|cffffa82eMail|r: '
    eq(FAKE.messages[1]:sub(1, #prefix), prefix)
    eq(FAKE.messages[1], prefix .. 'Mensaje de prueba')
end)

test('knulib_styles_mail_controls', function()
    FAKE.Fire('MAIL_SHOW')
    local found = {}
    for _, frame in ipairs(FAKE.frames) do
        local text = frame:GetText()
        if frame:GetParent() == InboxFrame and
            (text == ns.L['Open all'] or text == '>' or
             text == ns.L['Open selected'] or text == ns.L['Return selected']) then
            ok(ns.KL.frames[frame] and ns.KL.frames[frame].StyleButton, text)
            ok(frame.backdrop, text)
            found[text] = (found[text] or 0) + 1
        end
    end
    for _, text in ipairs({ns.L['Open all'], '>', ns.L['Open selected'], ns.L['Return selected']}) do
        eq(found[text], 1, text)
    end
    for i = 1, INBOXITEMS_TO_DISPLAY do
        local box = _G['MailItem' .. i].KnuMailCheck
        ok(box and ns.KL.frames[box] and ns.KL.frames[box].StyleCheck, 'Fila ' .. i)
        ok(box.backdrop, 'Fondo de fila ' .. i)
        local accent = ns.KL:GetTheme().accent
        eq(box:GetCheckedTexture().vertex[1], accent.r)
        eq(box:GetCheckedTexture().vertex[2], accent.g)
        eq(box:GetCheckedTexture().vertex[3], accent.b)
    end
end)
