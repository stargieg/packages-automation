#!/usr/bin/lua

require "uci"
mqtt = require "mosquitto"
json = require "luci.jsonc"

function sub_logger_err(msg)
	local pc=io.popen("logger -p error -t mqtt-sub "..msg)
	if pc then pc:close() end
end

function sub_logger_info(msg)
	local pc=io.popen("logger -p info -t mqtt-sub "..msg)
	if pc then pc:close() end
end

mclient = mqtt.new()
x = uci.cursor()
state = uci.cursor(nil, "/var/state")
dp={}
grp={}

mclient.ON_CONNECT = function()
	for i=0,31 do
		for j=0,7 do
			local groupname="knx_"..i.."_"..j
			local f = io.open("/etc/config/"..groupname,"r")
			if f~=nil then
				io.close(f)
				maingrp = x:get(groupname,"main_group", "Name")
				middlegrp = x:get(groupname,"middle_group", "Name")
				x:foreach(groupname, "grp", function(s)
					local name = groupname.."."..s['.name']
					local comment = s.Name
					local type = s.type
					if not type then
						sub_logger_err("no DPTs "..name.." "..comment)
						return
					end
					topic=maingrp.."/"..middlegrp.."/"..comment
					mclient:subscribe(topic)
					dp[topic] = { config=groupname, section=s['.name'] }
				end)
			end
		end
	end
	mclient:subscribe("homebridge/from/set")
end
mclient.ON_MESSAGE = function(mid, topic, payload)
	if topic and dp[topic] then
		local config = dp[topic].config
		local section = dp[topic].section
		local value = payload
		local name = config.."."..section
		sub_logger_info(name.."/"..value.."/"..topic)
		--arg={ name, value }
		--assert(loadfile("/usr/bin/linknxwritevalue.lua"))(name,value)
		local pc=io.popen("/usr/bin/linknxwritevalue.lua \""..name.."\" \""..value.."\"")
		if pc then pc:close() end
	elseif topic and topic == "homebridge/from/set" then
		local valuejs = json.parse(payload)
		local name = valuejs.name
		local value
		if valuejs.characteristic == "On" then
			if valuejs.value then
				value = "on"
			else 
				value = "off"
			end
		end
		if valuejs.characteristic == "Brightness" then
			value = valuejs.value
		end
		if value then
			sub_logger_info(name.."/"..value.."/"..topic)
			--arg={ name, value }
			--assert(loadfile("/usr/bin/linknxwritevalue.lua"))(name,value)
			local pc=io.popen("/usr/bin/linknxwritevalue.lua \""..name.."\" \""..value.."\"")
			if pc then pc:close() end
		end
	end
end
mhost=x:get("linknx_mqtt", "mqtt", "host")
mport=x:get("linknx_mqtt", "mqtt", "port")
muser=x:get("linknx_mqtt", "mqtt", "user")
mpw=x:get("linknx_mqtt", "mqtt", "pw")
mclient:login_set(muser, mpw)
mclient:connect(mhost, mport)
mclient:loop_forever()
