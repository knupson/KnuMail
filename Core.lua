local _, ns = ...
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
frame:SetScript('OnEvent', function(_, event, ...)
    for _, fn in ipairs(handlers[event] or {}) do fn(...) end
end)
function ns.Print(message) DEFAULT_CHAT_FRAME:AddMessage('|cffffa82eKnuMail|r: ' .. message) end
ns.On('ADDON_LOADED', function(name)
    if name ~= 'KnuMail' then return end
    if type(KnuMailDB) ~= 'table' then KnuMailDB = {} end
    merge(KnuMailDB, defaults); ns.db = KnuMailDB
end)
