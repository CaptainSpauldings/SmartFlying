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

-- AMS Processes Status Monitor

local core = require("ams.core.kernel")
require("ams.core.wm")
require("ams.core.dref_mgr")



function ams.procs_mon(_)
	core.win.procs_mon:show()
end



local procs_mon = {
	dref = {
		framerate_period 		= ams:map_dref("sim/time/framerate_period"),
	},
}
function procs_mon.show_win(self)
	if self.visible == true then
		return
	end
	self.width = 800
	self.height = 400
	self:create()

	self.visible = true
end

function procs_mon.draw_win(self)
	local task = core.kernel.task
	local modes = {[0] = "F", [1]="D", [2]="O", [3]="S", [4]="G", [5]="E"}

	imgui.TextUnformatted("")

	imgui.Columns(2, nil, false)
	imgui.SetColumnWidth(0, 120)
	imgui.SetColumnWidth(1, 120)

	imgui.TextUnformatted("Sim Speed:")
	imgui.TextUnformatted("")
	imgui.NextColumn()
	imgui.TextUnformatted(string.format("%.2f fps", 1/procs_mon.dref.framerate_period[0]))
	imgui.NextColumn()

	imgui.TextUnformatted("Mapped Drefs:")
	imgui.NextColumn()
	imgui.TextUnformatted(core.kernel.dref_mgr.totals.drefs)
	imgui.NextColumn()

	imgui.TextUnformatted("Custom Drefs:")
	imgui.NextColumn()
	imgui.TextUnformatted(core.kernel.dref_mgr.totals.custom_drefs)
	imgui.NextColumn()

	imgui.TextUnformatted("Custom Commands:")
	imgui.TextUnformatted("")
	imgui.NextColumn()
	imgui.TextUnformatted(core.kernel.dref_mgr.totals.custom_cmds)
	imgui.NextColumn()

	imgui.Columns(7, nil, false)
	imgui.SetColumnWidth(0, 120)
	imgui.SetColumnWidth(1, 80)
	imgui.SetColumnWidth(2, 80)
	imgui.SetColumnWidth(3, 80)
	imgui.SetColumnWidth(4, 80)
	imgui.SetColumnWidth(5, 80)
	imgui.SetColumnWidth(6, 80)


	imgui.TextUnformatted("")
	imgui.NextColumn()
	imgui.TextUnformatted("FRAME")
	imgui.TextUnformatted("-----------")
	imgui.NextColumn()
	imgui.TextUnformatted("DRAW")
	imgui.TextUnformatted("-----------")
	imgui.NextColumn()
	imgui.TextUnformatted("OFTEN")
	imgui.TextUnformatted("-----------")
	imgui.NextColumn()
	imgui.TextUnformatted("SOMETIMES")
	imgui.TextUnformatted("-----------")
	imgui.NextColumn()
	imgui.TextUnformatted("GUI")
	imgui.TextUnformatted("-----------")
	imgui.NextColumn()
	imgui.TextUnformatted("EXIT")
	imgui.TextUnformatted("-----------")
	imgui.NextColumn()

	imgui.TextUnformatted("Running:")
	imgui.NextColumn()
	for i = 0,5 do
		imgui.TextUnformatted(core.kernel.status[i].running)
		imgui.NextColumn()
	end

	imgui.TextUnformatted("Sleeping:")
	imgui.NextColumn()
	for i = 0,5 do
		imgui.TextUnformatted(core.kernel.status[i].sleeping)
		imgui.NextColumn()
	end

	imgui.TextUnformatted("CPU Time:")
	imgui.NextColumn()
	for i = 0,4 do
		imgui.TextUnformatted(string.format("%0.2f ms", core.kernel.status[i].cpu_time*1000))
		imgui.NextColumn()
	end
	imgui.NextColumn()

	imgui.TextUnformatted("Load %:")
	imgui.NextColumn()
	for i = 0,3 do
		imgui.TextUnformatted(string.format("%0.1f%%", (core.kernel.status[i].cpu_time/core.kernel.status[i].enlapsed)*100))
		imgui.NextColumn()
	end
	imgui.NextColumn()
	imgui.NextColumn()

	imgui.TextUnformatted("Elapsed:")
	imgui.NextColumn()
	for i = 0,3 do
		if i < 2 then
			imgui.TextUnformatted(string.format("%0.2f ms", core.kernel.status[i].enlapsed*1000))
		else
			imgui.TextUnformatted(string.format("%0.2f s", core.kernel.status[i].enlapsed))
		end
		imgui.NextColumn()
	end
	imgui.NextColumn()
	imgui.NextColumn()

	imgui.Columns(1, nil, false)
	imgui.TextUnformatted("")

	imgui.Columns(6, nil, false)
	imgui.SetColumnWidth(0, 40)
	imgui.SetColumnWidth(1, 60)
	imgui.SetColumnWidth(2, 450)
	imgui.SetColumnWidth(3, 80)
	imgui.SetColumnWidth(4, 80)
	imgui.SetColumnWidth(5, 80)



	imgui.TextUnformatted("ID")
	imgui.TextUnformatted("-----")
	imgui.NextColumn()
	imgui.TextUnformatted("Q/ORD")
	imgui.TextUnformatted("-------")
	imgui.NextColumn()
	imgui.TextUnformatted("PROCESS NAME")
	imgui.TextUnformatted("--------------------------------------------------------------------------------")
	imgui.NextColumn()
	imgui.TextUnformatted("CPU REAL")
	imgui.TextUnformatted("----------")
	imgui.NextColumn()
	imgui.TextUnformatted("AVERAGE")
	imgui.TextUnformatted("----------")
	imgui.NextColumn()
	imgui.TextUnformatted("PEAK")
	imgui.TextUnformatted("----------")
	imgui.NextColumn()

	for i, v in pairs(task) do
		local priority = ""
		if v.priority_flag  == true or i == 1 then
			priority = "*"
		end
		imgui.TextUnformatted(tostring(i)..priority)
		imgui.NextColumn()

		local queue = modes[v.queue]
		if v.queue_order > 0 then
			queue = queue.."/"..(v.queue_order)
		end
		imgui.TextUnformatted(queue)
		imgui.NextColumn()

		imgui.TextUnformatted(tostring(v.name))
		imgui.NextColumn()

		if v.sleeping_flag == true then
			imgui.TextUnformatted("<sleeping>")
			imgui.NextColumn()
			imgui.NextColumn()
			imgui.NextColumn()
		elseif tonumber(v.cpu_time) > 0 then
			imgui.TextUnformatted(string.format("%0.3f ms", v.cpu_time*1000))
			imgui.NextColumn()

			imgui.TextUnformatted(string.format("%0.3f ms", v.total_cpu_time/v.calls*1000))
			imgui.NextColumn()

			imgui.TextUnformatted(string.format("%0.3f ms", v.max_cpu_time*1000))
			imgui.NextColumn()
		else
			imgui.TextUnformatted("<waiting>")
			imgui.NextColumn()
			imgui.NextColumn()
			imgui.NextColumn()
		end

	end

end

function procs_mon.destroy_win(self)
	self.visible = false
end


core.win.procs_mon = ams:register_window("Processes Monitor", procs_mon.show_win, procs_mon.draw_win, procs_mon.destroy_win)

ams:create_command("ams/kernel/procs_monitor", "Show processes status", "", "", "ams:procs_mon()")
add_macro("Show processes status", "ams:procs_mon()")

