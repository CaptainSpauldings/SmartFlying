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


local ffi = require( "ffi" )

local XPLMlib = ""
if SYSTEM_ARCHITECTURE == 64 then
	if SYSTEM == "IBM" then
		XPLMlib = "XPLM_64"
	elseif SYSTEM == "LIN" then
		XPLMlib = "Resources/plugins/XPLM_64.so"
	else
		XPLMlib = "Resources/plugins/XPLM.framework/XPLM"
	end
else
	if SYSTEM == "IBM" then
		XPLMlib = "XPLM"
	elseif SYSTEM == "LIN" then
		XPLMlib = "Resources/plugins/XPLM.so"
	else
		XPLMlib = "Resources/plugins/XPLM.framework/XPLM"
	end
end

print("[ams/SDK/XPLM] XPLM Library Object loaded.")

return ffi.load(XPLMlib)

