#!/usr/bin/lua

require "uci"
lxp = require("lxp")

local count = 0
local main_group_name = ""
local main_group_nr = 0
local main_group_start = 0
local middle_group_name = ""
local middle_group_nr = 0
local sub_group_name = ""
local sub_group_nr = 0
callbacks = {
    StartElement = function (parser, name, attributes)
        count = count + 1
        if count == 2 then
            if attributes["RangeStart"] then
                main_group_start = tonumber(attributes["RangeStart"])
                main_group_nr = math.floor(main_group_start/2048)
            end
            if attributes["Name"] then
                main_group_name = attributes["Name"]
            end
        elseif count == 3 then
            if attributes["RangeStart"] then
                middle_group_start = tonumber(attributes["RangeStart"])
                middle_group_nr = math.floor((middle_group_start-main_group_start+1)/256)
                local f = io.open("/etc/config/knx_"..main_group_nr.."_"..middle_group_nr,"r")
                if f~=nil then
                    io.close(f)
                else
                    f = io.open("/etc/config/knx_"..main_group_nr.."_"..middle_group_nr, "w")
                    f:write()
                    f:close()
                end
            end
            if attributes["Name"] then
                middle_group_name = attributes["Name"]
                x:set("knx_"..main_group_nr.."_"..middle_group_nr, "main_group", "grpname")
                x:set("knx_"..main_group_nr.."_"..middle_group_nr, "main_group", "Name", main_group_name)
                x:set("knx_"..main_group_nr.."_"..middle_group_nr, "middle_group", "grpname")
                x:set("knx_"..main_group_nr.."_"..middle_group_nr, "middle_group", "Name", middle_group_name)
            end
        elseif count == 4 then
            if attributes["Address"] then
                string.gsub(attributes["Address"],".*/.*/(.-)$",function(a) sub_group_nr = a end)
                x:set("knx_"..main_group_nr.."_"..middle_group_nr, sub_group_nr, "grp")
                x:set("knx_"..main_group_nr.."_"..middle_group_nr, sub_group_nr, "Address", attributes["Address"])
            end
            if attributes["Name"] then
                sub_group_name = attributes["Name"]
                x:set("knx_"..main_group_nr.."_"..middle_group_nr, sub_group_nr, "Name", attributes["Name"])
            end
            if attributes["DPTs"] then
                local type
                type1=string.gsub(attributes["DPTs"],"^DPST%-(.-)%-.*$","%1")
                type1=tonumber(type1)
                type2=string.gsub(attributes["DPTs"],"^DPST%-.*%-(.-)$","%1")
                type2=tonumber(type2)
                if type1==1 then
                    type="1.001"
                elseif type1==3 then
                    type="3.006"
                    if type2==7 then
                        type="3.007"
                    end
                elseif type1==5 then
                    type="5.xxx"
                    if type2==1 then
                       type="5.001"
                    elseif type2==3 then
                       type="5.003"
                    end
                elseif type1==6 then
                    type="6.xxx"
                elseif type1==7 then
                    type="7.xxx"
                elseif type1==8 then
                    type="8.xxx"
                elseif type1==9 then
                    type="9.xxx"
                elseif type1==10 then
                    type="10.001"
                elseif type1==11 then
                    type="11.001"
                elseif type1==12 then
                    type="12.xxx"
                elseif type1==13 then
                    type="13.xxx"
                elseif type1==14 then
                    type="14.xxx"
                elseif type1==16 then
                    type="16.000"
                    if type2==1 then
                        type="16.001"
                    end
                elseif type1==20 then
                    type="20.102"
                elseif type1==28 then
                    type="28.001"
                elseif type1==29 then
                    type="29.xxx"
                end
                if type then
                    x:set("knx_"..main_group_nr.."_"..middle_group_nr, sub_group_nr, "type", type)
                end
            end
            x:commit("knx_"..main_group_nr.."_"..middle_group_nr)
            nixio.fs.chmod("/etc/config/knx_"..main_group_nr.."_"..middle_group_nr,644)
        end
    end,
    EndElement = function (parser, name, attributes)
        count = count - 1
    end,
}


local xmlfilename = arg[1]
if not xmlfilename then
	print("no file name")
	return
end

local f = io.open(xmlfilename,"r")
if f~=nil then
	io.close(f)
else
	print("can't open file "..xmlfilename)
end

p = lxp.new(callbacks)
x = uci.cursor()

for l in io.lines(xmlfilename) do
    p:parse(l)
    p:parse("\n")
end
p:parse()
p:close()
