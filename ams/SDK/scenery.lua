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

require("ams.core.kernel")
local ffi = require("ffi")
local XPLM = require("ams.SDK.XPLM")


ffi.cdef("typedef void * XPLMObjectRef;")
ffi.cdef("typedef struct {int structSize; float x; float y; float z; float pitch; float heading; float roll; } XPLMDrawInfo_t;") -- Struct size is 28

ffi.cdef("XPLMObjectRef XPLMLoadObject(const char * inPath);")
ffi.cdef("void XPLMUnloadObject(XPLMObjectRef inObject);")

ffi.cdef("typedef void * XPLMInstanceRef;")
ffi.cdef("XPLMInstanceRef XPLMCreateInstance(XPLMObjectRef obj, const char ** datarefs);")
ffi.cdef("void XPLMDestroyInstance(XPLMInstanceRef instance);")
ffi.cdef("void XPLMInstanceSetPosition(XPLMInstanceRef instance, const XPLMDrawInfo_t * new_position, const float * data);")


local nil_dref_th = ffi.new('const char *[1]', nil)

local obj_instance_registry = {}

local scenery = {}
function scenery.loadObj(name)
	local ret = XPLM.XPLMLoadObject(name)
	if ret == nil then
		print("[ams/SDK/scenery] Can't load object '"..name.."'.")
	else
		print("[ams/SDK/scenery] Loaded object '"..name.."'.")
	end
	return ret
end

function scenery.unloadObj(obj_h)
	XPLM.XPLMUnloadObject(obj_h)
end

function scenery.createInst(obj_h, dataref_t)
	local dref_th = nil_dref_th
	if dataref_t ~= nil then
		dref_th = ffi.new('const char *['..#dataref_t..']', dataref_t)
	end

	local ret = XPLM.XPLMCreateInstance(obj_h, dref_th)
	if ret ~= nil then
		obj_instance_registry[tostring(ret)] = ret
	end
	return ret
end

function scenery.xformInst(inst_h, xform_t, data_h)
	local xform_h = ffi.new('XPLMDrawInfo_t', 28,
			xform_t[1], --> local_x
			xform_t[2], --> local_y
			xform_t[3], --> local_z
			xform_t[4], --> theta
			xform_t[5], --> psi
			xform_t[6]  --> phi
		)

	XPLM.XPLMInstanceSetPosition(inst_h, xform_h, data_h)
end

function scenery.destroyInst(inst_h)
	obj_instance_registry[tostring(inst_h)] = nil
	XPLM.XPLMDestroyInstance(inst_h)
end

function scenery.free()
	print("[ams/SDK/scenery] Freeing instances...")
	local cnt = 0
	for k, v in pairs(obj_instance_registry) do
		XPLM.XPLMDestroyInstance(v)
		cnt = cnt + 1
	end
	print("[ams/SDK/scenery] "..cnt.." instances freed.")
end

ams:exec(scenery.free, "XPLMScenery free", ams.C.EXIT_LOOP)

print("[ams/SDK/scenery] XPLMScenery Module loaded..")

return scenery, XPLM

