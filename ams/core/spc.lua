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

-- AMS Serialized Processes Call
--
-- ## NOTE ##
-- It needs to be converted in a proper kernel class
--

require("ams.core.kernel")



function ams.spc(_, name, queue, opt_parms)
	queue = queue or ams.C.FRAME_LOOP
	local task = ams:exec(spc.main_loop, name, queue, opt_parms)
	task.spc_proc = {}
	task.spc_idx = 1
	task.cyclic = true
	task.kill_at_end = true
	task.spc_delay = 0
	task.spc_delay_cnt = 0

	task.insert = spc.insert_proc
	task.remove = spc.remove_proc
	task.erase_all = spc.erase_all_procs

	return task
end



local spc = {}
function spc.main_loop(self)
	local proc = self.spc_proc
	if #proc == 0 then
		self.name = self.basename..": idle"
		return
	end

	if self.spc_delay_cnt > 0 then
		self.spc_delay_cnt = self.spc_delay_cnt - 1
		return
	end
	self.spc_delay_cnt = self.spc_delay

	if  self.spc_idx > #proc then
		self.spc_idx = 1
		if not self.cyclic then
			if self.kill_at_end then
				self:kill()
			else
				self.name = self.basename
				self:pause()
			end
			return
		end
	end

	if proc[self.spc_idx] ~= nil then
		local proc_name = proc[self.spc_idx].name or "sub-proc #"..self.spc_idx
		self.name = self.basename..": "..proc_name
		proc[self.spc_idx].func(self)
	else
		self.name = self.basename..": missing sub-proc #"..self.spc_idx
	end

	self.spc_idx = self.spc_idx + 1
end

function spc.insert_proc(self, proc_f, proc_name)
	table.insert(self.spc_proc, {name=proc_name, func=proc_f})
	return self.spc_proc[#self.spc_proc]
end

function spc.remove_proc(self, idx)
	table.remove(self.spc_proc, idx)
end

function spc.erase_all_procs(self)
	self.spc_proc = {}
end

