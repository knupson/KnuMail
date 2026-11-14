local _, ns = ...
local Selection = {}; ns.Selection = Selection
local selected = {}
function Selection.Toggle(id) selected[id] = not selected[id] or nil end
function Selection.Remove(id) selected[id] = nil end
function Selection.IsSelected(id) return selected[id] == true end
function Selection.Clear() selected = {} end
function Selection.Count() local n=0; for _ in pairs(selected) do n=n+1 end; return n end
function Selection.Ids() local copy={}; for id in pairs(selected) do copy[id]=true end; return copy end
function Selection.Range(ids, fromId, toId)
    local first, last
    for i,id in ipairs(ids) do if id==fromId then first=i end; if id==toId then last=i end end
    if not first or not last then return end
    for i=math.min(first,last),math.max(first,last) do selected[ids[i]]=true end
end
function Selection.BySender(sender, mails)
    local normalized = ns.Names.Normalize(sender)
    for _,mail in ipairs(mails) do if ns.Names.Normalize(mail.sender)==normalized then selected[mail.id]=true end end
end
ns.On('MAIL_CLOSED', Selection.Clear)
