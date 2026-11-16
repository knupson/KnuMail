local _, ns = ...
local KL = LibStub('KnuLib-1.0')
ns.KL = KL
local defaults = {settings = {openAll = {ahSold = true, ahWon = true, ahExpired = true,
    ahCancelled = true, ahOutbid = true, other = true, strangerGold = false, keepFree = 0, goldOnly = false},
    rememberLast = false}, alts = {}, recent = {}}
local function merge(target, source)
    for key, value in pairs(source) do
        if type(value) == 'table' then
            if type(target[key]) ~= 'table' then target[key] = {} end
            merge(target[key], value)
        elseif target[key] == nil then target[key] = value end
    end
end
local handlers, frame = {}, CreateFrame('Frame')
function ns.On(event, fn)
    if not handlers[event] then handlers[event] = {}; frame:RegisterEvent(event) end
    handlers[event][#handlers[event] + 1] = fn
end
-- Forever closes the mailbox through the player interaction manager and never fires MAIL_CLOSED
-- (in-game test 2026-11-16: only PLAYER_INTERACTION_MANAGER_FRAME_HIDE 17, then 0), so that hide
-- runs the MAIL_CLOSED handlers. MAIL_CLOSED stays registered for clients that do fire it.
frame:RegisterEvent('PLAYER_INTERACTION_MANAGER_FRAME_HIDE')
frame:SetScript('OnEvent', function(_, event, ...)
    if event == 'PLAYER_INTERACTION_MANAGER_FRAME_HIDE' then
        local mailType = Enum and Enum.PlayerInteractionType and Enum.PlayerInteractionType.MailInfo
        if mailType == nil or (...) ~= mailType then return end
        event = 'MAIL_CLOSED'
    end
    for _, fn in ipairs(handlers[event] or {}) do fn(...) end
end)
ns.Print = KL:NewPrinter('Mail')
ns.On('ADDON_LOADED', function(name)
    if name ~= 'KnuMail' then return end
    if type(KnuMailDB) ~= 'table' then KnuMailDB = {} end
    merge(KnuMailDB, defaults); ns.db = KnuMailDB
end)
