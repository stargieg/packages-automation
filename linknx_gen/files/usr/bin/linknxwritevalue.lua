#!/usr/bin/lua

local argv = {}

local io    = require "io"
local uci = require "luci.model.uci"
local nixio = require "nixio"
local s = nixio.socket('unix', 'stream', none)
s:connect('/var/run/linknx.sock')

function writeval(txt,varval)
s:send("<write><object id="..txt.." value="..varval.."/></write>\r\n\4")
end

varname = arg[1]
varval = arg[2]
writeval(varname,varval)
s:close()
