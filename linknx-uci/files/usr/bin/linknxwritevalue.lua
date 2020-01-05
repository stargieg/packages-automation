#!/usr/bin/lua

require "uci"
nixio = require "nixio"

function writeval(txt,varval)
	s:send("<write><object id="..txt.." value="..varval.."/></write>\r\n\4")
end

varname = arg[1] or ""
varval = arg[2] or ""
s = nixio.socket('inet', 'stream', none)
s:connect('localhost','1028')
--s = nixio.socket('unix', 'stream', none)
--s:connect('/var/run/linknx')
writeval(varname,varval)
s:close()
assert(loadfile("/usr/bin/linknxmapper.lua"))(varname,varval)
