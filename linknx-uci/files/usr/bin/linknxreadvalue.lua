#!/usr/bin/lua

require "uci"
nixio = require "nixio"

function readval(txt)
	s:send("<read><object id="..txt.."/></read>\r\n\4")
	ret = s:recv(8192) or ''
	if string.find(ret, "success") then
		ret = string.gsub(ret,'.*success..','')
		ret = string.gsub(ret,'..read.*','')
		print(ret)
	end
end

varname = arg[1]
s = nixio.socket('inet', 'stream', none)
s:connect('localhost','1028')
--s = nixio.socket('unix', 'stream', none)
--s:connect('/var/run/linknx')
readval(varname)
s:close()
