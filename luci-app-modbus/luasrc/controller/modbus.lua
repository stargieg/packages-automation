--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--
module("luci.controller.modbus", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/modbus") then
		return
	end
	local page = entry({"admin", "services", "modbus"}, cbi("modbus"), "Modbus Device", 20)
	page.dependent = true
end

