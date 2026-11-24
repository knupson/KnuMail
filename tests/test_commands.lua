test('knu_mail_prints_help', function()
    FAKE.Fire('PLAYER_LOGIN'); FAKE.messages = {}
    LibStub('KnuLib-1.0'):Dispatch('mail', nil)
    eq(#FAKE.messages, 6); ok(FAKE.messages[1]:find('Clic derecho', 1, true), FAKE.messages[1])
    FAKE.messages = {}; LibStub('KnuLib-1.0'):Dispatch('correo', nil); eq(#FAKE.messages, 6)
    ok(FAKE.messages[6]:find('Otros addons de KNU: KnuCompanion', 1, true), FAKE.messages[6])
    ok(FAKE.messages[5]:find('github.com/knupson/KnuMail/issues', 1, true), FAKE.messages[5])
end)

test('feedback_line_once_per_account', function()
    FAKE.messages = {}
    FAKE.Fire('PLAYER_LOGIN')
    eq(#FAKE.messages, 1); ok(FAKE.messages[1]:find('curseforge.com/wow/addons/knumail', 1, true), FAKE.messages[1])
    eq(KnuMailDB.feedbackShown, true)
    FAKE.messages = {}; FAKE.Fire('PLAYER_LOGIN'); eq(#FAKE.messages, 0)
end)
