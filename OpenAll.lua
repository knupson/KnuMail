local _, ns = ...
local OpenAll = {}; ns.OpenAll = OpenAll
local running, timer, records, pending, settings, only, checkDeadline, failedIDs, confirmation
local summary = {gold = 0, opened = 0, skipped = {}}
local tick
local function schedule(delay)
    if running and not timer then timer = C_Timer.NewTimer(delay or 0.15, function() timer = nil; if running then tick() end end) end
end
function OpenAll.IsRunning() return running == true end
function OpenAll.Summary() return summary end
function OpenAll.Stop(reason)
    if timer then timer:Cancel(); timer = nil end
    confirmation = nil
    StaticPopup_Hide('KNUMAIL_STRANGER_GOLD')
    if not running then return end
    running = false; pending = nil; C_Mail.SetOpeningAll(false)
    if reason then ns.Print(reason) end
    -- A single-mail open (Shift-click on a row) reports one line, and only when there is news.
    if only then
        for _, key in ipairs({'cod', 'gm', 'strangerGold', 'filter', 'empty', 'failed'}) do
            if summary.skipped[key] then ns.Print(string.format(ns.L['Not opened: %s.'], ns.L[key])) end
        end
        return
    end
    ns.Print(string.format(ns.L['Collected %s; opened %d mail(s).'], GetMoneyString(summary.gold), summary.opened))
    for _, key in ipairs({'cod', 'gm', 'strangerGold', 'filter', 'empty', 'failed'}) do
        if summary.skipped[key] then ns.Print(string.format(ns.L['Skipped %d: %s.'], summary.skipped[key], ns.L[key])) end
    end
end
local function respondToStranger(_, data, accepted)
    if not running or not confirmation or confirmation ~= data then return end
    confirmation = nil
    if accepted then data.record.confirmedMoney = data.money
    else
        data.record.done = true
        summary.skipped.strangerGold = (summary.skipped.strangerGold or 0) + 1
    end
    schedule()
end
StaticPopupDialogs['KNUMAIL_STRANGER_GOLD'] = {
    text = ns.L['Take %s from %s?'], button1 = ACCEPT, button2 = CANCEL,
    timeout = 0, whileDead = true, hideOnEscape = true,
    OnAccept = function(self, data) respondToStranger(self, data, true) end,
    OnCancel = function(self, data) respondToStranger(self, data, false) end,
}
-- Runtime records carry the original identity through money/item changes and index shifts.
-- Every action still uses a freshly read index, never a saved inbox position.
local function signature(m)
    return ns.Inbox.Identity(m, 0)
end
local function failedSlot(record, slot)
    record.failedSlots=record.failedSlots or {}
    if not record.failedSlots[slot] then
        record.failedSlots[slot]=true
        summary.skipped.failed=(summary.skipped.failed or 0)+1
    end
end
local function failPending(itemID)
    if not pending then return end
    local p=pending
    if p.slot then
        if itemID then failedIDs[itemID]=true end
        failedSlot(p.record,p.slot)
    else
        p.record.done=true
        summary.skipped.failed=(summary.skipped.failed or 0)+1
    end
    pending=nil
end
local function freeSlots()
    if C_Container.CalculateTotalNumberOfFreeBagSlots then return C_Container.CalculateTotalNumberOfFreeBagSlots() end
    local free=0
    for bag=0,4 do
        local count, family=C_Container.GetContainerNumFreeSlots(bag)
        if family==0 then free=free+(count or 0) end
    end
    return free
