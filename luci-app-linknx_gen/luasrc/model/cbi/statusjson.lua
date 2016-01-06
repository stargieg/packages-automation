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
require("luci.model.uci")
require("luci.tools.webadmin")
require("luci.statistics.rrdtool")
require("nixio")

local larg = arg
local larg0 = arg[0]
local larg1 = arg[1]
local larg2 = arg[2]
local larg3 = arg[3]
if not larg1 then
	return
end

function readval(txt)
	uds:send("<read><object id="..txt.."/></read>\r\n\4")
	ret = uds:recv(8192) or ''
	if string.find(ret, "success") then
		ret = string.gsub(ret,'.*success..','')
		ret = string.gsub(ret,'..read.*','')
		if string.find(txt, '_hw_') then
			if string.find(ret, '%.') then
				ret = round(ret)
			end
		end
		if string.find(ret, 'on') then
			ret = '1'
		elseif string.find(ret, 'off') then
			ret = '0'
		end
		if string.find(txt, 'stat_dw_1') then
			local retbit=tonumber(ret) or 1
			local ret_text=''
			if retbit >= 128 then
				ret_text=ret_text.." Frostalarm"
				retbit=retbit-128
			end
			if retbit >= 64 then
				ret_text=ret_text.." Totzone"
				retbit=retbit-64
			end
			if retbit >= 32 then
				ret_text=ret_text.." Heizen"
				retbit=retbit-32
			else
				ret_text=ret_text.." Kühlen"
			end
			if retbit >= 16 then
				ret_text=ret_text.." gesperrt"
				retbit=retbit-16
			end
			if retbit >= 8 then
				ret_text=ret_text.." Frost"
				retbit=retbit-8
			end
			if retbit >= 4 then
				ret_text=ret_text.." Nacht"
				retbit=retbit-4
			end
			if retbit >= 2 then
				ret_text=ret_text.." Standby"
				retbit=retbit-2
			end
			if retbit >= 1 then
			        ret_text=ret_text.." Komfort"
			end
         		ret=ret_text
		end
		if string.find(txt, 'stat_dw_2') then
			local retbit=tonumber(ret) or 1
			local ret_text=ret
			if retbit >= 128 then
				ret_text=ret_text.." Taupunktbetrieb"
				retbit=retbit-128
			end
			if retbit >= 64 then
				ret_text=ret_text.." Hitzeschutz"
				retbit=retbit-64
			end
			if retbit >= 32 then
				ret_text=ret_text.." Zusatzstufe"
				retbit=retbit-32
			end
			if retbit >= 16 then
				ret_text=ret_text.." Fensterkontakt"
				retbit=retbit-16
			end
			if retbit >= 8 then
				ret_text=ret_text.." Präsenztaste"
				retbit=retbit-8
			end
			if retbit >= 4 then
				ret_text=ret_text.." Präsenzmelder"
				retbit=retbit-4
			end
			if retbit >= 2 then
				ret_text=ret_text.." Komfortverlängerung"
				retbit=retbit-2
			end
			if retbit >= 1 then
			        ret_text=ret_text.." Normal"
			else
				ret_text=ret_text.." Zwangs-Betriebsmodus"
			end
         		ret=ret_text
		end
		return ret
	elseif string.find(ret, 'read status=.error') then
		return '1'
	else
		return '2'
	end
end

function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local sys = require "luci.sys"
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()
local util = require "luci.util"
local http = require "luci.http"
local json = require "luci.json"
local ltn12 = require "luci.ltn12"
local version = require "luci.version"
local webadmin = require "luci.tools.webadmin"

local apgroup = {}
local apgroup_i = 0
local main = {}
local el = {}
local first1 = true
local first2 = true
local first3 = true

