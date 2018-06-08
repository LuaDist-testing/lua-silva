
--
-- lua-Silva : <http://fperrad.github.io/lua-Silva/>
--

local modname = string.gsub(..., '%.%w+$', '')
local matcher = require(modname).matcher

local char = string.char
local error = error
local tonumber = tonumber
local tostring = tostring
local _ENV = nil

local function convert (n)
    return char(tonumber(n, 16))
end

local function unescape (s, query)
    if query then
        s = s:gsub('+', ' ')    -- x-www-form-urlencoded
    end
    return (s:gsub('%%(%x%x)', convert))
end

local legal_op = {
    ['0'] = false,      -- literal
    ['1'] = false,      -- unreserved character string expansion
    ['+'] = true,       -- reserved character string expansion
    ['#'] = true,       -- fragment expansion, crosshatch-prefixed
    ['.'] = true,       -- label expansion, dot-prefixed
    ['/'] = true,       -- path segments, slash-prefixed
    [';'] = true,       -- path-style parameters, semicolon-prefixed
    ['?'] = true,       -- form-style query, ampersand-separated
    ['&'] = true,       -- form-style query continuation
}

local future_op = {
    ['='] = true,
    [','] = true,
    ['!'] = true,
    ['@'] = true,
    ['|'] = true,
}

local function compile (patt)
    local exist = {}
    local function uniq (name)
        if exist[name] then
            error("duplicated name " .. name, 4)
        end
        exist[name] = true
        return name
    end  -- uniq

    local ops = {}
    local ip = 1
    for start, _end in patt:gmatch("()%b{}()") do
        if start > ip then
            ops[#ops+1] = { '0', unescape(patt:sub(ip, start - 1)) }
        end
        ip = _end
        local s = patt:sub(start + 1, _end - 2)
        local c = s:sub(1, 1)
        if future_op[c] then
            error("operator for future extension found at position " .. tostring(start + 1), 3)
        end
        local op = {}
        local i
        if legal_op[c] then
            op[1] = c
            i = 2
        else
            op[1] = '1'
            i = 1
        end
        local j = i
        while i <= #s do
            c = s:sub(i, i)
            if not c:match'[%d%a_]' then
                if     c == ',' then
                    op[#op+1] = uniq(s:sub(j, i - 1))
                    j = i + 1
                elseif c == '%' then
                    c = s:sub(i+1, i+2)
                    if not c:match'%x%x' then
                        error("invalid triplet found at position " .. tostring(start + i), 3)
                    end
                    i = i + 2
                elseif c == ':' or c == '*' then
                    error("modifier (level 4) found at position " .. tostring(start + i), 3)
                else
                    error("invalid character found at position " .. tostring(start + i), 3)
                end
            end
            i = i + 1
        end
        if i ~= j then
            op[#op+1] = uniq(s:sub(j, i))
        end
        ops[#ops+1] = op
    end
    if #patt > ip then
        ops[#ops+1] = { '0', unescape(patt:sub(ip)) }
    end
    return ops
end

local patt_end = {
    ['1'] = '[/?#]',
    ['+'] = '[?#]',
    ['#'] = '][',       -- never match
    ['.'] = '[/?#]',
    ['/'] = '[?#]',
    [';'] = '[/?#]',
    ['?'] = '[#]',
    ['&'] = '[#]',
}

local sep_var = {
    ['1'] = ',',
    ['+'] = ',',
    ['#'] = ',',
    ['.'] = '.',
    ['/'] = '/',
    [';'] = ';',
    ['?'] = '&',
    ['&'] = '&',
}

local function match (s, ops)
    local capture = {}
    local query = false

    local function inner (i, ip)
        for k = ip, #ops do
            local op = ops[k]
            local oper = op[1]
            if     oper == '0' then
                local literal = op[2]
                for j = 1, #literal do
                    local c
                    local p = literal:sub(j, j)
                    local n = s:match('^%%(%x%x)', i)
                    if n then
                        c = convert(n)
                        i = i + 3
                    else
                        c = s:sub(i, i)
                        if c == '+' and query then
                            c = ' '     -- x-www-form-urlencoded
                        end
                        if c == '?' then
                            query = true
                        end
                        if c == '#' then
                            query = false
                        end
                        i = i + 1
                    end
                    if c ~= p then
                        return
                    end
                end
            elseif oper == ';' or oper == '?' or oper == '&' then
                local c = s:sub(i, i)
                if c == oper then
                    if c == '?' then
                        query = true
                    end
                    i = i + 1
                    local keys = {}
                    for j = 2, #op do
                        keys[op[j]] = true
                    end
                    local start = i
                    local key
                    while i <= #s do
                        while i <= #s do
                            c = s:sub(i, i)
                            if c == '=' or c == ';' then
                                break
                            end
                            i = i + 1
                        end
                        key = s:sub(start, i-1)
                        if not keys[key] then
                            return
                        end
                        start = i + 1
                        if c == ';' then
                            capture[key] = ''
                            i = i + 1
                        else
                            while i <= #s do
                                c = s:sub(i, i)
                                if c == sep_var[oper] then
                                    capture[key] = unescape(s:sub(start, i-1), query)
                                    i = i + 1
                                    start = i
                                    break
                                end
                                if c:match(patt_end[oper]) then
                                    break
                                end
                                i = i + 1
                            end
                        end
                        if c:match(patt_end[oper]) then
                            break
                        end
                    end
                    if k == #ops then
                        capture[key] = unescape(s:sub(start, i-1), query)
                    else
                        local sav = query
                        for j = i, start, -1 do
                            if inner(j, k+1) then
                                capture[key] = unescape(s:sub(start, j-1), sav)
                                return true
                            end
                        end
                    end
                end
            else
                local c = s:sub(i, i)
                if oper == '1' or oper == '+' or oper == c then
                    if c == '#' then
                        query = false
                    end
                    if oper ~= '1' and oper ~= '+' then
                        i = i + 1
                    end
                    local start = i
                    local nvar = 2
                    local varname = op[nvar]
                    while i <= #s do
                        c = s:sub(i, i)
                        if c == sep_var[oper] then
                            capture[varname] = unescape(s:sub(start, i-1), query)
                            if oper == '/' and not op[nvar+1] then
                                break
                            else
                                nvar = nvar + 1
                                varname = op[nvar]
                                if not varname then
                                    return
                                end
                            end
                            start = i + 1
                        elseif c:match(patt_end[oper]) then
                            break
                        end
                        i = i + 1
                    end
                    if k == #ops then
                        capture[varname] = unescape(s:sub(start, i-1), query)
                    else
                        local sav = query
                        for j = i, start, -1 do
                            if inner(j, k+1) then
                                capture[varname] = unescape(s:sub(start, j-1), sav)
                                return true
                            end
                        end
                    end
                end
            end
        end
        if i > #s then
            return true
        end
    end  -- inner

    if inner(1, 1) then
        if #ops == 1 and ops[1][1] == '0' then
            return s
        else
            return capture
        end
    end
end

return matcher(match, compile)
--
-- Copyright (c) 2017-2018 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
