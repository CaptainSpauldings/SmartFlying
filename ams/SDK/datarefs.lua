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
print("[ams/SDK/datarefs] XPLM module loaded.")

ffi.cdef("typedef void * XPLMDataRef")

ffi.cdef("XPLMDataRef XPLMFindDataRef( const char * inDataRefName )")
ffi.cdef("int XPLMCanWriteDataRef( XPLMDataRef inDataRef )")
ffi.cdef("int XPLMGetDataRefTypes( XPLMDataRef inDataRef )")

ffi.cdef("int XPLMGetDatai( XPLMDataRef inDataRef )")
ffi.cdef("float XPLMGetDataf( XPLMDataRef inDataRef )")
ffi.cdef("double XPLMGetDatad( XPLMDataRef inDataRef )")
ffi.cdef("int XPLMGetDatavi( XPLMDataRef inDataRef, int * outValues, int inOffset, int inMax )")
ffi.cdef("int XPLMGetDatavf( XPLMDataRef inDataRef, float * outValues, int inOffset, int inMax )")
ffi.cdef("int XPLMGetDatab( XPLMDataRef inDataRef, char * outValues, int inOffset, int inMaxBytes )")

ffi.cdef("void XPLMSetDatai( XPLMDataRef inDataRef, int inValue )")
ffi.cdef("void XPLMSetDataf( XPLMDataRef inDataRef, float inValue )")
ffi.cdef("void XPLMSetDatad( XPLMDataRef inDataRef, double inValue )")
ffi.cdef("void XPLMSetDatavi( XPLMDataRef inDataRef, int * inValues, int inOffset, int inCount )")
ffi.cdef("void XPLMSetDatavf( XPLMDataRef inDataRef, float * inValues, int inOffset, int inCount )")
ffi.cdef("void XPLMSetDatab( XPLMDataRef inDataRef, char * inValue, int inOffset, int inLenght )")

--ffi.cdef("int XPLMGetCycleNumber(void)")
ffi.cdef("int XPLMGetCycleNumber(void)")

local datarefs = {
	types = {
		[0] = "Unknown",
		[1] = "Int",
		[2] = "Float",
		[4] = "Double",
		[8] = "FloatArray",
		[16] = "IntArray",
		[32] = "Data",
	},
}

function datarefs.set_string(dref_name, str)
	local dref_h = XPLM.XPLMFindDataRef(dref_name)
	local c_str = ffi.new("char[?]", #str+1)
	ffi.copy(c_str, str..string.char(0))
	XPLM.XPLMSetDatab(dref_h, c_str, 0, #str+1)
end

function datarefs.len(dref_name)
	local dref_h = XPLM.XPLMFindDataRef(dref_name)
	local dref_type = XPLM.XPLMGetDataRefTypes(dref_h)

	if dref_type < 8 then
		return 1
	elseif dref_type == 8 then
		return XPLM.XPLMGetDatavf( dref_h, ffi.NULL, 0, 2)
	elseif dref_type == 16 then
		return XPLM.XPLMGetDatavi( dref_h, ffi.NULL, 0, 2)
	elseif dref_type == 32 then
		return XPLM.XPLMGetDatab( dref_h, ffi.NULL, 0, 2)
	end
	return -1
end

function datarefs.type(dref_name)
	local dref_h = XPLM.XPLMFindDataRef(dref_name)
	local dref_type = XPLM.XPLMGetDataRefTypes(dref_h)

	return datarefs.types[dref_type]
end

function datarefs.writable(dref_name)
	-- BUG: Apparently this function can't work because XPLMCanWriteDataRef() always returns 1
	-- 	it looks like that the only way to get it work, is to test to overwrite the dataref
	local dref_h = XPLM.XPLMFindDataRef(dref_name)
	local dref_stat = XPLM.XPLMCanWriteDataRef(dref_h)

	if dref_stat == 1 then
		return true
	end
	return false
end

function datarefs.get_cycle_num()
	return XPLM.XPLMGetCycleNumber()
end

return datarefs


