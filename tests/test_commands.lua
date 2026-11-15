test('knu_mail_prints_help', function()
    FAKE.Fire('PLAYER_LOGIN'); FAKE.messages = {}
    LibStub('KnuLib-1.0'):Dispatch('mail', nil)
    eq(#FAKE.messages, 5); ok(FAKE.messages[1]:find('Shift', 1, true), FAKE.messages[1])
    FAKE.messages = {}; LibStub('KnuLib-1.0'):Dispatch('correo', nil); eq(#FAKE.messages, 5)
end)
