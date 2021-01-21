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


-- AMS Advanced Management System Kernel
-- (c) Pasquale Croce
--
-- DATA STRUCTURE:
--
-- 	ams.C 		constants
-- 	core.class 	classes
-- 	core.kernel 	Kernel data structures

local socket = require('socket')
require("ams.lua_extended.constants")
require("ams.sys")


local core = {}

ams = {
	version = "1.35a",
	stage = "alpha",
	C = constants({
		FRAME_LOOP 		= 0,
		DRAW_LOOP 		= 1,
		OFTEN_LOOP 		= 2,
		SOMETIMES_LOOP 		= 3,
		GUI_LOOP 		= 4,
		EXIT_LOOP		= 5,
	}),
}
function ams.exec(_, task_f, name, queue, opt_parms)-->[
	queue = queue or 0
	name = name or "["..tostring(task_f).."]"

	local task = core.kernel.task
	local new_task = setmetatable({}, { __index = core.class.task})
	new_task.name = name
	new_task.basename = name
	new_task.func = task_f
	new_task.parm = opt_parms
	new_task.queue = queue
	new_task.queue_stats = core.kernel.status[queue]

	task[#task+1] = new_task
	return new_task
end-->]

function ams.kill(_, task_num)-->[
	if task_num == nil or task_num <= 1 then
		return
	end
	if core.kernel.task[task_num] ~= nil then
		core.kernel.task[task_num]:kill()
	end
end-->]

function ams.pause(_, task_num)-->[
	if task_num == nil or task_num <= 1 then
		return
	end
	if core.kernel.task[task_num] ~= nil then
		core.kernel.task[task_num]:pause()
	end
end-->]

function ams.resume(_, task_num)-->[
	if task_num == nil or task_num <= 1 then
		return
	end
	if core.kernel.task[task_num] ~= nil then
		core.kernel.task[task_num]:resume()
	end
end-->]


core.class = {}

core.class.task = {
	func = nil,
	terminate = nil,
	parm = nil,

	queue = 0,
	queue_order = 0,
	queue_stats = nil,

	kill_flag = false,
	sleeping_flag = false,
	priority_flag =false,

	calls = 0,
	cpu_time = 0,
	max_cpu_time = 0,
	total_cpu_time = 0,
	_super_max_cpu_time = 0,
}
function core.class.task.kill(self)-->[
	self.kill_flag = true
end-->]

function core.class.task.pause(self)-->[
	self.sleeping_flag = true
end-->]

function core.class.task.resume(self)-->[
	self.sleeping_flag = false
end-->]

function core.class.task.exec(self)-->[
	local task_start_t = os.clock()

	self:func()
	self.calls = self.calls + 1
	self.cpu_time = os.clock() - task_start_t
	self.total_cpu_time = self.total_cpu_time + self.cpu_time

	if self.cpu_time > self._super_max_cpu_time then
		self._super_max_cpu_time = self.cpu_time
	elseif self.cpu_time > self.max_cpu_time then
		self.max_cpu_time = self.cpu_time
	end
end-->]

function core.class.task.hi_priority(self)-->[
	self.priority_flag  = true
	return self
end-->]

function core.class.task.low_priority(self)-->[
	self.priority_flag  = false
	return self
end-->]

function core.class.task.set_queue(self, queue)-->[
	queue = queue or ams.C.FRAME_LOOP
	self.queue = queue
	self.queue_stats = core.kernel.status[queue]

	return self
end-->]

function core.class.task.set_parms(self, val)-->[
	self.parm = val

	return self
end-->]


core.kernel = {
	task = {},
	queue = {},
	status = {},
}
function core.kernel.mainloop(queue)-->[
	local queue_t = core.kernel.queue
	local task = core.kernel.task

	local start_t = os.clock()
	local curr_t = socket.gettime()
	core.kernel.status[queue].enlapsed = curr_t - core.kernel.status[queue].last_call
	core.kernel.status[queue].last_call = curr_t
	core.kernel.status[queue].cpu_time = 0

	if queue == 0 then
		task[1]:exec()
	end

	for i, v in pairs(queue_t[queue] or {}) do 	--> Here we get an error if XP halt loading for a warning/error [queue_t = NULL] ** FIXED **
		v:exec()
		v.queue_order = i
	end
	core.kernel.status[queue].cpu_time = os.clock() - start_t
end-->]

function core.kernel.core_process(self)-->[
	local task = core.kernel.task
	local queue_t = core.kernel.queue
	local status = core.kernel.status
	for m = 0, 5 do
		queue_t[m] = {}
		status[m].running = 0
		status[m].sleeping = 0
		if m == ams.C.GUI_LOOP then
			status[m].cpu_time = 0
		end
	end

	for i, v in pairs(task) do
		if i == 1 then
			status[v.queue].running = status[v.queue].running + 1
		else
			if v.kill_flag == true then
				print("[ams/core/kernel] INFO: process #"..i.." '"..task[i].basename.."' terminated after "..task[i].calls.." call(s).")
				task[i] = nil
			elseif v.sleeping_flag == false then
				if v.priority_flag  == false then
					table.insert(queue_t[v.queue], v)
				else
					table.insert(queue_t[v.queue], 1, v)
				end
				status[v.queue].running = status[v.queue].running + 1
				if v.queue == ams.C.GUI_LOOP then
					status[v.queue].cpu_time = status[v.queue].cpu_time + v.cpu_time
				end
			else
				status[v.queue].sleeping = status[v.queue].sleeping + 1
				v.cpu_time = 0
				v.queue_order = 0
			end
		end
	end
end-->]

function core.kernel.init_core_process()-->[
	local curr_t = socket.gettime()
	for i = 0, 5 do
		core.kernel.status[i] = {
			running = 0,
			sleeping = 0,
			cpu_time = 0,
			enlapsed = 0,
			last_call = curr_t,
		}
	end

	local task = core.kernel.task
	local new_task = setmetatable({}, { __index = core.class.task})

	new_task.name = "Kernel Core Process"
	new_task.basename = new_task.name
	new_task.func = core.kernel.core_process
	new_task.parm = nil
	new_task.queue = ams.C.FRAME_LOOP

	task[1] = new_task
end-->]

function core.kernel.terminate_all()-->[
	core.kernel.task[1]:exec()
	core.kernel.mainloop(ams.C.EXIT_LOOP)

	for n, tsk in pairs(core.kernel.task) do
		print("[ams/core/kernel] INFO: process #"..n.." '"..tsk.basename.."' terminated after "..tsk.calls.." call(s).")
	end
end-->]


__ams_core_kernel_mainloop = core.kernel.mainloop
__ams_core_kernel_terminate_all = core.kernel.terminate_all

core.kernel.init_core_process()

do_every_frame( 	"__ams_core_kernel_mainloop(ams.C.FRAME_LOOP)")
do_every_draw( 		"__ams_core_kernel_mainloop(ams.C.DRAW_LOOP)")
do_often( 		"__ams_core_kernel_mainloop(ams.C.OFTEN_LOOP)")
do_sometimes( 		"__ams_core_kernel_mainloop(ams.C.SOMETIMES_LOOP)")
do_on_exit( 		"__ams_core_kernel_terminate_all()")

print("[ams/core/kernel] Loaded version "..ams.version.." ("..ams.stage..").")

return core

-- vim: foldmethod=marker foldmarker=>[,>]
