local _, ns = ...
local Book = {}; ns.Book = Book
function Book.AddRecent(name)
    local normalized=ns.Names.Normalize(name)
    if not normalized or not normalized:match('%S+%s+%S+') then return end
    name=name:match('^%s*(.-)%s*$'):gsub('%-.*$',''):match('^%s*(.-)%s*$')
    for i=#ns.db.recent,1,-1 do if ns.Names.Normalize(ns.db.recent[i])==normalized then table.remove(ns.db.recent,i) end end
    table.insert(ns.db.recent,1,name)
    while #ns.db.recent>20 do table.remove(ns.db.recent) end
end
function Book.Lists()
    local lists={alts={},recent={},friends={},guild={}}
    local me=ns.Names.Normalize(ns.Names.Me())
    for name in pairs(ns.db.alts) do if ns.Names.Normalize(name)~=me then table.insert(lists.alts,name) end end
    table.sort(lists.alts)
    for i,name in ipairs(ns.db.recent) do lists.recent[i]=name end
    lists.friends,lists.guild=ns.Names.Contacts()
    return lists
end
