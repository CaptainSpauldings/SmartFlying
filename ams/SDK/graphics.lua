--  AMS an Advanced Library Package for FlyWithLua
--  Copyright (C) 2020 Pasquale Croce
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <https://www.gnu.org/licenses/>.
--

-- Lua integration for XPLMGraphics.h (incomplete)

require("ams.core.kernel")
local ffi = require("ffi")
local XPLM = require("ams.SDK.XPLM")

ffi.cdef[[
	void XPLMWorldToLocal(
		double 		inLatitude,
		double 		inLongitude,
		double 		inAltitude,
		double * 	outX,
		double * 	outY,
		double * 	outZ
	)
]]

ffi.cdef[[
	void XPLMLocalToWorld(
		double 		inX,
		double 		inY,
		double 		inZ,
		double * 	outLatitude,
		double * 	outLongitude,
		double * 	outAltitude
	)
]]

local graphics = {}

function graphics.world_to_local(lat, lon, elev)
	local out_x = ffi.new("double[1]", 0)
	local out_y = ffi.new("double[1]", 0)
	local out_z = ffi.new("double[1]", 0)
	local in_lat = ffi.new("double", tonumber(lat))
	local in_lon = ffi.new("double", tonumber(lon))
	local in_elev = ffi.new("double", tonumber(elev))
	XPLM.XPLMWorldToLocal(in_lat, in_lon, in_elev, out_x, out_y, out_z)

	return out_x[0], out_y[0], out_z[0]
end

function graphics.local_to_world(x, y, z)
	local out_lat = ffi.new("double[1]", 0)
	local out_lon = ffi.new("double[1]", 0)
	local out_elev = ffi.new("double[1]", 0)
	local in_x = ffi.new("double", tonumber(x))
	local in_y = ffi.new("double", tonumber(y))
	local in_z = ffi.new("double", tonumber(z))
	XPLM.XPLMLocalToWorld(in_x, in_y, in_z, out_lat, out_lon, out_elev)

	return out_lat[0], out_lon[0], out_elev[0]
end

return graphics
