Name
====

lua-resty-chash - consistent hash module for ngx_lua

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Synopsis](#synopsis)
* [Methods](#methods)
    * [new](#new)
    * [count](#count)
    * [add](#add)
    * [init](#init)
    * [get](#get)
    * [items](#items)
    * [delete] (#delete)
* [Installation](#installation)
* [Authors](#authors)
* [Copyright and License](#copyright-and-license)

Status
======

This library is production ready.

Synopsis
========
```lua
    lua_package_path "/path/to/lua-resty-chash/lib/?.lua;;";

    server {
        location /test {
            content_by_lua '
                local gh = require "resty.chash"
                local chash = gh:new()

                -- add a weighted item
                chash:add('192.168.1.1', 1) -- add the '192.168.1.1', weight 1
                chash:add('192.168.1.2', 2) -- add the '192.168.1.2', weight 2
                chash:add('192.168.1.3', 3)  -- add the '192.168.1.3' weight 3
                -- using the above data initialization chash
                chash:init()

                local key = ngx.var.arg_key or "def key"
                local ip = chash:get(key)
                ngx.say("the ip is:", ip)
            ';
        }
    }
```

Methods
=======

[Back to TOC](#table-of-contents)

new
---
`syntax: chash_obj = gh:new(consistent_buckets)`

Create a new chash object.
the `consistent_buckets` is the consistent buckets number. default is 256.

count
---
`syntax: count = chash_obj:count()`

Get the items count.


add
-------
`syntax: chash_obj:add(item, weight)`

Add a weighted item to the chash. 
the `item` must a string.
the `weight` is a number, default is 1.
the sum of all the item's weight must be less then `consistent_buckets`

init
-------
`syntax: chash_obj:init()`

Init of the chash. 
Before using the chash.You must initialize it.

get
-------
`syntax: value = chash_obj:get(key)`
Use chash to get a value, the value is one of the items you added!

the `key` is a string.

items
-------
`syntax: items = chash_obj:items()`
Get all the items as a table.

delete
-------
`syntax: chash_obj:delete(item)`
delete an item from the chash. you must be reinit the chash.


[Back to TOC](#table-of-contents)

Installation
============

You need to compile [ngx_lua](https://github.com/chaoslawful/lua-nginx-module/tags) with your Nginx.

You need to configure
the [lua_package_path](https://github.com/chaoslawful/lua-nginx-module#lua_package_path) directive to
add the path of your `lua-resty-chash` source tree to ngx_lua's Lua module search path, as in

    # nginx.conf
    http {
        lua_package_path "/path/to/lua-resty-chash/lib/?.lua;;";
        ...
    }

and then load the library in Lua:

    local gh = require "resty.chash"

[Back to TOC](#table-of-contents)

Authors
=======

Xiaojie Liu <jie123108@163.com>。

[Back to TOC](#table-of-contents)

Copyright and License
=====================

This module is licensed under the BSD license.

Copyright (C) 2015, by Xiaojie Liu <jie123108@163.com>

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[Back to TOC](#table-of-contents)

