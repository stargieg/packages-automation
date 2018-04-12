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
	os.execute("logger -s -p error -t linknxloaddata "..msg)
end

function logger_info(msg)
	os.execute("logger -s -p info -t linknxloaddata "..msg)
end


function write(varname,addr,dpt)
		local line
		local init
		init = 'persist'
		if dpt == "9.xxx" then
			init = 0
		end
		line = '<write><config><objects>'
		line = line..'<object id="'..varname..'" gad="'..addr..'" flags="crwtuf" type="'..dpt..'" init="'..init..'">"'..varname..'"</object>'
		-- line = line..'<object id="'..varname..'" gad="'..addr..'" flags="ctu" type="'..dpt..'" init="'..init..'">"'..varname..'"</object>'
		line = line..'</objects></config></write>'
		s:send(line.."\r\n")
		s:send("\r\n\4")
		res = s:recv(8192)
		if not res then
			logger_err("write obj no response "..varname)
		elseif not string.find(res, "success") then
			logger_err("write obj "..varname.." not success")
		else
			logger_info("write obj "..varname..":"..addr..":"..dpt..":"..init)
		end
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

function writerule(id,varname,varval,group,dpt)
	local line
	line="<write>\n<config>\n<rules>\n<rule id="..id..">\n"
	line=line.."<condition type='and'>"
		line=line.."<condition type='script'>"
			line=line.."varname='"..varname.."';"
			line=line.."group='"..group.."';"
			line=line.."dpt='"..dpt.."';"
			line=line.."value=obj(varname);"
			line=line.."os.execute('/usr/bin/linknxmapper.lua '..varname..' '..value..' '..group..' '..dpt);\n"
			line=line.."return 1;\n"
		line=line.."</condition>"
		if dpt == "1.001" then
			line=line.."<condition type='object' id='"..varname.."' value='on' trigger='true'>"
			line=line.."</condition>"
			line=line.."<condition type='object' id='"..varname.."' value='off' trigger='true'>"
			line=line.."</condition>"
		else
			line=line.."<condition type='object' id='"..varname.."' value='"..varval.."' trigger='true'>"
			line=line.."</condition>"
		end
	line=line.."</condition>"
	line=line.."<actionlist>\n"
		line=line.."<action type=script>\n"
		line=line.."return;\n"
		line=line.."</action>\n"
	line=line.."</actionlist>\n"
	line=line.."</rule>\n</rules>\n</config></write>\r\n\4"
	s:send(line)
	res = s:recv(8192)
	if not res then
		logger_err("write rule obj no response "..varname)
	elseif not string.find(res, "success") then
		logger_err("write rule obj "..varname.." not success")
	else
		logger_info("write rule obj "..varname..' '..id..' '..varval..' '..group..' '..dpt)
	end
end

function load_group(tagname)
	bacnet_objs = {"ai", "ao", "av", "bi", "bo", "bv", "mi", "mo", "mv"}
	for _,group in pairs(bacnet_objs) do
		logger_info("load "..group)
		uci:foreach("bacnet_"..group, group, function(s)
			if tagname == s.tagname then
				local name = s.name
				local addr = s.addr
				local dpt = s.dpt
				local value = s.value
				if dpt == "1.001" then
					value="on"
				elseif dpt == "5.001" then
					value="0"
				elseif dpt == "5.xxx" then
					value="0"
				elseif dpt == "9.xxx" then
					value="0"
				elseif dpt == "20.102" then
					value="comfort"
				end
				if initv then
					write(name,addr,dpt)
				else
					write(name,addr,dpt)
				end
				if value then
					writerule(name.."_rule",name,value,group,dpt)
				end
			end
		end)
		uci:foreach("bacnet_"..group, group, function(s)
			if tagname == s.tagname then
				local name = s.name
				readval(name)
			end
		end)
	end
end

logger_info("start")

uci:foreach("linknx", "station", function(y)
	logger_info("enable "..y.enable)
	if y.enable and y.enable == "1" then
		logger_info("tagname "..y.tagname)
		load_group(y.tagname)
	end
end)

s:close()

logger_info("end")
