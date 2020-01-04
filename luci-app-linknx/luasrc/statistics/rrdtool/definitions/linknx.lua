-- Copyright 2011 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.


module("luci.statistics.rrdtool.definitions.linknx", package.seeall)

function item()
	return luci.i18n.translate("LINKNX")
end

function rrdargs( graph, plugin, plugin_instance, dtype )
	local uci = luci.model.uci.cursor()
	local config = string.gsub(plugin_instance,"^(.-)%..*$","%1")
	local section = string.gsub(plugin_instance,"^.*%.(.-)$","%1")
	local maingrp = uci:get(config, "main_group", "Name") or "Main"
	local middlegrp = uci:get(config, "middle_group", "Name") or "Middle"
	local subgrp = uci:get(config, section, "Name") or "Sub"
	local comment = config.."."..section.." "..maingrp.."/"..middlegrp.."/"..subgrp
	local dt5xxx = {
		title = "%H: 5.xxx "..comment,
		vlabel = "",
		number_format = "%3.1lf",
		data = {
			types = { "5xxx" },
			options = {
				dt5xx = {
					title= "5.xxx",
					overlay = true,
					color = "0000ff"
				}
			}
		}
	}
	local dt5001 = {
		title = "%H: 5.001 Percent "..comment,
		vlabel = "%",
		number_format = "%3.1lf",
		data = {
			types = { "5001" },
			options = {
				dt5001 = {
					title= "5.001",
					overlay = true,
					color = "ff0000"
				}
			}
		}
	}
	local dt5003 = {
		title = "%H: 5.003 Angle "..comment,
		vlabel = "degree",
		number_format = "%3.1lf degree",
		data = {
			types = { "5003" },
			options = {
				dt5003 = {
					title= "Angle",
					overlay = true,
					color = "0000ff"
				}
			}
		}
	}
	local dt6xxx = {
			title = "%H: 6.xxx "..comment,
			vlabel = "",
			number_format = "%3.1lf",
			data = {
					types = { "6xxx" }, 
					options = { 
							dt6xxx = {
									title= "6.xxx", 
									overlay = true, 
									color = "0000ff"
							} 
					} 
			} 
	}
	local dt7xxx = {
			title = "%H: 7.xxx "..comment,
			vlabel = "",
			number_format = "%3.1lf",
			data = {
					types = { "7xxx" }, 
					options = { 
							dt7xxx = {
									title= "7.xxx", 
									overlay = true, 
									color = "0000ff"
							} 
					} 
			} 
	}
	local dt8xxx = {
			title = "%H: 8.xxx "..comment,
			vlabel = "",
			number_format = "%3.1lf",
			data = {
					types = { "8xxx" }, 
					options = { 
							dt9xxx = {
									title= "8.xxx", 
									overlay = true, 
									color = "0000ff"
							} 
					} 
			} 
	}
	local dt9xxx = {
			title = "%H: 9.xxx "..comment,
			vlabel = "degree",
			number_format = "%3.1lf degree",
			data = {
					types = { "9xxx" }, 
					options = { 
							dt9xxx = {
									title= "9.xxx", 
									overlay = true, 
									color = "0000ff"
							} 
					} 
			} 
	}
	local derive = {
			title = "%H: receive "..comment,
			vlabel = "recv",
			number_format = "%3.1lf count",
			data = {
					types = { "derive" },
					options = {
							derive = {
									title= "derive",
									overlay = true,
									color = "0000ff"
							} 
					} 
			} 
	}

	local types = graph.tree:data_types( plugin, plugin_instance )
	local p = {}
	for _, t in ipairs(types) do
		if t == "5xxx" then
			p[#p+1] = dt5xxx
		end
		if t == "5001" then
			p[#p+1] = dt5001
		end
		if t == "5003" then
			p[#p+1] = dt5003
		end
		if t == "6xxx" then 
				p[#p+1] = dt6xxx
		end
		if t == "7xxx" then 
				p[#p+1] = dt7xxx
		end
		if t == "8xxx" then 
				p[#p+1] = dt8xxx
		end
		if t == "9xxx" then
				p[#p+1] = dt9xxx
		end 
		if t == "derive" then
				p[#p+1] = derive
		end 
	end

	return p
end
