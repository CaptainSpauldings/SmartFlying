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

-- Lua implementation of constant variable
--
-- Every key of the table can be initialized only once,
--   then the value stored can not be changed anymore.

local function pairs_iterator(self)
	local c = self._constants

	local function stateless_iter(tbl, k)
		local v
		-- Implement your own key,value selection logic in place of next
		k, v = next(tbl, k)
		if nil~=v then return k,v end
	end

	-- Return an iterator function, the table, starting point
	return stateless_iter, c, nil
end

local function pop(self, k)
	if k == "pairs" then 			--> iterator for Lua version < 5.2
		return pairs_iterator
	end

	return self._constants[k]
end

local function push(self, k, v)
	if self._constants[k] == nil then
		self._constants[k] = v
	end
end

local Const = {
	__index = pop,
	__newindex = push,
	__pairs = pairs_iterator, 		--> standard pairs iterator for Lua version >= 5.2
}

function constants(array)
	local ret = {
		_constants = array or {},
	}
	return setmetatable(ret, Const)
end

