local function stranger(subject, money)
    return {sender='Desconocido Apellido', subject=subject or 'Carta', money=money or 50,
        itemCount=1, items={{id=7}}}
end
local function selectAll()
    local ids={}
    for _,mail in ipairs(ns.Inbox.Snapshot()) do ids[mail.id]=true end
    return {only=ids}
end

test('stranger_gold_open_all_never_touches_mail',function()
    FAKE.inbox={stranger()}; ns.db.settings.openAll.strangerGold=true
    ns.OpenAll.Start(); FAKE.Advance(10)
    eq(#FAKE.calls,0); eq(FAKE.checks,0); eq(ns.OpenAll.Summary().skipped.strangerGold,1)
end)

test('stranger_gold_selected_waits_then_accepts_each_mail',function()
    FAKE.inbox={stranger('A',100),stranger('B',200)}
    ns.OpenAll.Start(selectAll()); FAKE.Advance(10)
    eq(#FAKE.calls,0); eq(FAKE.checks,0); ok(ns.OpenAll.IsRunning()); eq(FAKE.popupShows,1)
    eq(FAKE.popups.KNUMAIL_STRANGER_GOLD.text,string.format(ns.L['Take %s from %s?'],'100','Desconocido Apellido'))
    FAKE.Fire('MAIL_FAILED'); FAKE.Advance(1); eq(#FAKE.calls,0)
    FAKE.RespondPopup(true); FAKE.Advance(10)
    eq(#FAKE.calls,2); eq(FAKE.popupShows,2); ok(ns.OpenAll.IsRunning())
    FAKE.RespondPopup(true); FAKE.Advance(10)
    eq(#FAKE.calls,4); eq(ns.OpenAll.Summary().gold,300); eq(ns.OpenAll.Summary().opened,2)
    eq(ns.OpenAll.IsRunning(),false)
end)

test('stranger_gold_cancel_and_escape_skip_whole_mail_and_continue',function()
    for _,reason in ipairs({'clicked','escape'}) do
        local calls=#FAKE.calls
        FAKE.inbox={stranger('A'),stranger('B')}
        ns.OpenAll.Start(selectAll()); FAKE.RespondPopup(false,reason); FAKE.Advance(1)
        eq(#FAKE.calls,calls); eq(ns.OpenAll.Summary().skipped.strangerGold,1)
        FAKE.RespondPopup(true); FAKE.Advance(10)
        eq(#FAKE.calls,calls+2); eq(#FAKE.inbox,1); eq(FAKE.inbox[1].subject,'A')
    end
end)

test('stranger_gold_close_hides_popup_and_ignores_stale_accept',function()
    FAKE.inbox={stranger()}; ns.OpenAll.Start(selectAll())
    local popup=assert(FAKE.popups.KNUMAIL_STRANGER_GOLD)
    FAKE.Fire('MAIL_CLOSED'); eq(FAKE.popups.KNUMAIL_STRANGER_GOLD,nil)
    StaticPopupDialogs.KNUMAIL_STRANGER_GOLD.OnAccept(popup,popup.data)
    FAKE.Advance(10); eq(#FAKE.calls,0); eq(ns.OpenAll.IsRunning(),false); eq(FAKE.opening,false)
end)

test('stranger_gold_popup_settings_and_locales',function()
    local dialog=assert(StaticPopupDialogs.KNUMAIL_STRANGER_GOLD)
    eq(dialog.timeout,0); eq(dialog.whileDead,true); eq(dialog.hideOnEscape,true)
    for _,locale in ipairs({'enUS','esES'}) do
        local old=FAKE.locale; FAKE.locale=locale; local localized={}
        assert(loadfile('Locales/Locales.lua'))('KnuMail',localized); FAKE.locale=old
        local expected=locale=='enUS' and 'Take %s from %s?' or '¿Cobrar %s de %s?'
        eq(localized.L['Take %s from %s?'],expected)
    end
end)

test('stranger_gold_popup_uses_coin_textures',function()
    local old=GetCoinTextureString; GetCoinTextureString=function(amount) return 'monedas:'..amount end
    FAKE.inbox={stranger()}; ns.OpenAll.Start(selectAll()); GetCoinTextureString=old
    eq(FAKE.popups.KNUMAIL_STRANGER_GOLD.text,string.format(ns.L['Take %s from %s?'],'monedas:50','Desconocido Apellido'))
end)

test('stranger_gold_known_and_system_auction_need_no_popup',function()
    ns.db.alts['Alter Apellido']={}; FAKE.friends={{name='Amigo Apellido'}}; FAKE.guild={'Guild Apellido'}
    FAKE.inbox={stranger('Alt'),stranger('Friend'),stranger('Guild'),stranger('Auction')}
    FAKE.inbox[1].sender='Alter Apellido'; FAKE.inbox[2].sender='Amigo Apellido'; FAKE.inbox[3].sender='Guild Apellido'
    FAKE.inbox[4].invoiceType='seller'
    ns.OpenAll.Start(selectAll()); FAKE.Advance(10); eq(FAKE.popupShows,0); eq(#FAKE.calls,8)
end)

test('stranger_gold_checkbox_open_selected_prompts',function()
    FAKE.inbox={stranger()}; FAKE.Fire('MAIL_SHOW')
    MailItem1.KnuMailCheck:GetScript('OnClick')(MailItem1.KnuMailCheck)
    for _,frame in ipairs(FAKE.frames) do
        if frame:GetText()==ns.L['Open selected'] then frame:GetScript('OnClick')(); break end
    end
    eq(#FAKE.calls,0); ok(FAKE.popups.KNUMAIL_STRANGER_GOLD)
    FAKE.RespondPopup(true); FAKE.Advance(10); eq(#FAKE.calls,2)
end)

test('stranger_gold_cod_gm_skipped_in_all_paths',function()
    for _,explicit in ipairs({false,true}) do
        FAKE.inbox={stranger('COD'),stranger('GM')}
        FAKE.inbox[1].cod=100; FAKE.inbox[2].isGM=true
        ns.OpenAll.Start(explicit and selectAll() or nil); FAKE.Advance(10)
        eq(#FAKE.calls,0); eq(ns.OpenAll.Summary().skipped.cod,1); eq(ns.OpenAll.Summary().skipped.gm,1)
    end
end)

test('stranger_gold_native_icon_warns_once_without_blocking',function()
    FAKE.inbox={stranger()}; FAKE.Fire('MAIL_SHOW'); FAKE.shift=true
    InboxFrame_OnModifiedClick(MailItem1Button,1)
    eq(#FAKE.calls,1); eq(#FAKE.messages,1); eq(FAKE.popupShows,0)
    eq(FAKE.messages[1],'|cffecd9bdKNU|r|cffffa82eMail|r: '..string.format(ns.L['you took gold from a stranger (%s).'],'Desconocido Apellido'))
    FAKE.Advance(1); eq(FAKE.inbox[1].money,0); eq(#FAKE.messages,1)
end)

test('stranger_gold_native_icon_uses_absolute_mail_index',function()
    for i=1,8 do FAKE.inbox[i]=stranger(tostring(i)) end
    FAKE.inbox[8].sender='Otro Desconocido'; InboxFrame.pageNum=2
    InboxFrame_OnModifiedClick(MailItem1Button,8)
    eq(#FAKE.calls,1); eq(FAKE.calls[1].index,8)
    eq(#FAKE.messages,1)
    eq(FAKE.messages[1],'|cffecd9bdKNU|r|cffffa82eMail|r: '..string.format(ns.L['you took gold from a stranger (%s).'],'Otro Desconocido'))
end)

test('stranger_gold_native_icon_no_warning_for_safe_mail_or_cod',function()
    ns.db.alts['Alter Apellido']={}
    FAKE.inbox={stranger('Alt'),stranger('AH'),stranger('COD'),stranger('Items')}
    FAKE.inbox[1].sender='Alter Apellido'; FAKE.inbox[2].invoiceType='seller'
    FAKE.inbox[3].cod=1; FAKE.inbox[4].money=0
    for i=1,4 do InboxFrame_OnModifiedClick(MailItem1Button,i) end
    eq(#FAKE.calls,3); eq(#FAKE.messages,0); eq(FAKE.popupShows,0)
end)

test('stranger_gold_warning_locales',function()
    for _,locale in ipairs({'enUS','esES'}) do
        local old=FAKE.locale; FAKE.locale=locale; local localized={}
        assert(loadfile('Locales/Locales.lua'))('KnuMail',localized); FAKE.locale=old
        local expected=locale=='enUS' and 'you took gold from a stranger (%s).'
            or 'cobraste oro de un desconocido (%s).'
        eq(localized.L['you took gold from a stranger (%s).'],expected)
    end
end)

test('stranger_gold_cancel_continues_to_known_mail',function()
    FAKE.inbox={stranger('Unknown'),stranger('Known')}
    FAKE.inbox[2].sender='Alter Apellido'; ns.db.alts['Alter Apellido']={}
    ns.OpenAll.Start(selectAll()); FAKE.RespondPopup(false); FAKE.Advance(10)
    eq(#FAKE.calls,2); eq(ns.OpenAll.Summary().skipped.strangerGold,1)
    eq(ns.OpenAll.Summary().gold,50); eq(ns.OpenAll.IsRunning(),false)
end)

test('stranger_gold_gold_only_prompts_and_leaves_items',function()
    FAKE.inbox={stranger()}; local opts=selectAll(); opts.goldOnly=true
    ns.OpenAll.Start(opts); eq(#FAKE.calls,0); FAKE.RespondPopup(true); FAKE.Advance(10)
    eq(#FAKE.calls,1); eq(FAKE.inbox[1].itemCount,1); eq(ns.OpenAll.Summary().gold,50)
end)

test('stranger_gold_accept_revalidates_changed_inbox',function()
    FAKE.inbox={stranger()}; ns.OpenAll.Start(selectAll())
    FAKE.inbox={stranger('Replacement',999)}; FAKE.Fire('MAIL_INBOX_UPDATE')
    FAKE.RespondPopup(true); FAKE.Advance(10)
    eq(#FAKE.calls,0); eq(ns.OpenAll.IsRunning(),false)
end)

test('stranger_gold_accept_does_not_override_new_gm_flag',function()
    FAKE.inbox={stranger()}; ns.OpenAll.Start(selectAll()); FAKE.inbox[1].isGM=true
    FAKE.RespondPopup(true); FAKE.Advance(10)
    eq(#FAKE.calls,0); eq(ns.OpenAll.Summary().skipped.gm,1)
end)

test('stranger_gold_duplicate_mail_needs_separate_confirmation',function()
    FAKE.inbox={stranger(),stranger()}; ns.OpenAll.Start(selectAll())
    FAKE.RespondPopup(true); FAKE.Advance(10)
    eq(#FAKE.calls,2); eq(FAKE.popupShows,2)
    FAKE.RespondPopup(false); FAKE.Advance(10)
    eq(#FAKE.calls,2); eq(ns.OpenAll.Summary().skipped.strangerGold,1); eq(#FAKE.inbox,1)
end)
