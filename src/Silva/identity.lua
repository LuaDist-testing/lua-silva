
--
-- lua-Silva : <http://fperrad.github.io/lua-Silva/>
--

local modname = string.gsub(..., '%.%w+$', '')
local matcher = require(modname).matcher

local function match (s, patt)
    if s == patt then
        return s
    end
end

return matcher(match)
--
-- Copyright (c) 2017-2018 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
