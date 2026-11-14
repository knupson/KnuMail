local _, ns = ...
-- Blizzard has already issued AutoLootMailItem; this hook only warns.
hooksecurefunc('InboxFrame_OnModifiedClick', function(_, index)
    local mail = ns.Inbox.Read(index)
    if mail and mail.cod == 0 and ns.Rules.IsStrangerGold(mail, ns.Names.IsKnown(mail.sender)) then
        ns.Print(string.format(ns.L['you took gold from a stranger (%s).'], mail.sender))
    end
end)
local initialized
ns.On('MAIL_SHOW',function()
    if initialized then return end
    initialized=true
    for i=1,INBOXITEMS_TO_DISPLAY do
        local position=i
        local row=_G['MailItem'..i]
        row:EnableMouse(true)
        row:HookScript('OnMouseUp',function(_,button)
            if button~='LeftButton' then return end
            local index=((InboxFrame.pageNum or 1)-1)*INBOXITEMS_TO_DISPLAY+position
            local mail=ns.Inbox.Snapshot()[index]
            if not mail then return end
            if IsControlKeyDown() then ns.Selection.ReturnMail(mail)
            elseif IsShiftKeyDown() then ns.OpenAll.Start({only={[mail.id]=true}}) end
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
