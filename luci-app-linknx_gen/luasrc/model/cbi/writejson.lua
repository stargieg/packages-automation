--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

local sys = require("luci.sys")
local http = require "luci.http"
local json = require "luci.json"
local ltn12 = require "luci.ltn12"
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()
local nixio = require "nixio"

local el = {}
local el_i = 0


function write_uci(txt,varval)
	uci:foreach("linknx_group", "group", function(g)
		uci_state:load("linknx_varlist_"..g.name)
		uci_state:foreach("linknx_varlist_"..g.name, "pvar", function(s)
			if s.name==txt then
				sys.exec("/usr/bin/logger -p info -t writejson_uci var:"..txt.." val:"..varval.." : "..g.name.."\n")
				uci_state:set('linknx_varlist_'..g.name,s[".name"],'value',varval)
			end
		end)
		uci_state:save('linknx_varlist_'..g.name)
	end)
end

function write_uci_group(txt,varval,group)
	uci_state:load("linknx_varlist_"..group)
	uci_state:foreach("linknx_varlist_"..group, "pvar", function(s)
		if s.name==txt then
			sys.exec("/usr/bin/logger -p info -t writejson_uci_group var:"..s[".name"].." val:"..varval.." : "..group.."\n")
			uci_state:set('linknx_varlist_'..group,s[".name"],'value',varval)
		end
	end)
	uci_state:save('linknx_varlist_'..group)
end

function write_uci_group_alm(name,group,acktime,ack)
	uci_state:load("linknx_varlist_"..group)
	uci_state:foreach("linknx_varlist_"..group, "pvar", function(s)
		if s.name==name then
			if ack=="ack" then
				uci_state:set('linknx_varlist_'..group,s[".name"],'acktime',acktime)
			else
				uci_state:set('linknx_varlist_'..group,s[".name"],'acktime','0')
			end
			uci_state:set('linknx_varlist_'..group,s[".name"],'ack',ack)
		end
	end)
	uci_state:save('linknx_varlist_'..group)
end


function write_linknx(txt,varval)
	rets=s:send("<write><object id="..txt.." value="..varval.."/></write>\r\n\4")
end

--f=SimpleForm("writejson", "writejson", "")
--pdp = f:field(Value, "pdp", "pdp")
--pdp.forcewrite = true
--function pdp.parse(self, section)
--	local fvalue = "1"
--	if self.forcewrite then
--		self:write(section, fvalue)
--	end
--end

--function pdp.write(self, section, value)
local name = luci.http.formvalue('cbid.writejson.1.name')
local value = luci.http.formvalue('cbid.writejson.1.value')
local group = luci.http.formvalue('cbid.writejson.1.group')
local tagname = luci.http.formvalue('cbid.writejson.1.tagname')
--local comment = luci.http.formvalue('cbid.writejson.1.comment')
--local ontime = luci.http.formvalue('cbid.writejson.1.ontime')
--local offtime = luci.http.formvalue('cbid.writejson.1.offtime')
local acktime = luci.http.formvalue('cbid.writejson.1.acktime')
--local lasttime = luci.http.formvalue('cbid.writejson.1.lasttime')
local ack = luci.http.formvalue('cbid.writejson.1.ack')
local addr
if name and value and group and tagname then
	if tagname == 'suco-sound' then
		uci_state:foreach("linknx_varlist_"..group, "pvar", function(s)
			if s.name == name then
				sys.exec("/usr/bin/logger -p info -t writejson var:"..name.." val:"..value.." : "..group.."\n")
				addr = uci:get('linknx_varlist_'..group,s[".name"],'addr')
			end
		end)
		if addr then
			sys.exec("/usr/bin/logger -p info -t writejsonsocket var:"..name.." val:"..value.." : "..group.."\n")
			--sys.exec("echo 'Master 10' | nc suco.olsr 9999")
			sys.exec("echo '"..addr.." "..value.."%' | nc suco.olsr 9999")
			el_i = el_i + 1
			el[el_i] = {}
			el[el_i].id = name
			el[el_i].value = value
			write_uci_group(name,value,group)
		end
	elseif tagname == 'linknx' then
		sys.exec("/usr/bin/logger -p info -t writejsonlinknx var:"..name.." val:"..value.." : "..group.."\n")
		el_i = el_i + 1
		el[el_i] = {}
		el[el_i].id = name
		el[el_i].value = value
		s = nixio.socket('unix', 'stream', none)
		s:connect('/var/run/linknx.sock')
		write_linknx(name,value)
		s:close()
		if acktime and ack then
			write_uci_group(name,value,group,acktime,ack)
		else
			write_uci_group(name,value,group)
		end
	end
elseif name and group and acktime and ack then
	sys.exec("/usr/bin/logger -p info -t writejsonalm var:"..name.." : "..group.." : "..acktime.." : "..ack.."\n")
	write_uci_group_alm(name,group,acktime,ack)
	el_i = el_i + 1
	el[el_i] = {}
end

http.prepare_content("application/json")
ltn12.pump.all(json.Encoder(el):source(), http.write)
--end


--return f