if larg1 == 'structure' then
	uci:foreach("linknx_group", "group", function(s)
		if not s.pgroup then
			local pgroupname = s.name
			el[#el+1] = {}
			el[#el].name = pgroupname
			el[#el].comment = s.comment
			uci:foreach("linknx_group", "group", function(t)
				if t.pgroup == pgroupname then
					el[#el+1] = {}
					el[#el].name = t.name
					el[#el].room = t.name
					el[#el].stage = t.pgroup
					el[#el].text = t.comment
					el[#el].statlist = {}
					local host = uci:get( "luci_statistics", "collectd", "Hostname" ) or luci.sys.hostname()
					host = host..'_'..t.pgroup
					local plugin = "ezr"
					local inst = t.name
					local spans = luci.util.split( uci:get( "luci_statistics", "collectd_rrdtool", "RRATimespans" ), "%s+", nil, true )
					for i, span in ipairs( spans ) do
						local opts = { host = host }
						local graph = luci.statistics.rrdtool.Graph( luci.util.parse_units( span ), opts )
						local hosts = graph.tree:host_instances()
						local is_index = false
						local images = { }
						for i, img in ipairs( graph:render( plugin, inst, is_index ) ) do
							table.insert( images, graph:strippngpath( img ) )
							images[images[#images]] = inst
						end
						-- deliver json image list
						for i, img in ipairs(images) do
							local imgurl = luci.dispatcher.build_url("linknx", "graph", plugin).."?img="..img.."&host="..host
							local statimg = {title = "Title1" , html = imgurl}
							el[#el].statlist[#el[#el].statlist+1] = statimg
						end
					end
				end
			end)
		end
	end)
elseif larg1 == 'structure2' then
	el[#el+1] = {}
	el[#el].id = 'root'
	el[#el].text = 'Linknx Sink'
	el[#el].cls = 'launchscreen'
	el[#el].items = {}
	uci:foreach("linknx_group", "group", function(s)
		if not s.pgroup then
			local pgroupname = s.name
			local items1 = {}
			uci:foreach("linknx_group", "group", function(t)
				if t.pgroup == pgroupname then
					local items2 = {}
					items2.view = 'room'
					items2.text = t.comment
					items2.leaf = 1
					items2.id = t.name
					items1[#items1+1] = items2
				end
			end)
			local items = {}
			items.id = pgroupname
			items.text = s.comment
			items.view = 'stage'
			items.cls = 'launchscreen'
			items.items = items1
			el[#el].items[#el[#el].items+1] = items
		end
	end)
elseif larg1 == 'almlist' then
	uci:foreach("linknx_group", "group", function(g)
		uci_state:load("linknx_varlist_"..g.name)
		uci_state:foreach("linknx_varlist_"..g.name, "pvar", function(s)
			if s.event=='alarm' and s.ontime then
				if tonumber(s.offtime) == 0 or s.ack=="unack" then
					el[#el+1] = {}
					el[#el].varName = s.name
					el[#el].value = s.value or '0'
					el[#el].group = s.group
					el[#el].commentName = s.comment
					el[#el].onTime = s.ontime
					el[#el].offTime = s.offtime
					el[#el].ackTime = s.acktime
					el[#el].lastTime = s.lasttime
					el[#el].ack = s.ack
				end
			end
		end)
	end)
else
	local group = larg1
	local socket_tagnames = {}
	local socket_tagnames_i = 1
	local has_hist = 0
	uci:foreach("linknx_exp", "socket", function(s)
		if s.cmd then
			socket_tagnames[socket_tagnames_i] = s.tagname
			socket_tagnames_i = socket_tagnames_i+1
		end
	end)

	local nixio	= require "nixio"
	uds = nixio.socket('unix', 'stream', none)
	if uds:connect('/var/run/linknx.sock') then
		has_xmlsocket = true
	end
	
	local linknx_tagnames = {}
	local linknx_tagnames_i = 1
	uci:foreach("linknx_exp", "daemon", function(s)
		if s.esf then
			if nixio.fs.access(s.esf) then
				linknx_tagnames[linknx_tagnames_i] = s.tagname
				linknx_tagnames_i = linknx_tagnames_i+1
			end
		end
	end)

	uci_state:foreach("linknx_varlist_"..group, "pvar", function(s)
		if s.log == 1 then
			has_hist = true
		end
		if larg2 then
			if string.find(s.name, larg2) then
				if larg3 then
					if string.find(s.name, larg3) then
						el[#el+1] = {}
						el[#el].label = s.comment
						el[#el].id = s.name
						el[#el].group = s.group
						el[#el].tagname = s.tagname
						el[#el].addr = s.addr
						if s.value then
							el[#el].value = s.value
						else
							for i, ss in ipairs(linknx_tagnames) do
								if ss == s.tagname then
									el[#el].value = has_xmlsocket and readval(s.name) or s.value or '0'
									uci_state:set('linknx_varlist_'..group,s[".name"],'value',el[#el].value)
								end
							end
						end
						if s.addr == 'medialist.radio' then
							local options = {}
							uci:foreach("linknx_medialist", "radio", function(r)
								if r.name then
									options[#options+1] = {}
									options[#options].value = r.name
									options[#options].text = r.comment
								end
							end)
							if #options > 0 then
								el[#el].options = options
							end
						end
					end
				else
					el[#el+1] = {}
					el[#el].label = s.comment
					el[#el].id = s.name
					el[#el].group = s.group
					el[#el].tagname = s.tagname
					el[#el].addr = s.addr
					if s.value then
						el[#el].value = s.value
					else
						for i, ss in ipairs(linknx_tagnames) do
							if ss == s.tagname then
								el[#el].value = has_xmlsocket and readval(s.name) or s.value or '0'
								uci_state:set('linknx_varlist_'..group,s[".name"],'value',el[#el].value)
							end
						end
					end
					if s.addr == 'medialist.radio' then
						local options = {}
						uci:foreach("linknx_medialist", "radio", function(r)
							if r.name then
								options[#options+1] = {}
								options[#options].value = r.name
								options[#options].text = r.comment
							end
						end)
						if #options > 0 then
							el[#el].options = options
						end
					end
				end
			end
		else
			el[#el+1] = {}
			el[#el].label = s.comment
			el[#el].id = s.name
			el[#el].group = s.group
			el[#el].tagname = s.tagname
			el[#el].addr = s.addr
			if s.value then
				el[#el].value = s.value
			else
				for i, ss in ipairs(linknx_tagnames) do
					if ss == s.tagname then
						el[#el].value = has_xmlsocket and readval(s.name) or '0'
						uci_state:set('linknx_varlist_'..group,s[".name"],'value',el[#el].value)
					end
				end
			end
			if s.addr == 'medialist.radio' then
				local options = {}
				options[#options+1] = {}
				options[#options].value = 'none'
				options[#options].text = 'Off'
				uci:foreach("linknx_medialist", "radio", function(r)
					if r.name then
						options[#options+1] = {}
						options[#options].value = r.name
						options[#options].text = r.comment
					end
				end)
				if #options > 0 then
					el[#el].options = options
				end
			end
		end
	end)
	if has_hist then
		local pgroup
		uci:foreach("linknx_group", "group", function(g)
			if group == g.name then
				pgroup = g.pgroup
			end
		end)
		local plugin = "ezr"
		local host = uci:get( "luci_statistics", "collectd", "Hostname" ) or luci.sys.hostname()
		host = host..'_'..pgroup
		local inst = group
		el[#el+1] = {}
		el[#el].title = 'EZR Trend'
		el[#el].id = "hist_"..plugin.."_"..group
		el[#el].group = group
		local items = {}
		local spans = luci.util.split( uci:get( "luci_statistics", "collectd_rrdtool", "RRATimespans" ), "%s+", nil, true )
		for i, span in ipairs( spans ) do
			local opts = { host = host }
			local graph = luci.statistics.rrdtool.Graph( luci.util.parse_units( span ), opts )
			local hosts = graph.tree:host_instances()
			local is_index = false
			local items1 = {}
			items[#items+1]= {}
			items[#items].title = span
			items[#items].id = "hist_"..plugin.."_"..group.."_"..span
			for i, img in ipairs( graph:render( plugin, inst, is_index ) ) do
				local imgurl = '/rrdimg/'..graph:strippngpath( img )
				items1[#items1+1] = {}
				items1[#items1].src = imgurl
			end
			items[#items].items = items1
		end
		el[#el].items = items
	end
	if has_xmlsocket then
		uds:close()
	end
	uci_state:save('linknx_varlist_'..group)
end

--if has_xmlsocket then
--	uds:close()
--end

http.prepare_content("application/json")
ltn12.pump.all(json.Encoder(el):source(), http.write)

