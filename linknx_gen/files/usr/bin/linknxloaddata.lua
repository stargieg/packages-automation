#!/usr/bin/lua

require("luci.util")
require("luci.model.uci")
require("luci.sys")
local uci = luci.model.uci.cursor()
local io    = require "io"
local nixio = require "nixio"
local fs    = require "nixio.fs"
local s = nixio.socket('unix', 'stream', none)
s:connect('/var/run/linknx.sock')

function write(varname,addr,type,initv)
		local line
		local init
		--if initv then
		--	init = initv
		--	print(initv)
		--else
			init = 'persist'
			--init = 'request'
		--end
		--if type == "9.xxx" then
		--	init = 0
		-- end
		line = '<write><config><objects>'
		line = line..'<object id="'..varname..'" gad="'..addr..'" flags="crwtuf" type="'..type..'" init="'..init..'">"'..varname..'"</object>'
		-- line = line..'<object id="'..varname..'" gad="'..addr..'" flags="ctu" type="'..type..'" init="'..init..'">"'..varname..'"</object>'
		line = line..'</objects></config></write>'
		s:send(line.."\r\n")
		s:send("\r\n\4")
		res = s:recv(8192)
		if not res then
			logger_err("write obj no response "..varname)
		elseif not string.find(res, "success") then
			logger_err("write obj "..varname.." not success")
		else
			logger_info("write obj "..varname..":"..addr..":"..type..":"..init)
		end
end

function find_type(pvar)
	local ret1 = nil
	local ret2 = nil
	uci:foreach("linknx_exp", "typeexpr", function(s)
		typeexpr = string.gsub(s.typeexpr,"%*","")
		if string.find(pvar,typeexpr) then
			ret1 = s.type
		end
	end)
	if ret1 then
		return ret1
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
		if string.find(res, '_hw_') then
			if string.find(res, '%.') then
				res = round(res)
			end
		end
		logger_info("read obj "..varname..":"..res)
	end

end

function writerule(id,varname,varval,group)
	local line
	line="<write>\n<config>\n<rules>\n<rule id="..id..">\n"
	line=line.."<condition type='and'>"
		line=line.."<condition type='script'>"
			line=line.."varname='"..varname.."';"
			line=line.."group='"..group.."';"
			line=line.."value=obj(varname);"
			line=line.."os.execute('/usr/bin/linknxmapper.lua '..varname..' '..value..' '..group);\n"
			line=line.."return 1;\n"
		line=line.."</condition>"
		line=line.."<condition type='object' id='"..varname.."' value='"..varval.."' trigger='true'>"
		line=line.."</condition>"
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
		logger_info("write rule obj "..varname..' '..id..' '..varval..' '..group)
	end
end

function writemail(id,varname,varval)
	local line
	line=line.."<write><config><rules><rule id="..id..">"
		line=line.."<condition type=or>"
			line=line.."<condition type=object id="..varname.." value="..varval.." trigger='true'>line=line.."
			line=line.."</condition>"
		line=line.."</condition>"
		line=line.."<actionlist>"
		line=line.."<action type=shell-cmd cmd='/usr/bin/linknxmapper.lua "..id.." "..varval.."'/>"
		line=line.."</actionlist>"
	line=line.."</rule></rules></config></write>\r\n\4"
	s:send(line)
	res = s:recv(8192)
	if not res then
		logger_err("write mail obj no response "..varname)
	elseif not string.find(res, "success") then
		logger_err("write mail obj "..varname.." not success")
	else
		logger_info("write mail obj "..varname)
	end
end


function logger_err(msg)
	os.execute("logger -p error -t linknxloaddata "..msg)
end

function logger_info(msg)
	os.execute("logger -p info -t linknxloaddata "..msg)
end

function load_group(tagname)
	uci:foreach("linknx_group", "group", function(s)
			uci:foreach("linknx_varlist_"..s.name, "pvar", function(n)
					if tagname == n.tagname then
						local group = s.name
						local name = n.name
						local addr = n.addr
						local initv = n.initv
						local type = find_type(name)
						local value
						if type == "1.001" then
							value="on"
						elseif type == "5.001" then
							value="0"
						elseif type == "5.xxx" then
							value="0"
						elseif type == "9.xxx" then
							value="0"
						elseif type == "20.102" then
							value="comfort"
						end
						if initv then
							write(name,addr,type,initv)
							value=initv
						--elseif value then
						--	write(name,addr,type,value)
						else
							write(name,addr,type)
						end
						if value then
							writerule(name.."_rule",name,value,group,type)
						end
					end
			end)
	end)
	uci:foreach("linknx_group", "group", function(s)
			uci:foreach("linknx_varlist_"..s.name, "pvar", function(n)
					if tagname == n.tagname then
						local name = n.name
						readval(name)
					end
			end)
	end)
end

logger_info("start")

uci:foreach("linknx_exp", "daemon", function(y)
	load_group(y.tagname)
end)


--uci:foreach("linknx_exp", "rule", function(y)
--	print(y.id)
--	if y.id then
--		writerule(y.id,y.varname,y.value)
--	end
--end)
--uci:foreach("linknx_exp", "mail", function(y)
--	print(y.id)
--	if y.id then
--		writemail(y.id,y.varname,y.value)
--	end
--end)

s:close()

logger_info("end")

