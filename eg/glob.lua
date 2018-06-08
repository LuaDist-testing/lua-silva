
local function glob (dirname, patt)
    return coroutine.wrap(function ()
        local sme = require'Silva'(patt, 'shell')
        for fname in require'lfs'.dir(dirname) do
            if sme(fname) then
                coroutine.yield(fname)
            end
        end
    end)
end

for k in glob('test', '*.t') do
    print(k)
end

for k in glob('src/Silva', '*.lua') do
    print(k)
end
