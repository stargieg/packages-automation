--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--
module("luci.controller.bacnet", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/bacnet_dev") then
		return
	end
	local page = entry({"admin", "services", "bacnet_dev"}, cbi("bacnet/bacnet_dev"), "Bacnet Device", 20)
	page.dependent = true
	local page = entry({"admin", "services", "bacnet_av"}, cbi("bacnet/bacnet_av"), "Analog Value", 21)
	page.dependent = true
	local page = entry({"admin", "services", "bacnet_bi"}, cbi("bacnet/bacnet_bi"), "Binary Input", 22)
	page.dependent = true
	local page = entry({"admin", "services", "bacnet_mv"}, cbi("bacnet/bacnet_mv"), "Multisate Value", 23)
	page.dependent = true
	local page = entry({"admin", "services", "bacnet_nc"}, cbi("bacnet/bacnet_nc"), "Notification Class", 24)
	page.dependent = true
	local page = entry({"admin", "services", "bacnettypes"}, cbi("bacnet/types", {autoapply=false}), "Bacnet Types", 25)
	page.dependent = true
	local page = entry({"admin", "services", "bacnetrules"}, cbi("bacnet/rules", {autoapply=false}), "Bacnet Rules", 26)
	page.dependent = true

	entry({"admin", "services", "bacnetgroups"}, cbi("bacnet/groups", {autoapply=false}), "Bacnet Groups", 27)
	local page = entry({"admin", "services", "icinga_mv"}, cbi("bacnet/icinga_mv"), "Icinga MV", 28)
	page.dependent = true
end

