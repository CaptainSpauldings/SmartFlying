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

-- AMS Window Manager

local core = require("ams.core.kernel")


function ams.register_window(_, name, build_f, draw_f, destroy_f)
	local win = setmetatable({}, { __index = core.class.window})
	win.name = name
	win.show = build_f
	win.draw_f = draw_f
	win.destroy_f = destroy_f

	return win
end


core.win = {}
core.kernel.win_task = {}

core.class.window = {
	name = nil,
	show = nil,
	draw_f = nil,
	destroy_f = nil,
	width = 640,
	height = 480,
	decoration = 1,
	imgui_flag = true,
}

function core.class.window.draw_callback(win_h)
	local start_t = os.clock()
	local win_task = core.kernel.win_task[tostring(win_h)]

	if win_task.sleeping_flag then
		return
	end
	if win_task.kill_window_flag then
		win_task:destroy()
		return
	end

	-- the function will receive both pointers: 'win_task.window' and 'win_task'
	win_task.window:draw_f(win_task)

	win_task.calls = win_task.calls + 1
	win_task.cpu_time = os.clock() - start_t
	win_task.total_cpu_time = win_task.total_cpu_time + win_task.cpu_time

	if win_task.cpu_time > win_task._super_max_cpu_time then
		win_task._super_max_cpu_time = win_task.cpu_time
	elseif win_task.cpu_time > win_task.max_cpu_time then
		win_task.max_cpu_time = win_task.cpu_time
	end
end

function core.class.window.destroy_callback(win_h)
	local tag = tostring(win_h)
	local win_task = core.kernel.win_task[tag]

	if win_task.window.destroy_f ~= nil then
		-- the function will receive both pointers: 'win_task.window' and 'win_task'
		win_task.window:destroy_f(win_task)
	end

	_G[win_task.global_draw_name] = nil
	_G[win_task.global_destroy_name] = nil

	win_task:kill_task()
	core.kernel.win_task[tag] = nil
end

function core.class.window.create(self)
	local win_h = float_wnd_create(self.width, self.height, self.decoration, self.imgui_flag)
	local tag = tostring(win_h)
	local handler_addr = string.split(tag, ' ')[2]

	local global_draw_func = "__ams_draw_window_"..handler_addr
	local global_destroy_func = "__ams_destroy_window_"..handler_addr

	_G[global_draw_func] = self.draw_callback
	_G[global_destroy_func] = self.destroy_callback


	float_wnd_set_imgui_builder(win_h, global_draw_func)
	float_wnd_set_onclose(win_h, global_destroy_func)

	local process_name
	if self.name ~= nil then
		process_name = self.name..": window "..handler_addr
		float_wnd_set_title(win_h, self.name)
	else
		process_name = "wm_window "..handler_addr
	end

	self.win_handler = win_h

	local win_task = ams:exec(nil, process_name, ams.C.GUI_LOOP)
	win_task.window = self
	win_task.win_handler = win_h
	win_task.destroy = core.class.window.destroy
	win_task.global_draw_name = global_draw_func
	win_task.global_destroy_name = global_destroy_func
	core.kernel.win_task[tag] = win_task
	win_task.kill_task = win_task.kill
	win_task.kill = core.class.window.kill
	win_task.kill_window_flag = false

	return win_h
end

function core.class.window.kill(self)
	self.kill_window_flag = true
end

function core.class.window.destroy(self)
	float_wnd_destroy(self.win_handler)
end


