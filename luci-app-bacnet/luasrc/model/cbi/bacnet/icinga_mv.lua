--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--

require("luci.sys")
require("luci.util")
require("luci.tools.webadmin")
require("luci.fs")
local arg1 = arg[1]
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()
--if not arg1 then
--	return
--end
--if not luci.fs.access("/etc/config/linknx_varlist_"..arg1) then
--	if not luci.sys.exec("touch /etc/config/linknx_varlist_"..arg1) then
--		return
--	end
--end
if not luci.fs.access("/etc/config/bacnet_mv") then
	if not luci.sys.exec("touch /etc/config/bacnet_mv") then
		return
	end
end

if arg1 then
	m = Map("bacnet_mv_"..arg1, "Bacnet Multisate Value", "Bacnet Multisate Value Configuration")
else
	m = Map("bacnet_mv", "Bacnet Multisate Value", "Bacnet Multisate Value Configuration")
end

s = m:section(TypedSection, "mv", arg1 or 'MV Index')
s.addremove = true
s.anonymous = false
--s.anonymous = true
s.template = "cbi/tblsection"

-- s:option(Flag, "disable", "Disable")
-- en.optional = true
s:option(Value, "name", "MV Name")
s:option(Value, "value", "Value")
s:option(Value, "description", "Anzeige Name")
sva = s:option(Value, "hostgroups", "Hostgroups")
sva:value("ddc-modbus")
sva:value("ddc-bacnet")
sva:value("ddc-asi")
sva:value("switche")
sva:value("switche-NG-GS716T")
sva:value("switche-NG-GS110TP")
sva:value("switche-HP1910")
sva:value("server")

sva = s:option(Value, "use", "use")
sva:value("ddc-modbus")
sva:value("ddc-bacnet")
sva:value("ddc-asi")
sva:value("switche")
sva:value("Wago-750-881")
sva:value("Wago-750-830")
sva:value("switche-NG-GS716T")
sva:value("server")

sva = s:option(Value, "parents",  "Parents")
local uci = luci.model.uci.cursor()
uci:foreach("bacnet_mv", "mv",
	function (section)
			sva:value(section.name)
	end)

return m

