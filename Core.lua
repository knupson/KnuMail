local _, ns = ...
local KL = LibStub('KnuLib-1.0')
ns.KL = KL
local defaults = {settings = {openAll = {ahSold = true, ahWon = true, ahExpired = true,
    ahCancelled = true, ahOutbid = true, other = true, strangerGold = false, keepFree = 0, goldOnly = false},
    rememberLast = false}, alts = {}, recent = {}}
local events = KL:NewEvents()
ns.Events = events
function ns.On(event, fn) return events:On(event, fn) end
-- Forever closes the mailbox through the player interaction manager and never fires MAIL_CLOSED
-- (in-game test 2026-11-16: only PLAYER_INTERACTION_MANAGER_FRAME_HIDE 17, then 0), so that hide
-- runs the MAIL_CLOSED handlers. MAIL_CLOSED stays registered for clients that do fire it; it has no
-- arguments, so none are passed on.
events:On('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', function(kind)
    local mailType = Enum and Enum.PlayerInteractionType and Enum.PlayerInteractionType.MailInfo
    if mailType ~= nil and kind == mailType then events:Emit('MAIL_CLOSED') end
end)
ns.Print = KL:NewPrinter('Mail')
ns.On('ADDON_LOADED', function(name)
    if name ~= 'KnuMail' then return end
    if type(KnuMailDB) ~= 'table' then KnuMailDB = {} end
    KnuMailDB = KL:ApplyDefaults(KnuMailDB, defaults); ns.db = KnuMailDB
end)
