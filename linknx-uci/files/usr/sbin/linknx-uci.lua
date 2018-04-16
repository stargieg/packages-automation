#!/usr/bin/lua

require("luci.util")
require("luci.model.uci")
require("luci.sys")
local uci = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()
local io    = require "io"
local nixio = require "nixio"
local fs    = require "nixio.fs"
local s = nixio.socket('unix', 'stream', none)
s:connect('/var/run/linknx')


function logger_err(msg)
	nixio.syslog("error",msg)
end

function logger_info(msg)
	nixio.syslog("info",msg)
end

function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function readval(varname)
	s:send("<read><object id="..varname.."/></read>\r\n\4")
	res = s:recv(8192) or ''
	if not res then
		logger_err("read obj no response "..varname)
	elseif not string.find(res, "success") then
		logger_err("read obj "..varname.." not success")
	else
		res = string.gsub(res,'.*success..','')
		res = string.gsub(res,'..read.*','')
		logger_info("read obj "..varname..":"..res)
	end
end

function write_linknx(lsock,name,value,dpt)
	logger_info("write_linknx "..name.." new value "..value)
	if dpt == "1.001" then
		value = tonumber(value)
		if value > 0 then
			value="on"
		else
			value="off"
		end
	elseif dpt == "3.007" then
		value = tonumber(value)
		if value == 1 then
			value = 'up'
		elseif value == 2 then
			value = 'down'
		else
			value = 'stop'
		end
	end
	rets=lsock:send("<write><object id="..name.." value="..value.."/></write>\r\n\4")
	return rets
end

function write_group(group,tagname)
	local uci_commit = 0
	uci:load("bacnet_"..group)
	uci:foreach("bacnet_"..group, group, function(s)
		if tagname == s.tagname and s.write and s.dpt then
			logger_info("write_group "..s.name.." new value "..s.value)
			if not lsock then
				lsock = nixio.socket('unix', 'stream', none)
			end
			lsock:connect('/var/run/linknx')
			ret = write_linknx(lsock,s.name,s.value,s.dpt)
			uci:set('bacnet_'..group,s[".name"],'fb_value',s.value)
			uci:delete('bacnet_'..group,s[".name"],'write')
			uci_commit = 1
		end
	end)
	if lsock then
		lsock:close()
		lsock = nil
	end
	if uci_commit == 1 then
		uci:commit('bacnet_'..group)
	end
end

function load_group(tagname)
	local modified_t = {}
	local modified_f = {}
	local bacnet_objs = {"ai", "ao", "av", "bi", "bo", "bv", "mi", "mo", "mv"}
	while true do
		for _,group in pairs(bacnet_objs) do
			local modified = fs.stat("/etc/config/bacnet_"..group,"mtime")
			if not modified then
				logger_err("load /etc/config/bacnet_"..group.." file not found")
				break
			end
			if not modified_t[group] or modified_t[group] < modified then
				modified_t[group] = modified
				modified_f[group] = true
			end
		end
		for _,group in pairs(bacnet_objs) do
			if modified_f[group] then
				logger_info("load "..group.." new mtime "..os.date("%c", modified_t[group]))
				write_group(group,tagname)
				modified_f[group] = nil
			end
		end
		--nixio.nanosleep (seconds, nanoseconds)
		nixio.nanosleep(0,500)
	end
end

logger_info("start")

uci:foreach("linknx", "station", function(y)
	logger_info("enable "..y.enable)
	if y.enable and y.enable == "1" and y.tagname then
		logger_info("tagname "..y.tagname)
		load_group(y.tagname)
	end
end)

s:close()

logger_info("end")
