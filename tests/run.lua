local ns = {}
_G.ns = ns
dofile('tests/wow_stub.lua')
local count, failures = 0, 0
function eq(actual, expected, message)
    if actual ~= expected then error((message or 'Valores distintos') .. ': ' .. tostring(actual) .. ' ~= ' .. tostring(expected), 2) end
end
function ok(value, message) if not value then error(message or 'Condición falsa', 2) end end
function test(name, fn)
    count = count + 1
    FAKE.Reset()
    local success, err = pcall(fn)
    if not success then failures = failures + 1; print('FALLÓ ' .. name .. ': ' .. tostring(err)) end
end
local toc = io.open('KnuMail.toc', 'r')
if toc then
    for line in toc:lines() do
        local path = line:match('^%s*([^#%s].-%.lua)%s*$')
        if path then
            assert(loadfile(path))('KnuMail', ns)
        end
    end
    toc:close()
end
local pipe = assert(io.popen('cmd /c dir /b /on tests\\test_*.lua 2>nul'))
for file in pipe:lines() do dofile('tests/' .. file) end
pipe:close()
print(string.format('%d tests, %d failures', count, failures))
os.exit(failures == 0 and 0 or 1)
