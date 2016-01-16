#!/usr/bin/lua

local argv = {}

local io    = require "io"
local uci = require "luci.model.uci"
local nixio = require "nixio"
-- s = nixio.socket('unix', 'stream', none)
-- s:connect('/var/run/linknx')
local sendcounter = 0

function writeval(txt,varval)
	print(txt..' '..varval)
	if not s then
		s = nixio.socket('unix', 'stream', none)
		s:connect('/var/run/linknx')
		s:send("<write>")
	end
	--s:send("<write><object id="..txt.." value="..varval.."/></write>\r\n\4")
	s:send("<object id="..txt.." value="..varval.."/>")
	--s:close()
	sendcounter = sendcounter + 1
	if sendcounter >= 15 then
		s:send("</write>\r\n\4")
		sleep(1)
		sendcounter = 0
	s:close()
	s = nil
	end
	--end
end

local clock = os.clock
function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

varnames = {
	"2191_bel_de_29_hw_R103",
	"2231_bel_de_37_hw_R103",
	"2196_bel_de_30_hw_R103",
	"2236_bel_de_38_hw_R103",
	"2201_bel_de_31_hw_R103",
	"2241_bel_de_39_hw_R103",
	"2206_bel_de_32_hw_R103",
	"2246_bel_de_40_hw_R103",
	"2211_bel_de_33_hw_R103",
	"2251_bel_de_41_hw_R103",
	"2216_bel_de_34_hw_R103",
	"2256_bel_de_42_hw_R103",
	"2221_bel_de_35_hw_R103",
	"2261_bel_de_43_hw_R103",
	"2226_bel_de_36_hw_R103"
}


up_down = {}
for i,v in ipairs(varnames) do
    up_down[v] = 'up'
    print('updown:'..v..' '..up_down[v]..' ')
end

startval=0
values = {}
for i,v in ipairs(varnames) do
    startval = startval + 2
    values[v] = startval
    print('startval:'..v..' '..up_down[v]..' '..values[v])
end


local i = 1
while i do
	if i == 200 then break end
	print(i)
	i = i + 1
	for j,v in ipairs(varnames) do
		writeval(v,values[v])
		if values[v] >= 32 then
			up_down[v] = 'down'
		end
		if up_down[v] == 'down' then
			values[v] = values[v] - 2
		end

		if up_down[v] == 'up' then
			values[v] = values[v] + 2
		end
		if values[v] <= 2 then
			up_down[v] = 'up'
		end
	end
	--sleep(1)
end
s:close()

