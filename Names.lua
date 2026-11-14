local _, ns = ...
local Names = {}; ns.Names = Names
function Names.Normalize(name)
    if type(name) ~= 'string' then return nil end
    name = name:match('^%s*(.-)%s*$'):gsub('%-.*$', ''):match('^%s*(.-)%s*$')
    if name == '' then return nil end
    return string.lower(name)
end
local function full(name)
    local normalized = Names.Normalize(name)
    return normalized ~= nil and normalized:match('^%S+%s+%S+') ~= nil
end
function Names.Me()
    local first, last = UnitFullName('player')
    return first .. (last and last ~= '' and (' ' .. last) or '')
end
function Names.RegisterAlt()
    if not ns.db then return end
    local _, class = UnitClass('player')
    ns.db.alts[Names.Me()] = {class = class, level = UnitLevel('player'), faction = UnitFactionGroup('player')}
end
function Names.Contacts()
    local friends, guild = {}, {}
    for i = 1, C_FriendList.GetNumFriends() do
        local info = C_FriendList.GetFriendInfoByIndex(i)
        if info and full(info.name) then friends[#friends + 1] = info.name end
    end
    if BNGetNumFriends and C_BattleNet then
        for i = 1, BNGetNumFriends() do
            for j = 1, C_BattleNet.GetFriendNumGameAccounts(i) do
                local info = C_BattleNet.GetFriendGameAccountInfo(i, j)
                if info and info.isOnline and info.clientProgram == 'WoW' and info.wowProjectID == WOW_PROJECT_ID and full(info.characterName) then
                    friends[#friends + 1] = info.characterName
                end
            end
        end
    end
    for i = 1, GetNumGuildMembers() do
        local name = GetGuildRosterInfo(i)
        if full(name) then guild[#guild + 1] = name end
    end
    return friends, guild
end
function Names.IsKnown(name)
    if not full(name) then return false end
    local normalized = Names.Normalize(name)
    for alt in pairs(ns.db.alts) do if full(alt) and Names.Normalize(alt) == normalized then return true end end
    local friends, guild = Names.Contacts()
    for _, list in ipairs({friends, guild}) do
        for _, entry in ipairs(list) do if Names.Normalize(entry) == normalized then return true end end
    end
    return false
end
ns.On('PLAYER_LOGIN', Names.RegisterAlt)
ns.On('PLAYER_LEVEL_UP', Names.RegisterAlt)
