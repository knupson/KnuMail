local _, ns = ...
local initialized, anchor, returnTimer, returning, pageNum
function ns.Selection.IsReturning() return returning ~= nil end
local function cancelReturns()
    returning = nil
    if returnTimer then returnTimer:Cancel(); returnTimer=nil end
end
local function visibleMails()
    local page = InboxFrame.pageNum or 1
    if pageNum and pageNum ~= page then
        ns.Selection.Clear(); anchor=nil; cancelReturns()
    end
    pageNum=page
    local mails=ns.Inbox.Snapshot()
    local existing={}
    for _,mail in ipairs(mails) do existing[mail.id]=true end
    for id in pairs(ns.Selection.Ids()) do if not existing[id] then ns.Selection.Remove(id) end end
    if anchor and not existing[anchor] then anchor=nil end
    local visible={}; local offset=(page-1)*INBOXITEMS_TO_DISPLAY
    for i=1,INBOXITEMS_TO_DISPLAY do if mails[offset+i] then visible[#visible+1]=mails[offset+i] end end
    return visible
end
local function selectedVisible()
    local ids={}
    for _,mail in ipairs(visibleMails()) do if ns.Selection.IsSelected(mail.id) then ids[mail.id]=true end end
    return ids
end
function ns.Selection.ReturnMail(mail)
    if ns.OpenAll.IsRunning() or returning or C_Mail.IsCommandPending() or not ns.Inbox.CanReturn(mail) then return false end
    ReturnInboxItem(mail.index); return true
end
function ns.Selection.ReturnSelected()
    if returning or ns.OpenAll.IsRunning() then return end
    returning = selectedVisible()
    local function step()
        returnTimer=nil
        if not returning then return end
        if not C_Mail.IsCommandPending() then
            local mails=ns.Inbox.Snapshot()
            -- Descending order preserves occurrence numbers for identical remaining mail.
            for i=#mails,1,-1 do
                local mail=mails[i]
                if returning[mail.id] then
                    returning[mail.id]=nil
                    if ns.Inbox.CanReturn(mail) then
                        ReturnInboxItem(mail.index)
                        returnTimer=C_Timer.NewTimer(0.15,step); return
                    end
                end
            end
            cancelReturns(); ns.Selection.Clear(); InboxFrame:Update(); return
        end
        returnTimer=C_Timer.NewTimer(0.15,step)
    end
    step()
end
local function refresh()
    if not initialized then return end
    local mails=visibleMails()
    for i=1,INBOXITEMS_TO_DISPLAY do
        local row=_G['MailItem'..i]; local mail=mails[i]
        row.KnuMailCheck.mail=mail
        row.KnuMailCheck:SetShown(mail~=nil)
        row.KnuMailCheck:SetChecked(mail and ns.Selection.IsSelected(mail.id) or false)
        row.KnuMailNumber:SetText(mail and tostring(mail.index) or '')
    end
end
ns.On('MAIL_CLOSED',function() anchor=nil; cancelReturns(); refresh(); pageNum=nil end)
ns.On('MAIL_FAILED',cancelReturns)
ns.On('MAIL_SHOW',function()
    if initialized then refresh(); return end
    initialized=true
    for i=1,INBOXITEMS_TO_DISPLAY do
        local row=_G['MailItem'..i]
        local box=CreateFrame('CheckButton',nil,row,'UICheckButtonTemplate'); row.KnuMailCheck=box
        box:SetSize(22,22); box:SetPoint('LEFT',row,'RIGHT',-2,-3)
        local number=row:CreateFontString(nil,'OVERLAY','GameFontNormalSmall'); row.KnuMailNumber=number
        number:SetPoint('BOTTOM',box,'TOP',0,-2)
        box:SetScript('OnClick',function(self)
            refresh()
            if not self.mail then return end
            if IsControlKeyDown() then ns.Selection.BySender(self.mail.sender,visibleMails())
            elseif IsShiftKeyDown() then
                local ids={}; local offset=((InboxFrame.pageNum or 1)-1)*INBOXITEMS_TO_DISPLAY
                local mails=ns.Inbox.Snapshot()
                for n=1,INBOXITEMS_TO_DISPLAY do if mails[offset+n] then ids[#ids+1]=mails[offset+n].id end end
                ns.Selection.Range(ids,anchor or self.mail.id,self.mail.id)
            else ns.Selection.Toggle(self.mail.id) end
            anchor=self.mail.id; refresh()
        end)
    end
    local open=CreateFrame('Button',nil,InboxFrame,'UIPanelButtonTemplate')
    open:SetSize(145,22); open:SetPoint('TOPLEFT',InboxFrame,'TOPLEFT',20,-44); open:SetText(ns.L['Open selected'])
    open:SetScript('OnClick',function() if not returning then ns.OpenAll.Start({only=selectedVisible()}) end end)
    local back=CreateFrame('Button',nil,InboxFrame,'UIPanelButtonTemplate')
    back:SetSize(145,22); back:SetPoint('LEFT',open,'RIGHT',4,0); back:SetText(ns.L['Return selected'])
    back:SetScript('OnClick',ns.Selection.ReturnSelected)
    hooksecurefunc(InboxFrame,'Update',refresh); refresh()
end)
