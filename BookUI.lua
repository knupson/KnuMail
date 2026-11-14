local _, ns = ...
local initialized, recipient
ns.On('MAIL_SHOW',function()
    if initialized then return end
    initialized=true
    local edit=SendMailNameEditBox
    -- Icon button: a text button covered the "Postage" cost label (in-game test 2026-11-13).
    local button=CreateFrame('Button',nil,SendMailFrame)
    button:SetSize(20,20); button:SetPoint('LEFT',edit,'RIGHT',3,0)
    button:SetNormalTexture('Interface\\Icons\\INV_Misc_Book_09')
    button:SetHighlightTexture('Interface\\Buttons\\ButtonHilight-Square','ADD')
    button:SetScript('OnEnter',function(self)
        GameTooltip:SetOwner(self,'ANCHOR_RIGHT'); GameTooltip:SetText(ns.L['Address book']); GameTooltip:Show()
    end)
    button:SetScript('OnLeave',function() GameTooltip:Hide() end)
    button:SetScript('OnClick',function(self)
        MenuUtil.CreateContextMenu(self,function(_,root)
            root:CreateTitle(ns.L['Address book'])
            local lists=ns.Book.Lists()
            for _,entry in ipairs({{'alts','Alts'},{'recent','Recent'},{'friends','Friends'},{'guild','Guild'}}) do
                local submenu=root:CreateButton(ns.L[entry[2]])
                for _,name in ipairs(lists[entry[1]]) do
                    local destination=name
                    submenu:CreateButton(destination,function() edit:SetText(destination); edit:SetCursorPosition(#destination) end)
                end
            end
            root:CreateCheckbox(ns.L['Remember last recipient'],function() return ns.db.settings.rememberLast end,
                function() ns.db.settings.rememberLast=not ns.db.settings.rememberLast end)
        end)
    end)
    -- Only remembers what was typed; Forever's own autocomplete fills the field.
    edit:HookScript('OnTextChanged',function(self)
        local text=self:GetText()
        if text~='' then recipient=text end
    end)
    SendMailFrame:HookScript('OnShow',function()
        if ns.db.settings.rememberLast and ns.db.recent[1] then edit:SetText(ns.db.recent[1]) end
    end)
end)
ns.On('MAIL_SEND_SUCCESS',function()
    local name=SendMailNameEditBox:GetText()
    ns.Book.AddRecent(name~='' and name or recipient); recipient=nil
end)
ns.On('MAIL_CLOSED',function() recipient=nil end)
