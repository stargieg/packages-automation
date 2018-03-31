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
require("nixio.fs")
local arg1 = arg[1]
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()

if not nixio.fs.access("/etc/config/bacnet_nc") then
	if not luci.sys.exec("touch /etc/config/bacnet_nc") then
		return
	end
end

--if arg1 then
--	m = Map("bacnet_nc_"..arg1, "Bacnet Notification Class", "Bacnet Notification Class Configuration")
--else
m = Map("bacnet_nc", "Bacnet Notification Class", "Bacnet Notification Class Configuration")
--end

s = m:section(TypedSection, "nc", arg1 or 'NC Index')
s.addremove = true
s.anonymous = false
s.template = "cbi/tblsection"

s:option(Flag, "disable", "Disable")
s:option(Value, "name", "NC Name")

sva = s:option(ListValue, "group",  "Gruppe")
local uci = luci.model.uci.cursor()
uci:foreach("bacnet_group", "group",
	function (section)
			sva:value(section.name)
	end)

s:option(Value, "description", "Anzeige Name")
sva = s:option(DynamicList, "recipient",  "Empfaenger", "65535 fuer Broadcast oder net,ip:port z.B. 1,104.13.8.92:47808")

return m

