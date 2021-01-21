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

-- AMS Sequencially Called For-Loop
--
-- Description:
-- 	This function acts a for-loop cycle, but each iteration is executed at each call of the task.
-- 	It allows to run slow cycles, without blocking the simulator for the eccessive CPU load.
--
-- 	Works in a similar way of the standard Lua for-loop, accepting either a numerical range or a value pairs.
-- 	It needs a function to be executed at each call. This function must accept a numerical value for the range form or two values for the pairs form.
--
-- Usage:
-- 	ams:for_loop( <name_of_task>, (* func(val)), <beg>, [<end>], [<step>] ) or
-- 	ams:for_loop( <name_of_task>, (* func(val, val)), pairs(<array>))
--
-- Example 1:
-- 	function my_func(k, v)
--		print("Key = "..k.." - Value = "..tostring(v))
--	end
--
-- 	foo = { "AA", "BB", "CC", "DD", end="ZZ" }
-- 	ams:for_loop( "Prints many letters", my_func, pairs(foo)):set_queue(ams.C.OFTEN_LOOP)
--
-- Example 2:
-- 	function my_func(val)
-- 		print("Value = "..val)
-- 	end
--
-- 	ams:for_loop( "Counts", my_func, 1, 300, 1 ):hi_priority()
--


local core = require("ams.core.kernel")

function ams.for_loop(_, name, func, ...)
	local arg = {...}

	local new_loop = setmetatable({}, { __index = core.class.for_loop})

	if type(arg[1]) == "number" and type(arg[2]) == "number" then
		new_loop.func = func
		new_loop.curr_v = arg[1]
		new_loop.end_v = arg[2] or arg[1]
		new_loop.step_v = arg[3] or 1
		new_loop.for_loop_f = new_loop.sequential
	elseif type(arg[1]) == "function" and type(arg[2]) == "table" then
		new_loop.func = func
		new_loop.iter_f = arg[1]
		new_loop.pairs_t = arg[2]
		new_loop.for_loop_f = new_loop.table_pairs
	end

	local ret = ams:exec(new_loop.for_loop_f, name)
	ret.for_loop = new_loop

	return ret
end



core.class.for_loop = {
	for_loop_f = nil,
	func = nil,

	iter_f = nil,
	pairs_t = nil,
	iter_idx = nil,
	iter_val = nil,
	iter_num = 0,

	curr_v = 0,
	end_v = 0,
	step_v = 0,
}
function core.class.for_loop.sequential(self)
	local for_loop = self.for_loop
	if for_loop.curr_v > for_loop.end_v then
		self:kill()
		return
	end

	self.name = self.basename..": count #"..for_loop.curr_v
	for_loop.func(for_loop.curr_v, self)

	for_loop.curr_v = for_loop.curr_v + for_loop.step_v
end

function core.class.for_loop.table_pairs(self)
	local for_loop = self.for_loop

	for_loop.iter_idx, for_loop.iter_val = for_loop.iter_f(for_loop.pairs_t, for_loop.iter_idx)
	if for_loop.iter_idx == nil then
		self:kill()
		return
	end

	for_loop.iter_num = for_loop.iter_num + 1
	self.name = self.basename..": iteration #"..for_loop.iter_num

	for_loop.func(for_loop.iter_idx, for_loop.iter_val, self)
end


