#!/usr/bin/lua

require "uci"
mqtt = require "mosquitto"

function logger_err(msg)
	local pc=io.popen("logger -p error -t mqtt-sub "..msg)
	if pc then pc:close() end
end

function logger_info(msg)
	local pc=io.popen("logger -p info -t mqtt-sub "..msg)
	if pc then pc:close() end
end

mclient = mqtt.new()
x = uci.cursor()
state = uci.cursor(nil, "/var/state")
dp={}

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
						logger_err("no DPTs "..name.." "..comment)
						return
					end
					topic=maingrp.."/"..middlegrp.."/"..comment
					mclient:subscribe(topic)
					dp[topic] = { config=groupname, section=s['.name'] }
				end)
			end
		end
	end
end
mclient.ON_MESSAGE = function(mid, topic, payload)
	local config = dp[topic].config
	local section = dp[topic].section
	local value = payload
	local name = config.."."..section
	logger_info(name.."/"..value.."/"..topic.."/"..mid)
	arg={ name, value, mid }
	assert(loadfile("/usr/bin/linknxwritevalue.lua"))(name,value,mid)
end
mclient:connect()
mclient:loop_forever()
