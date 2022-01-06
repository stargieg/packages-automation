--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.tools.webadmin")
local uci = luci.model.uci.cursor()
local arg1 = arg[1]

function load_group(group,sec)
	maingrp = uci:get(group,"main_group", "Name")
	middlegrp = uci:get(group,"middle_group", "Name")
	dval = sec:option(DummyValue, group)
	dval.href = luci.dispatcher.build_url("admin", "services", "linknx") .. "/"..group
	dval.rawhtml = true
	dval.default = group.." "..maingrp.."/"..middlegrp
end

if not arg1 then
	m = Map("linknx", "linknx Server", "high level functionalities to EIB/KNX installation")
	s = m:section(SimpleSection, "grp", "KNX groups")
	for i=0,31 do
		for j=0,7 do
			local groupname="knx_"..i.."_"..j
			local f = io.open("/etc/config/"..groupname,"r")
			if f~=nil then
				io.close(f)
				load_group(groupname,s)
			end
		end
	end
	s = m:section(NamedSection, "args", "LINKNX deamon")
	--o = s:option(Value, "conf", "xml config file")
	o = s:option(FileUpload, "conf", "xml config file")
	o.placeholder="/etc/linknx.xml"
	o.default="/etc/linknx.xml"
	o.optional = false
	o = s:option(Value, "options", "options")
	o.placeholder="-w --daemon=/tmp/linknx/linknx.log --pid-file=/var/run/linknx.pid"
	o.default="-w --daemon=/tmp/linknx/linknx.log --pid-file=/var/run/linknx.pid"
	o.optional = false

	mq = Map("linknx_mqtt", "linknx MQTT Server", "settings")
	mqs = mq:section(NamedSection, "mqtt", "connection")
	mqs:option(Value, "host", "hostname").datatype = "hostname"
	mqs:option(Value, "port", "port").datatype = "port"
	mqs:option(Value, "user", "user").datatype = "string"
	mqs:option(Value, "pw", "pw").password = true
	return mq,n
else
	maingrp = uci:get(arg1,"main_group", "Name")
	middlegrp = uci:get(arg1,"middle_group", "Name")	
	m = Map(arg1, arg1, arg1.." "..maingrp.."/"..middlegrp)
	s = m:section(TypedSection, "grp", "KNX groups")
	s.template = "cbi/tblsection"
	local dval = s:option(DummyValue, "Value","Value")
	function dval.value(self, section)
		value = self.map:get(section)
		return uci:get_state(arg1,value[".name"],"value") or ""
	end
	function dval.cfgvalue(self, section)
		value = self.map:get(section)
		return uci:get_state(arg1,value[".name"],"value") or ""
	end
	local nval = s:option(Value, "newValue","newValue")
	function nval.cfgvalue(self, section)
		local sec = self.map:get(section)
		return uci:get_state(arg1,sec[".name"],"value") or ""
	end
	function nval.write(self, section, value)
		local sec = self.map:get(section)
		local cvalue = self:cfgvalue(section) or ""
		local varname=arg1.."."..sec[".name"]
		--io.popen("logger -p info -t luciwrite "..varname.." fvalue ".." "..value.." cvalue "..cvalue.." >/dev/null 2>&1 &")
		if value and cvalue~=value then
			--BUG ON knx is faster then this luci cgi. form value is unchanged and uci state has new feedback from knx 
			io.popen("(sleep 2 && /usr/bin/linknxwritevalue.lua "..varname.." "..value.." )>/dev/null 2>&1 &")
			--io.popen("logger -p info -t luciwrite write >/dev/null 2>&1 &")
		end
	end
	s:option(Value, "Address", "Address")
	s:option(Value, "Name", "ETS Name")
	s:option(Value, "type", "type")
	s:option(Flag, "homebridge", "Homebridge")
	local svc = s:option(ListValue, "characteristic", "Characteristic")
	svc:value('')
	svc:value('CurrentTemperature')
	svc:value('Brightness')
	return m
end