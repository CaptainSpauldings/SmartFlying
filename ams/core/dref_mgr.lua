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


-- AMS Dataref Manager

local core = require("ams.core.kernel")
require("ams.lua_extended.strings")

--[[
--
-- ams:create_dref( <name_of_dref>, <cast>, [<array len>], [<init value>] ) or
-- ams:create_dref( <name_of_dref>, "Data", [<init string>] )
-- 		<name_of_dref> 		= string with the name
-- 		<cast> 			= type of dref: "Int", "Float", "FloatArray", "IntArray", "Double", "Data"
-- 		<array len> 		= defaults to 1
-- 		<init value> 		= can be a single value or an array of value, in the first case the value will be given to all the elements
--
--]]


function ams.create_dref(_, dref_name, dref_cast, len, init_v)
	if type(len) == "string" then
		init_v = len
		len = 1
	else
		len = len or 1
		init_v = init_v or 0
	end
	local dmgr = core.kernel.dref_mgr

	if dmgr.dref[dref_name] ~= nil then
		print("[ams/core/dref_mgr] WARNING: A dataref with the same name already exists and is already mapped.")
		print("[ams/core/dref_mgr] WARNING: Returning existing dataref "..dref_name..".")
		return dmgr.dref[dref_name]
	end

	dmgr.custom_dref[dref_name] = {cast=dref_cast, length=len, init_val=init_v}

	local init = false
	if XPLMFindDataRef(dref_name) == nil then
		define_shared_DataRef(dref_name, dref_cast)
		init = true
	else
		print("[ams/core/dref_mgr] WARNING: A dataref with the same name already exists.")
		print("[ams/core/dref_mgr] WARNING: Mapping dataref "..dref_name..".")
	end
	dmgr.dref[dref_name] = dataref_table(dref_name)

	if init then
		if dref_cast == "Data" then
			dmgr.dref[dref_name][0] = tostring(init_v)
		else
			for i = 0, len-1 do
				if type(init_v) == "table" then
					if init_v[i] ~= nil then
						dmgr.dref[dref_name][i] = init_v[i]
					else
						dmgr.dref[dref_name][i] = 0
					end
				else
					dmgr.dref[dref_name][i] = init_v
				end
			end
		end
		print("[ams/core/dref_mgr] INFO: Initialized dataref "..dref_name..".")
	end

	dmgr.totals.custom_drefs = dmgr.totals.custom_drefs + 1
	return dmgr.dref[dref_name]
end

function ams.create_command(_, cmd_dref, cmd_descr, cmd_begin, cmd_cont, cmd_once)
	local dmgr = core.kernel.dref_mgr
	if dmgr.custom_cmd[cmd_dref] ~= nil then
		print("[ams/core/dref_mgr] WARNING: A command with the same name already exists.")
		print("[ams/core/dref_mgr] WARNING: Overwriting command "..cmd_dref..".")
		-- *** NEED TO CHECK IF OVERWRITING COMMAND WORKS ***
--		return
	end


	local cmd_begin_str, cmd_cont_str, cmd_once_str = "", "", ""
	local ptr_str
	if type(cmd_begin) == "string" then
		cmd_begin_str= cmd_begin
	elseif type(cmd_begin) == "function" then
		ptr_str = "__ams_begin_"..tostring(cmd_begin):split(' ')[2]
		_G[ptr_str] = cmd_begin
		cmd_begin_str = ptr_str.."()"
	end

	if type(cmd_cont) == "string" then
		cmd_cont_str= cmd_cont
	elseif type(cmd_cont) == "function" then
		ptr_str = "__ams_cont_"..tostring(cmd_cont):split(' ')[2]
		_G[ptr_str] = cmd_cont
		cmd_cont_str = ptr_str.."()"
	end

	if type(cmd_once) == "string" then
		cmd_once_str= cmd_once
	elseif type(cmd_once) == "function" then
		ptr_str = "__ams_once_"..tostring(cmd_once):split(' ')[2]
		_G[ptr_str] = cmd_once
		cmd_once_str = ptr_str.."()"
		print("IS FUNCTION "..cmd_once_str)
	end

	dmgr.custom_cmd[cmd_dref] = {descr=cmd_descr, begin=cmd_begin_str, cont=cmd_cont_str, once=cmd_once_str}

	create_command(cmd_dref, cmd_descr, cmd_begin_str, cmd_cont_str, cmd_once_str)
	dmgr.totals.custom_cmds = dmgr.totals.custom_cmds + 1
end

function ams.map_dref(_, dref_name)
	local dmgr = core.kernel.dref_mgr

	if dmgr.dref[dref_name] ~= nil then
		print("[ams/core/dref_mgr] INFO: Dataref "..dref_name.." was already mapped.")
		return dmgr.dref[dref_name]
	end

	dmgr.dref[dref_name] = dataref_table(dref_name)
	dmgr.totals.drefs = dmgr.totals.drefs + 1
	return dmgr.dref[dref_name]
end



-- Encapsulated Dataref  ***WIP***
local function edref_get(self, idx)
	self.idx = idx or self.idx
	return self.v[self.idx]
end

local function edref_set(self, value, idx)
	if self.readonly then
		return
	end
	self.idx = idx or self.idx
	self.v[self.idx] = value
	return self.v[self.idx]
end

local eDref_class = {
	get = edref_get,
	set = edref_set,
	v = nil,
	idx = 0,
	readonly = false,
}

function ams.encapsulate(_, dref_p, idx, readonly)
	local ret = setmetatable({}, { __index = eDref_class})
	ret.v = dref_p
	ret.idx = idx or 0
	ret.readonly = readonly or false

	return ret
end



core.kernel.dref_mgr = {
	dref = {},
	custom_cmd = {},
	custom_dref = {},
	totals = {
		drefs = 0,
		custom_cmds = 0,
		custom_drefs = 0,
	},
}
function core.kernel.dref_mgr.init(self)
	core.kernel.dref_mgr.write_cache_file()
	self:kill()
end

function core.kernel.dref_mgr.write_cache_file()
	local dmgr = core.kernel.dref_mgr
	local file = io.open(SCRIPT_DIRECTORY.."_CustomDRefs.cache.lua", "w")

	file:write("-- ** THIS FILE IS AN HACK TO MAKE THE CUSTOM DATAREFS VISIBLES IN DATAREF-TOOL **\n")
	file:write("-- ** THIS FILE IS AUTOMATICALLY GENERATED. ANY EDIT WILL BE ERASED **\n")

	file:write("\n\n-- CUSTOM DATAREFS:\n")
	for name, data in pairs(dmgr.custom_dref) do
		file:write("-- dataref '"..name.."' ("..data.cast..")\n")
	end

	file:write("\n\n-- CUSTOM COMMANDS:\n")
	for name, data in pairs(dmgr.custom_cmd) do
		file:write("-- command '"..name.."' ("..data.descr..")\n")
	end
	file:write("\n\n-- generated on: "..os.date().."\n")
	file:close()

	print("[ams/core/dref_mgr] Cache file dumped.")
end


ams:exec(core.kernel.dref_mgr.init, "[ams/core/dref_mgr]: init")

