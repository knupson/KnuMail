local _, ns = ...
local Tooltip={}; ns.Tooltip=Tooltip
function Tooltip.Lines(index)
    local lines,byLink={},{}
    local mail=ns.Inbox.Read(index)
    if not mail then return lines end
    lines.money=mail.money; lines.cod=mail.cod
    for slot=1,ATTACHMENTS_MAX_RECEIVE do
        local link=HasInboxItem(index,slot) and GetInboxItemLink(index,slot)
        if link then
            local _,_,_,count=GetInboxItem(index,slot)
            if not byLink[link] then
                byLink[link]={link=link,count=0}; lines[#lines+1]=byLink[link]
            end
            byLink[link].count=byLink[link].count+(count or 1)
        end
    end
    return lines
end
local initialized
ns.On('MAIL_SHOW',function()
    if initialized then return end
    initialized=true
    for i=1,INBOXITEMS_TO_DISPLAY do
        local position=i
        local row=_G['MailItem'..i]
        row:EnableMouse(true)
        row:HookScript('OnEnter',function(self)
            local index=((InboxFrame.pageNum or 1)-1)*INBOXITEMS_TO_DISPLAY+position
            if not ns.Inbox.Read(index) then return end
            local lines=Tooltip.Lines(index)
            GameTooltip:SetOwner(self,'ANCHOR_RIGHT'); GameTooltip:SetText(ns.Inbox.Read(index).subject)
            for _,line in ipairs(lines) do GameTooltip:AddLine(line.link..' x'..line.count) end
            if lines.money>0 then GameTooltip:AddLine(ns.L['Gold']..': '..GetMoneyString(lines.money)) end
            if lines.cod>0 then GameTooltip:AddLine(ns.L['COD']..': '..GetMoneyString(lines.cod)) end
            GameTooltip:AddLine(ns.L['Right-click: actions'],0.6,0.6,0.6)
            GameTooltip:Show()
        end)
        row:HookScript('OnLeave',function() GameTooltip:Hide() end)
    end
end)
