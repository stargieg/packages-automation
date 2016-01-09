--[[

Luci statistics - statistics controller module
(c) 2008 Freifunk Leipzig / Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

$Id$

]]--

module("luci.controller.luci_statistics.linknx_statistics", package.seeall)

function index()

	require("nixio.fs")
	require("luci.util")
	require("luci.statistics.datatree")
	require("luci.model.uci")

	local labels = {
		ezr		= _("EZR"),
		rlt		= _("RLT"),
		hk		= _("HK")
	}


	local uci  = luci.model.uci.cursor()
	local vars = luci.http.formvalue(nil, true)
	local span = vars.timespan or nil
	local vhost = vars.host or nil

	--FIXME remove "graph" dep luci.dispatcher.context.path[i]
	--local page = assign({"admin", "linknx_statistics"}, {"admin", "linknx_statistics", "graph"}, "Statistiken")
	--                           Workaround
	local page = assign({"admin", "graph"}, {"admin", "linknx_statistics", "graph"}, "Statistiken")
	page.order  = 85

	local page = entry({ "admin", "linknx_statistics", "graph" }, template("admin_statistics/index"), "Linknx Statistics")
	page.index = true
	page.setuser  = "nobody"
	page.setgroup = "nogroup"

	local page = entry({ "admin", "linknx_statistics_render", "graph" }, call("statistics_index_render"), "Linknx Statistics json")
	page.index = true
	page.setuser  = "nobody"
	page.setgroup = "nogroup"

	local hosts = luci.statistics.datatree.Instance(nil):host_instances()
	local j, host
	for j, host in ipairs( hosts ) do

		local page = entry({ "admin", "linknx_statistics", "graph", host }, template("admin_statistics/index"), host )
		page.i18n = "statistics"
		page.index = true
		page.order = j
		if span then
			page.query = { timespan = span }
		end

		local tree = luci.statistics.datatree.Instance(host)
		local _, plugin, i
		for _, plugin, i in luci.util.vspairs( tree:plugins() ) do

			-- get plugin instances
			local instances = tree:plugin_instances( plugin )

			-- plugin menu entry
			local page = entry(
				{ "admin", "linknx_statistics", "graph", host, plugin },
				call("statistics_render"), labels[plugin]
			)
			page.order = i
			if span then
				page.query = { timespan = span }
			end

			-- if more then one instance is found then generate submenu
			if #instances > 1 then
				local _, inst, k
				for _, inst, k in luci.util.vspairs(instances) do
					-- instance menu entry
					local page = entry(
						{ "admin", "linknx_statistics", "graph", host, plugin, inst },
						call("statistics_render"), inst
					)
					page.order = k
					if span then
						page.query = { timespan = span }
					end
				end
			end
		end
	end
end

function statistics_render()

	require("luci.statistics.rrdtool")
	require("luci.template")
	require("luci.model.uci")

	local vars  = luci.http.formvalue()
	local req   = luci.dispatcher.context.request
	local path  = luci.dispatcher.context.path
	local uci   = luci.model.uci.cursor()
	local spans = luci.util.split( uci:get( "luci_statistics", "collectd_rrdtool", "RRATimespans" ), "%s+", nil, true )
	local span  = vars.timespan or uci:get( "luci_statistics", "rrdtool", "default_timespan" ) or spans[1]

	local is_index = false

	local plugin, instances, host
	local images = { }

	-- find requested host, plugin and instance
	for i, p in ipairs( luci.dispatcher.context.path ) do
		if luci.dispatcher.context.path[i] == "graph" then
			host    = luci.dispatcher.context.path[i+1]
			plugin    = luci.dispatcher.context.path[i+2]
			instances = { luci.dispatcher.context.path[i+3] }
		end
	end
	local opts = { host = host }
	local graph = luci.statistics.rrdtool.Graph( luci.util.parse_units( span ), opts )
	local hosts = graph.tree:host_instances() or { }

	-- deliver image
	if vars.img then
		local l12 = require "luci.ltn12"
		local png = io.open(graph.opts.imgpath .. "/" .. vars.img:gsub("%.+", "."), "r")
		if png then
			luci.http.prepare_content("image/png")
			l12.pump.all(l12.source.file(png), luci.http.write)
		end
		return
	end


	-- no instance requested, find all instances
	if #instances == 0 then
		instances = graph.tree:plugin_instances( plugin )
		is_index = true

	-- index instance requested
	elseif instances[1] == "-" then
		instances[1] = ""
		is_index = true
	end


	-- render graphs
	for i, inst in ipairs( instances ) do
		for i, img in ipairs( graph:render( plugin, inst, is_index ) ) do
			table.insert( images, graph:strippngpath( img ) )
			images[images[#images]] = inst
		end
	end

	-- deliver json image list
	if vars.json then
		local l12 = require "luci.ltn12"
		local http = require "luci.http"
		local json = require "luci.json"
		local el = {}
		for i, img in ipairs(images) do
			el[#el+1] = '/rrdimg/'..img
		end
		http.prepare_content("application/json")
		l12.pump.all(json.Encoder(el):source(), http.write)
		return
	end

	luci.template.render( "public_statistics/graph_linknx", {
		images           = images,
		plugin           = plugin,
		timespans        = spans,
		current_timespan = span,
		is_index         = is_index
	} )
end

function statistics_index_render()
	require("luci.template")
	require("luci.model.uci")
	require("luci.statistics.rrdtool")
	local vars  = luci.http.formvalue()
	local path  = luci.dispatcher.context.path
	local uci   = luci.model.uci.cursor()
	local spans = luci.util.split( uci:get( "luci_statistics", "collectd_rrdtool", "RRATimespans" ), "%s+", nil, true )
	local span  = vars.timespan or uci:get( "luci_statistics", "rrdtool", "default_timespan" ) or spans[1]

	-- find requested host, plugin and instance
	for i, p in ipairs( luci.dispatcher.context.path ) do
		if luci.dispatcher.context.path[i] == "graph" then
			host    = luci.dispatcher.context.path[i+1]
		end
	end
	local opts = { host = host }
	local graph = luci.statistics.rrdtool.Graph( luci.util.parse_units( span ), opts )
	local hosts = graph.tree:host_instances() or { }
	
	luci.template.render("admin_statistics/index", {
		timespans        = spans,
		current_timespan = span,
		hosts            = hosts,
		current_host     = host
	} )
end
