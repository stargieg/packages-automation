#!/usr/bin/lua

local argv = {}

local io	= require "io"
local sys 	= require("luci.sys")
local uci       = luci.model.uci.cursor()
local uci_state = luci.model.uci.cursor_state()
local nixio	= require "nixio"
local host      = sys.getenv("COLLECTD_HOSTNAME") or "OpenWrt"
local interval  = sys.getenv("COLLECTD_INTERVAL") or "20"
function logger_err(msg)
	os.execute("logger -p error -t linknx-collectd "..msg)
end

function logger_info(msg)
	os.execute("logger -p info -t linknx-collectd "..msg)
end
function logger_std(msg)
	print(msg)
end

while true do
	uci_state:load("linknx_group")
	uci_state:foreach("linknx_group", "group", function(g)
		local pgroup = g.pgroup
		local group = g.name
		if pgroup and group then
			local rt_x, rt_xb, ve_y, lk_y
			--rt_x = math.random(15,25)
			--rt_xb = 23
			--ve_y = math.random(90,100)
			--lk_y = math.random(0,10)
			local a_x = math.random(4,6)
			uci_state:load("linknx_varlist_"..group)
			uci_state:foreach("linknx_varlist_"..group, "pvar", function(s)
				if s.value then
					local name = s.name
					if string.find(name, '_hlk_t_ist_R') then
						rt_x = s.value
					elseif string.find(name, '_ezr_t_soll_R') then
						rt_xb = s.value
					elseif string.find(name, '_hz_y_R') then
						ve_y = s.value
					elseif string.find(name, '_ku_y_R') then
						lk_y = s.value
					end
				end
			end)
			if rt_x and rt_xb and a_x then
				print("PUTVAL "..host.."_"..pgroup.."/ezr-"..group.."/ezr_temperature interval="..interval.." N:"..rt_x..":"..rt_xb..":"..a_x)
			end
			if ve_y and lk_y then
				print("PUTVAL "..host.."_"..pgroup.."/ezr-"..group.."/ezr_valve interval="..interval.." N:"..ve_y..":"..lk_y)
			end
		end
	end)
	sys.exec("sleep "..interval)
end
