--[[

Luci statistics - irq plugin diagram definition
(c) 2008 Freifunk Leipzig / Jo-Philipp Wich <xm@leipzig.freifunk.net>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0
$Id: irq.lua 2276 2008-06-03 23:18:37Z jow $
]]--

module("luci.statistics.rrdtool.definitions.rlt", package.seeall)

function rrdargs( graph, plugin, plugin_instance, dtype )

		Canvas		= "FFFFFF"
		FullRed		= "FF0000"
		FullGreen	= "00E000"
		FullBlue	= "0000FF"
		FullYellow	= "F0A000"
		FullCyan	= "00A0FF"
		FullMagenta	= "A000FF"
		HalfRed		= "F7B7B7"
		HalfGreen	= "B7EFB7"
		HalfBlue	= "B7B7F7"
		HalfYellow	= "F3DFB7"
		HalfCyan	= "B7DFF7"
		HalfMagenta	= "DFB7F7"
		HalfBlueGreen	= "89B3C9"
	--
	-- Feuchte diagram
	--
	local g = { }
	g[#g+1] = {
		title = "Feuchte",
		vlabel = "%",
		number_format = "%5.1lf",
		data = {
			sources = {
				rlt_humidity = { "fzul_x", "fabl_x", "faus_x" }
			},
			options = {
				rlt_humidity__fzul_x = {noarea = true, overlay = true, color = FullGreen, title = "Zul.Feuchte"},
				rlt_humidity__fabl_x = {noarea = true, overlay = true, color = FullBlue, title = "Abl.Feuchte"},
				rlt_humidity__faus_x = {noarea = true, overlay = true, color = FullRed, title = "Aussen.Feuchte"}
			}
		}
	}
	--
	-- Ventil diagram
	--
	g[#g+1] = {
		title = "Ventile",
		vlabel = "%",
		number_format = "%5.1lf",
		data = {
			sources = {
				rlt_valve = { "le_y", "lk_y", "wrg_y" }
			},
			options = {
				rlt_valve__ve_y = {overlay = true, color = FullRed, title = "Heizung"},
				rlt_valve__lk_y = {flip  = true, overlay = true, color = FullBlue, title = "Kuehlung"},
				rlt_valve__wrg_y = {overlay = true, color = FullGreen, title = "Waermerueckgewinnung"}
			}
		}
	}

	--
	-- Temperatur diagram
	--
	g[#g+1] = {
		title = "Temperatur",
		vlabel = "Grad C",
		number_format = "%5.1lf",
		data = {
			sources = {
				rlt_temperature = { "zul_x", "zul_xs", "abl_x", "abl_xs", "a_x"}
			},
			options = {
				rlt_temperature__zul_x = {noarea = true, overlay = true, color = FullGreen, title = "Zul.Temperatur"},
				rlt_temperature__zul_xs = {noarea = true, overlay = true, color = FullCyan, title = "Zul.Sollwert"},
				rlt_temperature__abl_x = {noarea = true, overlay = true, color = FullBlue, title = "Abl.Temperatur"},
				rlt_temperature__abl_xs = {noarea = true, overlay = true, color = HalfBlue, title = "Abl.Sollwert"},
				rlt_temperature__a_x = {noarea = true, overlay = true, color = FullRed, title = "Aussen Temperatur"}
			}
		}
	}
	
	return g
end

