--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--
module("luci.controller.linknx", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/linknx_exp") then
		return
	end
	local page = entry({"admin", "services", "linknx_load"}, cbi("linknx/linknx"), "linknx import", 12)
	page.dependent = true
	local page = entry({"admin", "services", "linknx_groups"}, cbi("linknx/groups", {autoapply=false}), "Groups", 13)
	page.dependent = true
	local page = entry({"admin", "services", "linknx_varlist"}, cbi("linknx/varlist", {autoapply=false}), "Variablenliste", 14)
	page.leaf = true
	page.subindex = true
	local page = entry({"admin", "services", "linknx_types"}, cbi("linknx/types", {autoapply=false}), "linknx Types", 15)
	page.dependent = true
	local page = entry({"admin", "services", "linknx_rules"}, cbi("linknx/rules", {autoapply=false}), "linknx Rules", 16)
	page.dependent = true
	local page = entry({"admin", "services", "linknx_medialist"}, cbi("linknx/medialist", {autoapply=false}), "Media Listen", 17)
	page.dependent = true

	local page  = node()
	page.lock   = true
	page.target = alias("linknx")
	page.subindex = true
	page.index = false

	local page    = node("linknx")
	page.title    = "linknx"
	page.target   = alias("linknx", "index")
	page.order    = 5
	page.setuser  = "nobody"
	page.setgroup = "nogroup"
	page.i18n     = "linknx"
	page.index    = true

	local page  = node("linknx", "index")
	page.target = template("linknx/index")
	page.title  = "Übersicht"
	page.order  = 10
	page.indexignore = true

	entry({"linknx", "status"}, alias("linknx", "status", "status"), "Status", 20)

	local page  = node("linknx", "status", "status")
	page.target = form("linknx/public_status")
	page.title  = "overview"
	page.order  = 20
	page.i18n   = "admin-core"
	page.setuser  = false
	page.setgroup = false

	entry({"linknx", "status.json"}, call("jsonstatus"))
	local page = entry({"linknx", "statusjson"}, cbi("statusjson"), "linknx json download",25)
	page.leaf = true
	page.subindex = true
	entry({"linknx", "write.json"}, call("jsonswrite"))
	local page = entry({"linknx", "writejson"}, cbi("writejson"), "linknx json write",25)
	page.leaf = true
	page.subindex = true

	if nixio.fs.access("/usr/lib/lua/luci/controller/luci_statistics/linknx_statistics.lua") then
		assign({"linknx", "graph"}, {"admin", "linknx_statistics", "graph"}, "Statistiken", 40)
		assign({"linknx", "graph_render"}, {"admin", "linknx_statistics_render", "graph"}, "Statistiken Rendern", 40)
	end

end


