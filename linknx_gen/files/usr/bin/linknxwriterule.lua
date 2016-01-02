#!/usr/bin/lua

local io    = require "io"
local uci = require "luci.model.uci"
local x = uci.cursor()
local nixio = require "nixio"
local s = nixio.socket('unix', 'stream', none)
s:connect('/var/run/linknx.sock')

function writerule(id,varname,varval)
	s:send("<write><config><rules><rule id="..id.."><condition type=or><condition type=object id="..varname.." value="..varval.." trigger='true'></condition></condition><actionlist><action type=shell-cmd cmd='/etc/linknx/linknxwrapper.sh "..id.." "..varval.."'/></actionlist></rule></rules></config></write>\n\4")
	print(s:recv(8192))
end
function writemail(id,varname,varval)
	s:send("<write><config><rules><rule id="..id.."><condition type=or><condition type=object id="..varname.." value="..varval.." trigger='true'></condition></condition><actionlist><action type=shell-cmd cmd='/etc/linknx/linknxmail.sh "..id.." "..varval.."'/></actionlist></rule></rules></config></write>\n\4")
	print(s:recv(8192))
end



x:foreach("linknx_exp", "rule", function(y)
	print(y.id)
	if y.id then
		writerule(y.id,y.varname,y.value)
	end
end)

x:foreach("linknx_exp", "mail", function(y)
	print(y.id)
	if y.id then
		writemail(y.id,y.varname,y.value)
	end
end)

s:close()
