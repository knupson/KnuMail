local _, ns = ...
local Inbox = {}; ns.Inbox = Inbox
function Inbox.Read(index)
    if index < 1 or index > GetInboxNumItems() then return nil end
    local _, _, sender, subject, money, cod, daysLeft, itemCount, _, wasReturned, _, canReply, isGM = GetInboxHeaderInfo(index)
    sender = sender or UNKNOWN
    local invoiceType = GetInboxInvoiceInfo(index)
    local kind = ns.Classify.Kind(subject, invoiceType)
    local trustedAH = invoiceType == 'seller' or invoiceType == 'buyer' or (canReply == false and kind ~= 'other')
    if not trustedAH then kind = 'other' end
    return {index = index, sender = sender, subject = subject or '', money = money or 0, cod = cod or 0,
        daysLeft = daysLeft or 0, itemCount = itemCount or 0, isGM = isGM, wasReturned = wasReturned,
        invoiceType = invoiceType, canReply = canReply, trustedAH = trustedAH, kind = kind}
end
function Inbox.Identity(mail, occurrence)
    return table.concat({mail.sender or '', mail.subject or '', tostring(mail.money or 0), tostring(mail.cod or 0),
        tostring(mail.itemCount or 0), tostring(occurrence or 1)}, '|')
end
function Inbox.Snapshot()
    local mails, occurrences = {}, {}
    for i = 1, GetInboxNumItems() do
        local mail = Inbox.Read(i)
        if mail then
            local base = Inbox.Identity(mail, 0)
            occurrences[base] = (occurrences[base] or 0) + 1
            mail.id = Inbox.Identity(mail, occurrences[base]); mails[i] = mail
        end
    end
    return mails
end
function Inbox.CanReturn(mail)
    return mail and mail.kind == 'other' and not mail.isGM and not mail.wasReturned and not InboxItemCanDelete(mail.index)
end
