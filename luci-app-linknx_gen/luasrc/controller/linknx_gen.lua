--[[
LuCI - Lua Configuration Interface

Copyright 2012 Patrick Grimm <patrick@lunatiki.de>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

$Id$
]]--
module("luci.controller.linknx_gen", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/linknx_exp") then
		return
	end
	local page = entry({"admin", "services", "linknx_load"}, cbi("linknx/linknx"))
	page.dependent = true
	page.title  = _("linknx Import")
	page.order = 15
	local page = entry({"admin", "services", "linknx_groups"}, cbi("linknx/groups", {autoapply=false}))
	page.dependent = true
	page.title  = _("linknx Gruppen")
	page.order = 16
	local page = entry({"admin", "services", "linknx_varlist"}, cbi("linknx/varlist", {autoapply=false}))
	page.dependent = true
	page.title  = _("linknx Variablenliste")
	page.order = 17
	page.leaf = true
	page.subindex = true
	local page = entry({"admin", "services", "linknx_types"}, cbi("linknx/types", {autoapply=false}))
	page.dependent = true
	page.title  = _("linknx Variablentypen")
	page.order = 18
	local page = entry({"admin", "services", "linknx_rules"}, cbi("linknx/rules", {autoapply=false}))
	page.dependent = true
	page.title  = _("linknx Variablenregeln")
	page.order = 19
	--local page = entry({"admin", "services", "linknx_medialist"}, cbi("linknx/medialist", {autoapply=false}))
	--page.dependent = true
	--page.title  = _("linknx Multimedia")
	--page.order = 20

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

	local page = entry({"linknx", "status"}, alias("linknx", "status", "status"), "Status")
	page.order = 20

	local page  = node("linknx", "status", "status")
	page.target = form("linknx/public_status")
	page.title  = "overview"
	page.order  = 20
	page.i18n   = "admin-core"
	page.setuser  = false
	page.setgroup = false

	entry({"linknx", "status.json"}, call("jsonstatus"))
	local page = entry({"linknx", "statusjson"}, cbi("statusjson"), "linknx json read")
	page.leaf = true
	page.subindex = true
	page.order = 25
	entry({"linknx", "write.json"}, call("jsonswrite"))
	local page = entry({"linknx", "writejson"}, cbi("writejson"), "linknx json write")
	page.leaf = true
	page.subindex = true
	page.order = 25

	if nixio.fs.access("/usr/lib/lua/luci/controller/luci_statistics/linknx_statistics.lua") then
		local page = assign({"linknx", "graph"}, {"admin", "linknx_statistics", "graph"}, "Statistiken")
		page.order = 40
		local page = assign({"linknx", "graph_render"}, {"admin", "linknx_statistics_render", "graph"}, "Statistiken Rendern")
		page.order = 41
	end

end
