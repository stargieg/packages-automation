#!/usr/bin/lua

require("luci.util")
require("luci.model.uci")
require("luci.sys")
require("nixio")

-- Init state session
local uci_state = luci.model.uci.cursor_state()
local uci = luci.model.uci.cursor()

function lock()
	os.execute("lock -w /var/run/test.lock && lock /var/run/test.lock")
end

function unlock()
	os.execute("lock -u /var/run/test.lock")
end

function logger_err(msg)
	os.execute("logger -p error -t ubus-linknx "..msg)
end

function logger_info(msg)
	os.execute("logger -p info -t ubus-linknx "..msg)
end

function fromESF (s)
	s = s .. '.'        -- ending dot
	s_len = string.len(s)
	local t = {}        -- table to collect fields
	local fieldstart = 1
	repeat
		-- next field is quoted? (start with `.'?)
		if fieldstart == 1 then
			local nexti = string.find(s, '%.')
			table.insert(t, string.sub(s, fieldstart, nexti-1))
			fieldstart = nexti + 1
		else                -- unquoted; find next comma
			local nexti = string.find(s, '%.', fieldstart)
			nextii = nexti + 1
			if nextii > s_len then
				last = string.sub(s, fieldstart, nexti-1)
				last = last..'	'
				last_len = string.len(last)
				fieldstart = 1
				repeat
					local nexti = string.find(last, '	', fieldstart)
					table.insert(t, string.sub(last, fieldstart, nexti-1))
					fieldstart = nexti + 1
				until fieldstart > last_len
				fieldstart = s_len + 1
			else
				table.insert(t, string.sub(s, fieldstart, nexti-1))
			end
			fieldstart = nexti + 1
		end
	until fieldstart > s_len
	return t
end

function find_grp (pvar)
	local ret
	uci:foreach("linknx_group", "group", function(s)
		if s.pgroup then
			if string.find(pvar,s.groupexpr) then
				ret = s.name
			end
		end
	end)
	return ret
end
function find_type (pvar)
	local ret1 = nil
	local ret2 = nil
	local ret3 = nil
	local ret4 = nil
	local prio = 0
	uci:foreach("linknx_exp", "typeexpr", function(s)
		typeexpr = string.gsub(s.typeexpr,"%*","")
		if string.find(pvar,'_stat_pos') then
			ret1 = nil
		elseif string.find(pvar,'_stat_lam') then
			ret1 = nil
		elseif string.find(pvar,'e_a_stat') then
			ret1 = nil
		elseif string.find(pvar,'dim_stat') then
			ret1 = nil
		elseif string.find(pvar,'_dim_') then
			ret1 = nil
		elseif string.find(pvar,typeexpr) then
			if prio < #typeexpr then
				ret1 = s.type
				ret2 = s.comment or ""
				ret3 = s.init or ""
				ret4 = s.event or ""
				prio = #typeexpr
			end
		end
	end)
	return ret1,ret2,ret3,ret4
end



local uci_tagname
local esf_file
uci:foreach("linknx_exp", "daemon", function(s)
	if s.esf then
		if nixio.fs.access(s.esf) then
			esf_file = s.esf
			uci_tagname = s.tagname or "linknx"
		end
	end
end)

local esf
local uci_addr = {}
local uci_adr_int = {}
local uci_pvar = {}
local uci_group = {}
local uci_type = {}
local uci_comment = {}
local uci_initv = {}
local uci_event = {}

if esf_file then
	esf = io.open(esf_file,"r")
	while true do
		line = esf.read(esf)
		if not line then break end
		t = fromESF(line)
		local adr_int
		local addr
		for i, s in ipairs(t) do 
			if i == 3 then
				addr = s
				local fieldstart = 1
				local s_len = string.len(s)
				local nexti = string.find(s, '%/', fieldstart)
				local adr1 = string.sub(s, fieldstart, nexti-1)
				fieldstart = nexti + 1
				nexti = string.find(s, '%/', fieldstart)
				local adr2 = string.sub(s, fieldstart, nexti-1)
				fieldstart = nexti + 1
				local adr3 = string.sub(s, fieldstart, s_len)
				adr_int = adr1 * 2048 + adr2 * 256 + adr3
			elseif i == 4 then
				local grp = nil
				--local grp_type = nil
				--local grp_comment = nil
				--local grp_initv = nil
				--local grp_event = nil
				grp = find_grp(s)
				local grp_type,grp_comment,grp_initv,grp_event = find_type(s)
				if grp and grp_type then
					table.insert(uci_pvar,adr_int.."_"..s)
					table.insert(uci_adr_int,adr_int)
					table.insert(uci_addr,addr)
					table.insert(uci_group,grp)
					table.insert(uci_type,grp_type)
					table.insert(uci_comment,grp_comment)
					table.insert(uci_initv,grp_initv)
					table.insert(uci_event,grp_event)
				else
					if not grp and grp_type then
						logger_err("NO Group: "..s)
					end
					if not grp_type and grp then
						logger_err("NO Type: "..s)
					end
					if not grp_type and not grp then
						logger_err("NO GroupType: "..s)
					end
				end
			end
		end
	end
	for i, s in ipairs(uci_pvar) do 
		local old_pvar = nil
		local old_pvarr
		if not nixio.fs.access('/etc/config/linknx_varlist_'..uci_group[i]) then
				nixio.fs.writefile('/etc/config/linknx_varlist_'..uci_group[i],'')
		end
		uci:foreach("linknx_varlist_"..uci_group[i], "pvar", function(sec)
			if sec.name and uci_adr_int[i] then
				if string.find(sec.name,uci_adr_int[i]) then
					old_pvar = sec.name
					old_pvarr = sec
					--TODO e.g. Name von 1/1/1 geaendert. Löschen und neu anlegen?
					--oder nur warnen?
				end
			end
		end)
		if not old_pvar then
			-- print("N"..s)
			uci:section("linknx_varlist_"..uci_group[i], "pvar", nil, {
				name    =s,
				tagname =uci_tagname,
				addr    =uci_addr[i],
				group   =uci_group[i],
				comment =uci_comment[i],
				initv   =uci_initv[i],
				event   =uci_event[i]
			})
	--	else
	--		print("O"..old_pvar)
		end
		uci:save("linknx_varlist_"..uci_group[i])
		uci:commit("linknx_varlist_"..uci_group[i])
	end
end

