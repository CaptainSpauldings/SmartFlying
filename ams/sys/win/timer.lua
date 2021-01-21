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

-- Hi-Res timer for Windows
--   derived form: http://lua-users.org/wiki/HiResTimer (unknown author)
--

require("ams.sys.info")

if os.name() ~= "win" then
	return
end

local ffi = require("ffi")
local kernel32 = ffi.load("kernel32.dll")
local socket = require("socket")

ffi.cdef("int QueryPerformanceCounter( int *lpPerformanceCount )")
ffi.cdef("int QueryPerformanceFrequency( int *lpFrequency )")

local function lu(long)-->[
	return long<0 and long+0x80000000+0x80000000 or long
end-->]

local function qpf()-->[
	local frequency=ffi.new("long[2]")
	kernel32.QueryPerformanceFrequency(frequency)
	return  math.ldexp(lu(frequency[0]),0)
		    +math.ldexp(lu(frequency[1]),32)
end-->]

local function qpc()-->[
	local counter=ffi.new("long[2]")
	kernel32.QueryPerformanceCounter(counter)
	return	 math.ldexp(lu(counter[0]),0)
			+math.ldexp(lu(counter[0]),32)
end-->]


local win = {
	scale = 1,
	start_val = qpc(),
}
function win.clock() 		--> returns the enlapsed time in floating seconds with microseconds precision>[
	local curr_val=qpc()
	return (curr_val-win.start_val)/win.scale
end-->]

function win.calibrate(interval) 	--> do a one second loop to calibrate the scale for the output of win.clock()>[
	interval = interval or 1.0

	local start_t = socket.gettime()
	local start_c = qpc()
	socket.sleep(interval)
	local end_c = qpc()
	local end_t = socket.gettime()

	win.scale = (end_c-start_c)/(end_t-start_t)
end-->]

win.calibrate()

print("[ams/sys/win/timer] CPU Frequency is "..string.format("%.4f", tonumber(qpf())))
print("[ams/sys/win/timer] Windows timer scale is "..string.format("%.4f", tonumber(win.scale) or 0))

return win

-- vim: foldmethod=marker foldmarker=>[,>]
