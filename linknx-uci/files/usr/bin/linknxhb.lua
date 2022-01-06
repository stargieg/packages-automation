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
					local valuejs
					if not valuejs and type == "1.001" then
						valuejs=json.stringify({ name = name, service_name = topic, service = "Lightbulb"})
					end
					if not valuejs and type == "5.001" then
						valuejs=json.stringify({ name = name, service_name = topic, service = "Lightbulb"})
					end
					if not valuejs and type == "9.xxx" then
						valuejs=json.stringify({ name = name, service_name = topic, service = "TemperatureSensor"})
					end
					mclient:publish("homebridge/to/add",valuejs)
				end)
			end
		end
	end
end

mclient.ON_PUBLISH = function()
	mclient:disconnect()
end

mhost=x:get("linknx_mqtt", "mqtt", "host")
mport=x:get("linknx_mqtt", "mqtt", "port")
muser=x:get("linknx_mqtt", "mqtt", "user")
mpw=x:get("linknx_mqtt", "mqtt", "pw")
mclient:login_set(muser, mpw)
mclient:connect(mhost, mport)
mclient:loop_forever()
