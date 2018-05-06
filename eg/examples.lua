local Silva = require 'Silva'

local matcher = Silva('/index.html', 'identity')
print(matcher('/index.html'))  --> /index.html

local matcher = Silva('/%w+%.html', 'lua')
print(matcher('/lua.html'))  --> /lua.html

local matcher = Silva('/foo/(%w+)', 'lua')
local capture = matcher('/foo/bar')
print(capture[1]) --> bar

local matcher = Silva('/\\w+\\.html', 'pcre')
print(matcher('/lua.html'))  --> /lua.html

local matcher = Silva('/foo/(\\w+)', 'pcre')
local capture = matcher('/foo/bar')
print(capture[1]) --> bar

local matcher = Silva('/foo/{var}', 'template')
local capture = matcher('/foo/bar')
print(capture.var) --> bar

local matcher = Silva('/foo/{path}{?query,number}')
local capture = matcher('/foo/bar?number=42&query=baz')
print(capture.path, capture.number, capture.query) --> bar   42    baz

local matcher = Silva('/?*.html', 'shell')
print(matcher('/shell.html'))  --> /shell.html

local matcher = Silva('/[Ff]oo[1-9][0-9]', 'shell')
print(matcher('/foo42'))  --> /foo42

