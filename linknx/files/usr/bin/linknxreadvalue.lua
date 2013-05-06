#!/usr/bin/lua

local argv = {}

local io	= require "io"
local uci	= require "luci.model.uci"
local nixio	= require "nixio"
local s		= nixio.socket('unix', 'stream', none)

s:connect('/var/run/linknx.sock')
function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function readval(txt)
	s:send("<read><object id="..txt.."/></read>\r\n\4")
	ret = s:recv(8192) or ''
	if string.find(ret, "success") then
		ret = string.gsub(ret,'.*success..','')
		ret = string.gsub(ret,'..read.*','')
		if string.find(txt, '_hw_') then
			if string.find(ret, '%.') then
				ret = round(ret)
			end
		end
		print(ret)
	elseif string.find(ret, 'read status=.error') then
		print('')
		io.stderr:write(ret)
	else
		print('')
		io.stderr:write(ret)
	end
end

varname = arg[1]
readval(varname)
s:close()
