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
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()

if not nixio.fs.access("/etc/config/modbus") then
	if not luci.sys.exec("touch /etc/config/modbus") then
		return
	end
end

m = Map("modbus", "Modbus Device", "Modbus Device Configuration")

s = m:section(TypedSection, "station", 'Station')
s.addremove = true
s.anonymous = true

s:option(Flag, "enable", "enable")

sva = s:option(Value, "ipaddr", "IP Adresse")

sva = s:option(Value, "port", "TCP Port")
sva:value('502')

sva = s:option(Value, "station_id", "Slave ID")
sva:value('1')
sva:value('255')

s:option(Value, "tagname", "Tag Name benutzt in bacnet objects")

s:option(Value, "modelname", "Model Name")

s:option(Value, "description", "Anzeige Name")

s:option(Value, "location", "Einbau Ort")

s:option(FileUpload, "csv", "Datenpunktliste")

return m

