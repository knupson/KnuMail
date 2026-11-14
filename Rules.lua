local _, ns = ...
ns.Rules = {}
function ns.Rules.IsStrangerGold(mail, isKnown)
    return not mail.trustedAH and not isKnown and (mail.money or 0) > 0
end
function ns.Rules.Decide(mail, settings, isKnown, explicit)
    if (mail.cod or 0) > 0 then return 'skip', 'cod' end
    if mail.isGM then return 'skip', 'gm' end
    if not explicit then
        if ns.Rules.IsStrangerGold(mail, isKnown) then return 'skip', 'strangerGold' end
        if settings[mail.kind] == false then return 'skip', 'filter' end
    end
    if settings.goldOnly then
        if (mail.money or 0) > 0 then return 'gold' end
        return 'skip', 'empty'
    end
    if (mail.money or 0) == 0 and (mail.itemCount or 0) == 0 then return 'skip', 'empty' end
    return 'take'
end
