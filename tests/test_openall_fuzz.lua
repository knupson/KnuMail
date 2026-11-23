-- Randomised Open all runs with late inbox data and emptied mails that linger before the server deletes them.
local function lingering()
    local takeMoney, takeItem = TakeInboxMoney, TakeInboxItem
    local function watch(m)
        local delay = ({0, 0.1, 0.3, 0.7, 1.5})[math.random(1, 5)]
        local function check()
            if (m.money or 0) == 0 and next(m.items or {}) == nil then
                C_Timer.NewTimer(delay, function()
                    for j, x in ipairs(FAKE.inbox) do
                        if x == m then table.remove(FAKE.inbox, j); FAKE.Fire('MAIL_INBOX_UPDATE'); break end
                    end
                end)
            else C_Timer.NewTimer(0.05, check) end
        end
        C_Timer.NewTimer(0.05, check)
    end
    TakeInboxMoney = function(i) local m = FAKE.inbox[i]; takeMoney(i); watch(m) end
    TakeInboxItem = function(i, slot) local m = FAKE.inbox[i]; takeItem(i, slot); watch(m) end
    return function() TakeInboxMoney, TakeInboxItem = takeMoney, takeItem end
end
test('open_all_fuzz_counts_every_mail_and_coin_once', function()
    local bad = {}
    for seed = 1, 150 do
        FAKE.Reset(); math.randomseed(seed); FAKE.freeSlots = 200
        local n, twins, gold, items = math.random(2, 14), math.random() < 0.5, 0, 0
        for i = 1, n do
            local kind = math.random(1, 3)
            local m = {sender = 'Casa de subastas: Horda', subject = twins and ('Venta ' .. math.random(1, 2)) or ('Venta ' .. i),
                invoiceType = kind == 2 and 'buyer' or 'seller', money = kind ~= 2 and (twins and 100 or 100 + i) or 0, keep = true, items = {}}
            if kind ~= 1 then for s = 1, math.random(1, 2) do m.items[s] = {id = 10 + s, link = 'item:' .. (10 + s), count = 1} end end
            m.itemCount = #m.items; FAKE.inbox[i] = m; gold = gold + m.money; items = items + m.itemCount
        end
        FAKE.lag = ({false, 0.2, 0.6})[math.random(1, 3)] or nil
        FAKE.deferTicks = math.random(0, 3)
        local restore = lingering()
        local done, err = pcall(function() ns.OpenAll.Start(); FAKE.Advance(200) end)
        restore()
        local s = ns.OpenAll.Summary()
        local taken = 0
        for _, call in ipairs(FAKE.calls) do if call.kind == 'item' then taken = taken + 1 end end
        if not done or s.opened ~= n or s.gold ~= gold or taken ~= items or s.skipped.empty or s.skipped.failed or #FAKE.inbox > 0 then
            bad[#bad + 1] = string.format('seed %d: n=%d opened=%s gold=%s/%d empty=%s failed=%s left=%d %s', seed, n,
                tostring(s.opened), tostring(s.gold), gold, tostring(s.skipped.empty), tostring(s.skipped.failed), #FAKE.inbox, tostring(err or ''))
        end
    end
    ok(#bad == 0, table.concat(bad, '\n', 1, math.min(#bad, 5)))
end)
