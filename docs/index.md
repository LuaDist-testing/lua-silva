
# lua-Silva

---

_your personal string matching expert_

---

## Overview

lua-Silva allows to match a URI against various kind of pattern :
URI Template, shell, Lua regex, PCRE regex, ...

Some of them allow to capture parts of URI.

lua-Silva was inspired by [Mustermann](http://sinatrarb.com/mustermann/)
( a part of Sinatra / Ruby ).

## Status

lua-Silva is in beta stage.

It's developed for Lua 5.1, 5.2 & 5.3.

## Download

lua-Silva source can be downloaded from
[GitHub](http://github.com/fperrad/lua-Silva/releases/).

## Installation

lua-Silva is available via LuaRocks:

```sh
luarocks install lua-silva
```

or manually, with:

```sh
make install
```

## Test

The test suite requires the module
[lua-TestMore](http://fperrad.github.io/lua-TestMore/).

    make test

## Copyright and License

Copyright &copy; 2017 Fran&ccedil;ois Perrad
[![OpenHUB](http://www.openhub.net/accounts/4780/widgets/account_rank.gif)](http://www.openhub.net/accounts/4780?ref=Rank)
[![LinkedIn](http://www.linkedin.com/img/webpromo/btn_liprofile_blue_80x15.gif)](http://www.linkedin.com/in/fperrad)

This library is licensed under the terms of the MIT/X11 license, like Lua itself.
