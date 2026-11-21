local _, ns = ...
-- Forever 1.60.1.70959 (2026-11-17) only fills the subject from the first attachment when C.O.D. is
-- enabled (SendMailFrame_Update), and mail cannot be sent without a subject. KnuMail fills it the same
-- way. A subject the player typed or cleared is never touched again until the compose form resets.
local auto, manual
-- First attachment as Blizzard names it: "Name" or "Name (count)". Returns nil, true while its data loads.
local function title()
    for slot = 1, ATTACHMENTS_MAX_SEND do
        if HasSendMailItem(slot) then
            local name, _, _, count = GetSendMailItem(slot)
            if not name then return nil, true end
            return (count or 1) <= 1 and name or (name .. ' (' .. count .. ')'), true
        end
    end
    return nil, false
end
local function reset() auto, manual = nil, false end
local function fill()
    if manual or not SendMailSubjectEditBox then return end
    local current = SendMailSubjectEditBox:GetText() or ''
    local wanted, attached = title()
    if not attached then
        if auto and current == auto then SendMailSubjectEditBox:SetText('') end
        auto = nil; return
    end
    if not wanted then return end
    if current == wanted then auto = wanted; return end
    if current == '' or current == auto or current == SendMailFrame.previousItem then
        auto = wanted; SendMailSubjectEditBox:SetText(wanted)
    end
end
if SendMailFrame_Update then hooksecurefunc('SendMailFrame_Update', fill) end
if SendMailFrame_Reset then hooksecurefunc('SendMailFrame_Reset', reset) end
if SendMailSubjectEditBox then
    SendMailSubjectEditBox:HookScript('OnTextChanged', function(_, userInput) if userInput then manual = true end end)
end
ns.On('MAIL_CLOSED', reset)
reset()
