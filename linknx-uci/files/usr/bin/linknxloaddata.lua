#!/usr/bin/lua

require "uci"
nixio = require "nixio"

function logger_err(msg)
	os.execute("logger -p error -t linknxloaddata "..msg)
end

function logger_info(msg)
	os.execute("logger -p info -t linknxloaddata "..msg)
end


function write(varname,addr,type)
		local line
		local init
		init = 'persist'
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

function writerule(id,varname,varval)
	local line
	line="<write>\n<config>\n<rules>\n<rule id="..id..">\n"
	line=line.."<condition type='and'>"
		line=line.."<condition type='script'>"
			line=line.."varname='"..varname.."';"
			line=line.."value=obj(varname);"
			line=line.."os.execute('/usr/bin/linknxmapper.lua '..varname..' '..value);\n"
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
		logger_info("write rule obj "..varname..' '..id..' '..varval)
	end
end

function load_group(group)
	x:foreach(group, "grp", function(s)
		local name = group.."."..s['.name']
		local comment = s.Name
		local addr = s.Address
		local type = s.type
		if not type then
			logger_err("no DPTs "..name.." "..comment)
			return
		end
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
		write(name,addr,type)
		if value then
			writerule(name.."_rule",name,value,type)
		end
	end)
end

logger_info("start")

s = nixio.socket('inet', 'stream', none)
s:connect('localhost','1028')
--s = nixio.socket('unix', 'stream', none)
--s:connect('/var/run/linknx')

x = uci.cursor()
for i=0,31 do
	for j=0,7 do
		local groupname="knx_"..i.."_"..j
		local f = io.open("/etc/config/"..groupname,"r")
		if f~=nil then
			io.close(f)
			load_group(groupname)
		end
	end
end

s:close()

logger_info("end")