end
local function refresh(fresh)
    if pending then
        local p, changed = pending, false
        for _, m in ipairs(fresh) do
            if signature(m) == p.before then changed = true; break end
        end
        -- A successful action must change the observed multiset, even with duplicates.
        local oldCount, newCount = 0, 0
        for _, r in ipairs(records) do if signature(r.mail) == p.before then oldCount = oldCount + 1 end end
        for _, m in ipairs(fresh) do if signature(m) == p.before then newCount = newCount + 1 end end
        if changed and oldCount == newCount then
            failPending()
        else
            local m = p.record.mail
            if p.money then m.money = 0 else m.itemCount = math.max(0, m.itemCount - 1) end
            if m.money == 0 and m.itemCount == 0 and #fresh < #records then p.record.removed = true end
            if not p.record.opened then p.record.opened = true; summary.opened = summary.opened + 1 end
            if ns.Selection then ns.Selection.Remove(p.record.id) end
            summary.gold = summary.gold + (p.money or 0)
            if p.goldOnly then p.record.done = true end
            pending = nil
        end
    end
    local buckets = {}
    for _, r in ipairs(records) do
        if not r.removed then
            local key = signature(r.mail); buckets[key] = buckets[key] or {}; table.insert(buckets[key], r)
        end
    end
    local updated = {}
    for _, mail in ipairs(fresh) do
        local bucket = buckets[signature(mail)]
        local record = bucket and table.remove(bucket, 1) or {id = mail.id}
        record.mail = mail; updated[#updated + 1] = record
    end
    records = updated; return true
end
tick = function()
    if confirmation then return end
    if C_Mail.IsCommandPending() then schedule(); return end
    local fresh = ns.Inbox.Snapshot()
    if not refresh(fresh) then return end
    for _, record in ipairs(records) do
        local mail = record.mail
        if not record.done then
            if only and not only[record.id] then record.done = true
            else
                local known = ns.Names.IsKnown(mail.sender)
                local action, reason = ns.Rules.Decide(mail, settings, known, only ~= nil)
                if action == 'skip' then
                    record.done = true
                    if not (record.opened and reason == 'empty') then summary.skipped[reason] = (summary.skipped[reason] or 0) + 1 end
                else
                    if only and ns.Rules.IsStrangerGold(mail, known) and record.confirmedMoney ~= mail.money then
                        confirmation = {record = record, money = mail.money}
                        StaticPopup_Show('KNUMAIL_STRANGER_GOLD', GetCoinTextureString(mail.money), mail.sender, confirmation)
                        return
                    end
                    local slot
                    if mail.money == 0 then
                        local free = freeSlots()
                        if free <= settings.keepFree then OpenAll.Stop(ns.L['Bags full']); return end
                        for i = 1, ATTACHMENTS_MAX_RECEIVE do
                            if HasInboxItem(mail.index, i) then
                                local _, itemID = GetInboxItem(mail.index, i)
                                if itemID and failedIDs[itemID] then failedSlot(record,i) end
                                if not (record.failedSlots and record.failedSlots[i]) then slot = i; break end
                            end
                        end
                        if not slot then record.done=true end
                    end
                    if not record.done then
                        pending = {record = record, slot = slot, before = signature(mail), money = mail.money > 0 and mail.money or nil, goldOnly = action == 'gold'}
                        if mail.money > 0 then TakeInboxMoney(mail.index) else TakeInboxItem(mail.index, slot) end
                        schedule(); return
                    end
                end
            end
        end
    end
    local shown, total = GetInboxNumItems()
    if not only and total > shown then
        if checkDeadline and GetTime() < checkDeadline then schedule(); return end
        local canCheck, seconds = C_Mail.CanCheckInbox()
        if canCheck then
            checkDeadline = GetTime() + 5; CheckInbox(); schedule(); return
        end
        schedule(math.max(0.15, seconds or 0)); return
    end
    OpenAll.Stop()
end
function OpenAll.Start(opts)
    if ns.Selection and ns.Selection.IsReturning() then return end
    if running then OpenAll.Stop(ns.L['Stopped']); return end
    opts = opts or {}; settings = {}
    for k,v in pairs(ns.db.settings.openAll) do settings[k] = v end
    if opts.goldOnly ~= nil then settings.goldOnly = opts.goldOnly end
    only = opts.only; records = {}; pending = nil; failedIDs = {}; checkDeadline = nil
    summary = {gold = 0, opened = 0, skipped = {}}; running = true
    C_Mail.SetOpeningAll(true); tick()
end
ns.On('MAIL_CLOSED', function() OpenAll.Stop() end)
ns.On('MAIL_OPEN_ALL_CANCELED', function() OpenAll.Stop(ns.L['Stopped']) end)
ns.On('MAIL_FAILED', function(itemID) if running then failPending(itemID); schedule() end end)
ns.On('UI_ERROR_MESSAGE', function(code, text)
    if text == ERR_INV_FULL or code == ERR_INV_FULL then OpenAll.Stop(ns.L['Bags full']) end
end)
ns.On('MAIL_INBOX_UPDATE', function() if running then checkDeadline = nil end end)

local initialized
ns.On('MAIL_SHOW', function()
    if initialized then return end
    initialized = true
    InboxFrame.OpenAllMail:Hide()
    local button = CreateFrame('Button', nil, InboxFrame, 'UIPanelButtonTemplate')
    button:SetSize(115, 22); button:SetPoint('BOTTOM', InboxFrame, 'BOTTOM', -13, 15); button:SetText(ns.L['Open all'])
    ns.KL:StyleButton(button)
    button:SetScript('OnClick', function() OpenAll.Start(IsAltKeyDown() and {goldOnly = true} or nil) end)
    local arrow = CreateFrame('Button', nil, InboxFrame, 'UIPanelButtonTemplate')
    arrow:SetSize(24, 22); arrow:SetPoint('LEFT', button, 'RIGHT', 2, 0); arrow:SetText('>')
    ns.KL:StyleButton(arrow)
    arrow:SetScript('OnClick', function(self)
        MenuUtil.CreateContextMenu(self, function(_, root)
            root:CreateTitle('KnuMail')
            local s = ns.db.settings.openAll
            for _, entry in ipairs({{'ahSold','Auction sold'}, {'ahWon','Auction won'}, {'ahExpired','Auction expired'},
                {'ahCancelled','Auction cancelled'}, {'ahOutbid','Auction outbid'}, {'other','Other mail'}, {'goldOnly','Gold only'}}) do
                local key = entry[1]
                root:CreateCheckbox(ns.L[entry[2]], function() return s[key] end, function() s[key] = not s[key] end)
            end
            -- The owner's safety rule takes precedence over the planned unsafe toggle.
            for _, value in ipairs({0,2,4,6}) do
                local slots = value
                root:CreateRadio(string.format(ns.L['Keep %d bag slots free'], slots), function() return s.keepFree == slots end, function() s.keepFree = slots end)
            end
        end)
    end)
end)
