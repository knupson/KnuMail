local _, ns = ...
ns.Classify = {}
function ns.Classify.Kind(subject, invoiceType, subjects)
    if invoiceType == 'seller' then return 'ahSold' end
    if invoiceType == 'buyer' then return 'ahWon' end
    subjects = subjects or {ahExpired = AUCTION_EXPIRED_MAIL_SUBJECT, ahCancelled = AUCTION_REMOVED_MAIL_SUBJECT,
        ahOutbid = AUCTION_OUTBID_MAIL_SUBJECT, ahSold = AUCTION_SOLD_MAIL_SUBJECT, ahWon = AUCTION_WON_MAIL_SUBJECT}
    for _, kind in ipairs({'ahExpired', 'ahCancelled', 'ahOutbid', 'ahSold', 'ahWon'}) do
        local template = subjects[kind]
        if template then
            local pattern = template:gsub('([%^%$%(%)%%%.%[%]%*%+%-%?])', '%%%1'):gsub('%%%%s', '.+')
            if (subject or ''):match('^' .. pattern .. '$') then return kind end
        end
    end
    return 'other'
end
