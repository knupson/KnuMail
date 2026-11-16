local _, ns = ...
-- /knu mail (alias /knu correo): KnuLib-1.0 minor 3 shares /knu between Knu addons.
local help = {'Right-click a row: take its contents, return it or mark that sender.',
    'Row checkbox: click marks it; Shift-click marks a range; Ctrl-click marks that sender.',
    'Alt-click a bag item with Send Mail open: attach it.',
    'Open all settings: the Options button next to Open all.'}
function ns.PrintHelp()
    for _, line in ipairs(help) do ns.Print(ns.L[line]) end
end
-- Registered on login, never at file load: an older KnuLib copy may still be the active one.
ns.On('PLAYER_LOGIN', function()
    local KL = LibStub('KnuLib-1.0')
    if KL.RegisterCommand then
        KL:RegisterCommand('mail', function() ns.PrintHelp() end, ns.L['KnuMail clicks and settings'], {'correo'})
    end
end)
