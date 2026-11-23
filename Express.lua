local _, ns = ...
-- Blizzard has already issued AutoLootMailItem; this hook only warns.
hooksecurefunc('InboxFrame_OnModifiedClick', function(_, index)
    local mail = ns.Inbox.Read(index)
    if mail and mail.cod == 0 and ns.Rules.IsStrangerGold(mail, ns.Names.IsKnown(mail.sender)) then
        ns.Print(string.format(ns.L['you took gold from a stranger (%s).'], mail.sender))
    end
end)
local function returnBlock(mail)
    if mail.isGM then return ns.L['GM mail'] end
    if mail.kind ~= 'other' then return ns.L['system mail'] end
    if mail.wasReturned then return ns.L['already returned'] end
    if InboxItemCanDelete(mail.index) then return ns.L['the game only lets you delete it'] end
end
ns.ReturnBlock = returnBlock
-- The right-click menu holds every row action; modifier clicks on the row text clashed with the checkbox.
-- Actions resolve the mail again by identity when chosen: the inbox can shift while the menu is open.
local function current(id)
    for _, mail in ipairs(ns.Inbox.Snapshot()) do if mail.id == id then return mail end end
end
local function busy() return ns.OpenAll.IsRunning() or ns.Selection.IsReturning() end
-- Any inbox change while the menu is open voids it: identical mails are renumbered per snapshot,
-- so a vanished mail can hand its id to its twin.
local generation = 0
ns.On('MAIL_INBOX_UPDATE', function() generation = generation + 1 end)
ns.On('MAIL_CLOSED', function() generation = generation + 1 end)
local function showActions(row, mail)
    local id, opened = mail.id, generation
    local function stale()
        if generation == opened then return false end
        ns.Print(ns.L['The inbox changed; open the menu again.']); return true
    end
    MenuUtil.CreateContextMenu(row, function(_, root)
        root:CreateTitle(mail.sender)
        local take = root:CreateButton(ns.L['Take contents'], function()
            if busy() or stale() then return end
            if current(id) then ns.OpenAll.Start({only = {[id] = true}}) end
        end)
        local blocked = returnBlock(mail)
        local back = root:CreateButton(blocked and string.format(ns.L['Return to sender (%s)'], blocked) or ns.L['Return to sender'],
            function()
                if busy() or stale() then return end
                local fresh = current(id)
                if fresh then ns.Selection.ReturnMail(fresh) end
            end)
        if busy() then take:SetEnabled(false); back:SetEnabled(false)
        elseif blocked then back:SetEnabled(false) end
        root:CreateButton(ns.L['Mark mail from this sender'], function()
            if not stale() then ns.Selection.MarkSender(mail.sender) end
        end)
    end)
end
ns.ShowActions = showActions
local initialized
ns.On('MAIL_SHOW',function()
    if initialized then return end
    initialized=true
    for i=1,INBOXITEMS_TO_DISPLAY do
        local position=i
        local row=_G['MailItem'..i]
        row:EnableMouse(true)
        row:HookScript('OnMouseUp',function(self,button)
            if button~='RightButton' then return end
            local index=((InboxFrame.pageNum or 1)-1)*INBOXITEMS_TO_DISPLAY+position
            local mail=ns.Inbox.Snapshot()[index]
            if mail then showActions(self, mail) end
        end)
    end
end)
local function attach(self,button)
    if button~='LeftButton' or not IsAltKeyDown() or not SendMailFrame or not SendMailFrame:IsShown() or GetCursorInfo() then return end
    local free
    for slot=1,ATTACHMENTS_MAX_SEND do if not GetSendMailItem(slot) then free=slot; break end end
    if not free then return end
    local bag=self:GetBagID()
    if bag<0 or bag>4 then return end
    C_Container.PickupContainerItem(bag,self:GetID())
    if CursorHasItem() then ClickSendMailItemButton(free) end
end
-- Mixin methods are copied into existing pooled buttons. Hook the actual instance.
EventRegistry:RegisterCallback('ContainerFrameItemButton.EnterButton',function(_,item)
    if item.KnuMailExpressHook then return end
    item.KnuMailExpressHook=true
    hooksecurefunc(item,'OnModifiedClick',attach)
end,ns)
