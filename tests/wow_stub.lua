FAKE = { frames = {} }
local methods = {}
function methods:SetScript(event, fn) self.scripts[event] = fn end
function methods:GetScript(event) return self.scripts[event] end
function methods:HookScript(event, fn)
    local previous = self.scripts[event]
    self.scripts[event] = function(...) if previous then previous(...) end; fn(...) end
end
function methods:RegisterEvent(event) self.events[event] = true end
function methods:Show() self.shown = true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
function methods:Hide() self.shown = false end
function methods:IsShown() return self.shown end
function methods:SetShown(value) if value then self:Show() else self:Hide() end end
function methods:SetText(text) self.text = text; if self.scripts.OnTextChanged then self.scripts.OnTextChanged(self, false) end end
function methods:GetText() return self.text or '' end
function methods:SetChecked(value) self.checked = value end
function methods:GetChecked() return self.checked end
function methods:GetID() return self.id end
function methods:GetParent() return self.parent end
function methods:CreateFontString() return CreateFrame('FontString') end
for _, method in ipairs({'SetPoint','SetSize','SetWidth','SetHeight','RegisterForClicks','EnableMouse','SetOwner','AddLine','SetHyperlink','HighlightText','SetCursorPosition','SetAutoFocus','ClearAllPoints','SetNormalTexture','SetHighlightTexture'}) do methods[method] = function() end end
function CreateFrame(kind, name, parent)
    local frame = setmetatable({ scripts = {}, events = {}, shown = true, parent = parent }, {__index = methods})
    FAKE.frames[#FAKE.frames + 1] = frame
    if name then _G[name] = frame end
    return frame
end
UIParent = CreateFrame('Frame')
InboxFrame = CreateFrame('Frame'); InboxFrame.pageNum = 1
InboxFrame.OpenAllMail = CreateFrame('Button', nil, InboxFrame)
function InboxFrame:Update() end
SendMailFrame = CreateFrame('Frame'); SendMailNameEditBox = CreateFrame('EditBox')
GameTooltip = CreateFrame('Tooltip')
FAKE.attachmentClick=function() end
for i = 1, 7 do
    local row=CreateFrame('Frame', 'MailItem' .. i, InboxFrame)
    row.Button=CreateFrame('Button','MailItem'..i..'Button',row)
    row.Button:SetScript('OnClick',FAKE.attachmentClick)
end
function hooksecurefunc(target, key, hook)
    if type(target) == 'string' then hook = key; key = target; target = _G end
    local previous = target[key]
    target[key] = function(...) if previous then previous(...) end; hook(...) end
end
function FAKE.Fire(event, ...)
    for _, frame in ipairs(FAKE.frames) do
        if frame.events[event] and frame.scripts.OnEvent then frame.scripts.OnEvent(frame, event, ...) end
    end
end
function FAKE.Advance(seconds)
    local finish = FAKE.time + seconds
    while true do
        local index, due
        for i, timer in ipairs(FAKE.timers) do if not due or timer.at < due then index, due = i, timer.at end end
        if not due or due > finish then break end
        FAKE.time = due
        local timer = table.remove(FAKE.timers, index)
        if not timer.cancelled then timer.fn() end
    end
    FAKE.time = finish
end
C_Timer = {}
function C_Timer.NewTimer(delay, fn)
    local timer = { at = FAKE.time + delay, fn = fn }
    function timer:Cancel() self.cancelled = true end
    FAKE.timers[#FAKE.timers + 1] = timer
    return timer
end
function C_Timer.After(delay, fn) C_Timer.NewTimer(delay, fn) end
function GetTime() return FAKE.time end
function GetLocale() return FAKE.locale or 'esES' end
function UnitFullName() return 'Yaestoy', 'Muerto' end
UnitName = UnitFullName
function UnitClass() return 'Guerrero', 'WARRIOR' end
function UnitLevel() return 60 end
function UnitFactionGroup() return 'Horde' end
C_FriendList = {GetNumFriends = function() return #FAKE.friends end, GetFriendInfoByIndex = function(i) return FAKE.friends[i] end}
function GetNumGuildMembers() return #FAKE.guild end
function GetGuildRosterInfo(i) return FAKE.guild[i] end
function BNGetNumFriends() return #FAKE.bn end
C_BattleNet = { GetFriendNumGameAccounts = function(i) return #(FAKE.bn[i] or {}) end,
    GetFriendGameAccountInfo = function(i, j) return FAKE.bn[i][j] end }
WOW_PROJECT_ID = 99
function GetInboxNumItems() return #FAKE.inbox, FAKE.total or #FAKE.inbox end
function GetInboxHeaderInfo(i)
    local m = FAKE.inbox[i]; if not m then return end
    local count = m.itemCount
    if count == nil and not m.nilItemCount then count = #(m.items or {}) end
    local canReply = m.canReply ~= false
    return nil, nil, m.sender, m.subject or '', m.money or 0, m.cod or 0, m.daysLeft or 30,
        count, false, m.wasReturned or false, false, canReply, m.isGM or false
end
function GetInboxInvoiceInfo(i) return FAKE.inbox[i].invoiceType end
function GetInboxItem(i, slot)
    local item = (FAKE.inbox[i].items or {})[slot]
    if item then return not item.uncached and (item.name or 'Item') or nil, item.id or 1, nil, item.count or 1 end
end
function HasInboxItem(i, slot) return (FAKE.inbox[i].items or {})[slot] ~= nil end
function GetInboxItemLink(i, slot) local item = (FAKE.inbox[i].items or {})[slot]; return item and item.link end
local function take(kind, i, slot)
    FAKE.calls[#FAKE.calls + 1] = {kind = kind, index = i, slot = slot, time = FAKE.time}
    if kind == 'item' and FAKE.inventoryError then FAKE.Fire('UI_ERROR_MESSAGE', 1, ERR_INV_FULL); return end
    local m = FAKE.inbox[i]
    local function complete()
        FAKE.pending = false
        if kind == 'item' and (m.items[slot].fail or FAKE.failedIDs[m.items[slot].id]) then
            FAKE.Fire('MAIL_FAILED', m.items[slot].id); return
        end
        if kind == 'money' then m.money = 0 else m.items[slot] = nil; m.itemCount = math.max(0, (m.itemCount or 1) - 1); FAKE.freeSlots = FAKE.freeSlots - 1 end
        if not m.keep and (m.money or 0) == 0 and (m.itemCount or 0) == 0 then
            table.remove(FAKE.inbox, i)
            if FAKE.total then FAKE.total=FAKE.total-1 end
        end
        FAKE.Fire('MAIL_SUCCESS'); FAKE.Fire('MAIL_INBOX_UPDATE')
    end
    if FAKE.deferTicks > 0 then
        FAKE.pending = true
        local remaining = FAKE.deferTicks
        local function wait()
            remaining = remaining - 1
            if remaining == 0 then complete() else C_Timer.NewTimer(0.15, wait) end
        end
        C_Timer.NewTimer(0.15, wait)
    else complete() end
end
function TakeInboxMoney(i) take('money', i) end
function TakeInboxItem(i, slot) take('item', i, slot) end
function AutoLootMailItem(i) TakeInboxMoney(i) end
function InboxFrame_OnModifiedClick(self, index)
    local _,_,_,_,_,cod=GetInboxHeaderInfo(index)
    if cod<=0 then
        -- Native mail commands finish asynchronously, after secure post-hooks.
        local ticks=FAKE.deferTicks; FAKE.deferTicks=math.max(1,ticks)
        AutoLootMailItem(index); FAKE.deferTicks=ticks
    end
end
function ReturnInboxItem(i) FAKE.returns[#FAKE.returns + 1] = i; table.remove(FAKE.inbox, i) end
function DeleteInboxItem(i) table.remove(FAKE.inbox, i) end
function InboxItemCanDelete(i) return FAKE.inbox[i].canDelete or false end
function CheckInbox() FAKE.checks = FAKE.checks + 1; if FAKE.onCheck then FAKE.onCheck() end end
C_Mail = { IsCommandPending = function() return FAKE.pending end, CanCheckInbox = function() return FAKE.canCheck, FAKE.checkSeconds end,
    HasInboxMoney = function() for _, m in ipairs(FAKE.inbox) do if (m.money or 0) > 0 then return true end end return false end,
    SetOpeningAll = function(value) FAKE.opening = value end }
C_Container = {CalculateTotalNumberOfFreeBagSlots = function() return FAKE.freeSlots end,
    GetContainerNumFreeSlots = function(bag) return bag == 0 and FAKE.freeSlots or FAKE.specialFree, bag == 0 and 0 or 32 end,
    PickupContainerItem = function(bag, slot) FAKE.pickup = {bag, slot} end}
function ClickSendMailItemButton(slot) FAKE.attached = slot end
function GetSendMailItem(slot) return FAKE.sendItems[slot] end
function SetSendMailMoney(value) FAKE.sendMoney = value end
function CursorHasItem() return FAKE.pickup ~= nil end
function GetCursorInfo() return FAKE.cursor end
function IsShiftKeyDown() return FAKE.shift end
function IsControlKeyDown() return FAKE.ctrl end
function IsAltKeyDown() return FAKE.alt end
function GetMoneyString(amount) return tostring(amount) end
function GetCoinTextureString(amount) return tostring(amount) end
StaticPopupDialogs = {}
ACCEPT = 'Aceptar'; CANCEL = 'Cancelar'
function StaticPopup_Show(which, arg1, arg2, data)
    local dialog=assert(StaticPopupDialogs[which])
    local popup={which=which, data=data, text=string.format(dialog.text,arg1,arg2)}
    FAKE.popups[which]=popup; FAKE.popupShows=FAKE.popupShows+1
    return popup
end
function StaticPopup_Hide(which) FAKE.popups[which]=nil end
function FAKE.RespondPopup(accept, reason)
    local which='KNUMAIL_STRANGER_GOLD'
    local popup=assert(FAKE.popups[which], 'No hay confirmación pendiente')
    FAKE.popups[which]=nil
    local callback=accept and StaticPopupDialogs[which].OnAccept or StaticPopupDialogs[which].OnCancel
    callback(popup,popup.data,reason)
end
function ContainerFrameItemButton_OnModifiedClick() end
ContainerFrameItemButtonMixin={OnModifiedClick=function() end}
EventRegistry={callbacks={}}
function EventRegistry:RegisterCallback(event,fn,owner) self.callbacks[event]={fn=fn,owner=owner} end
function EventRegistry:TriggerEvent(event,...)
    local callback=self.callbacks[event]; if callback then callback.fn(callback.owner,...) end
end
DEFAULT_CHAT_FRAME = {AddMessage = function(_, message) FAKE.messages[#FAKE.messages + 1] = message end}
MenuUtil = {CreateContextMenu = function(owner, generator)
    local root = {}; function root:CreateTitle() end
    function root:CreateButton(label, callback) return self end
    root.CreateCheckbox = root.CreateButton; root.CreateRadio = root.CreateButton
    generator(owner, root)
end}
INBOXITEMS_TO_DISPLAY = 7; ATTACHMENTS_MAX_RECEIVE = 16; ATTACHMENTS_MAX_SEND = 12
ERR_INV_FULL = 'Inventario lleno'
UNKNOWN = 'Desconocido'
AUCTION_EXPIRED_MAIL_SUBJECT = 'Subasta terminada: %s'
AUCTION_REMOVED_MAIL_SUBJECT = 'Subasta cancelada: %s'
AUCTION_OUTBID_MAIL_SUBJECT = 'Puja superada en %s'
AUCTION_SOLD_MAIL_SUBJECT = 'Subasta conseguida: %s'
AUCTION_WON_MAIL_SUBJECT = 'Subasta ganada: %s'
function FAKE.Reset()
    FAKE.Fire('MAIL_CLOSED')
    if ns.OpenAll then ns.OpenAll.Stop() end
    FAKE.inbox = {}; FAKE.friends = {}; FAKE.guild = {}; FAKE.bn = {}; FAKE.freeSlots = 20; FAKE.time = 0
    FAKE.timers = {}; FAKE.calls = {}; FAKE.returns = {}; FAKE.messages = {}; FAKE.sendItems = {}
    FAKE.popups = {}; FAKE.popupShows = 0
    FAKE.pending = false; FAKE.canCheck = true; FAKE.checks = 0; FAKE.total = nil; FAKE.onCheck = nil
    FAKE.checkSeconds = 0; FAKE.deferTicks = 0; FAKE.failedIDs = {}; FAKE.specialFree = 0
    FAKE.inventoryError = nil; FAKE.alt = false; FAKE.ctrl = false; FAKE.shift = false; FAKE.pickup = nil; FAKE.cursor = nil; FAKE.attached = nil
    InboxFrame.pageNum = 1; SendMailFrame:Hide(); SendMailNameEditBox:SetText('')
    KnuMailDB = nil; FAKE.Fire('ADDON_LOADED', 'KnuMail')
    if ns.Selection then ns.Selection.Clear() end
end
FAKE.Reset()
