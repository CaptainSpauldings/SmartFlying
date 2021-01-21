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

local ffi = require("ffi")
local XPLM = require("ams.SDK.XPLM")
print("[ams/SDK/AIplanes] XPLM module loaded.")

ffi.cdef("typedef int XPLMPluginID")
ffi.cdef("typedef void (* XPLMPlanesAvailable_f)(void * inRefcon)")

ffi.cdef("void XPLMCountAircraft (int * outTotalAcf, int * outActiveAcf, XPLMPluginID * outController)")
ffi.cdef("void XPLMGetNthAircraftModel (int inIndex, char * outFilename, char *outPath)")

ffi.cdef("int XPLMAcquirePlanes ( char ** inAcf, XPLMPlanesAvailable_f inCallback, void * inRefcon)")
ffi.cdef("void XPLMReleasePlanes(void)")

ffi.cdef("void XPLMDisableAIForPlane (int inPlaneIndex)")

return XPLM


