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
	return m
else
	maingrp = uci:get(arg1,"main_group", "Name")
	middlegrp = uci:get(arg1,"middle_group", "Name")	
	m = Map(arg1, arg1, arg1.." "..maingrp.."/"..middlegrp)
	s = m:section(TypedSection, "grp", "KNX groups")
	s.template = "cbi/tblsection"
	sval = s:option(DummyValue, "Value","Value")
	function sval.value(self, section)
		value = self.map:get(section)
		return uci:get_state(arg1,value[".name"],"value") or ""
	end
	s:option(Value, "Address", "Address")
	s:option(Value, "Name", "ETS Name")
	s:option(Value, "type", "type")
	return m
end