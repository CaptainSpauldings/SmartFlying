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

-- System Info
--

-- Gather OS name
local os_patterns = {
	['linux'] 	= 'lin',
	['windows'] 	= 'win',
	['^mingw'] 	= 'win',
	['^cygwin'] 	= 'win',
	['mac'] 	= 'mac',
	['darwin'] 	= 'mac',
}

local raw_os_name = string.lower(jit.os)
print("[ams/sys/info] Raw OS Name "..tostring(raw_os_name))
local os_name
for pattern, name in pairs(os_patterns) do
	if raw_os_name:match(pattern) then
		os_name = name
		break
	end
end
print("[ams/sys/info] OS type is "..tostring(os_name))


-- Gather Arch type
local arch_patterns = {
	['^x86$'] 	= 'x32',
	['i[%d]86'] 	= 'x32',
	['amd64'] 	= 'x64',
	['x86_64'] 	= 'x64',
	['x64'] 	= 'x64',
}
local raw_arch_name = string.lower(jit.arch)
print("[ams/sys/info] Raw Arch Name "..tostring(raw_arch_name))
local arch_name
for pattern, name in pairs(arch_patterns) do
	if raw_arch_name:match(pattern) then
		arch_name = name
		break
	end
end
print("[ams/sys/info] Arch type is "..tostring(arch_name))


-- Gather Dir separator
local dirsep = package.config:sub(1, 1)


-- Extends Lua os command sets
function os.name()
	return os_name
end

function os.libext()
	return lib_ext
end

function os.arch()
	return arch_name
end

function os.dirsep()
	return dirsep
end


