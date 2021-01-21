--  SmartFlying, an extension to make Formation Flying with SmartCopilot
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


-- Smart Flying -- an extesion for SmartCopilot (requires v.3.1.4)
-- written by Captain Spaulding (a.k.a. the Drunk Bush Pilot)
--
-- (c) 2021, Pasquale Croce

if not(pcall(require, 'ams')) then
	print("[SmartFlying] ERROR: Required 'ams' lua package not found.")
	return
end
local XPLM = require("ams.SDK.AIplanes")
local graph = require("ams.SDK.graphics")

local smartfly = {
	version = "0.84a [AMS]",
	stage = "alpha",

	_inited = false,
	enabled = false,

	is_master = 1,

	CONF = {
		SCP_MASTER 		= "scp/api/ismaster",

	},
	dref = {
		zulu_time 				= ams:map_dref("sim/time/zulu_time_sec"),
		master_data = {
			lat 				= ams:create_dref("smartfly/master/latitude", "Double"),
			lon 				= ams:create_dref("smartfly/master/longitude", "Double"),
			elev 				= ams:create_dref("smartfly/master/elevation", "Double"),
			the 				= ams:create_dref("smartfly/master/the", "Float"),
			phi 				= ams:create_dref("smartfly/master/phi", "Float"),
			psi 				= ams:create_dref("smartfly/master/psi", "Float"),
			v_x 				= ams:create_dref("smartfly/master/v_x", "Float"),
			v_y 				= ams:create_dref("smartfly/master/v_y", "Float"),
			v_z 				= ams:create_dref("smartfly/master/v_z", "Float"),
			gear_deploy 			= ams:create_dref("smartfly/master/gear_deploy", "FloatArray", 10),
			flap_ratio 			= ams:create_dref("smartfly/master/flap_ratio", "Float"),
			flap_ratio2 			= ams:create_dref("smartfly/master/flap_ratio2", "Float"),
			spoiler_ratio 			= ams:create_dref("smartfly/master/spoiler_ratio", "Float"),
			speedbrake_ratio 		= ams:create_dref("smartfly/master/speedbrake_ratio", "Float"),
			slat_ratio 			= ams:create_dref("smartfly/master/slat_ratio", "Float"),
			wing_sweep 			= ams:create_dref("smartfly/master/wing_sweep", "Float"),
			throttle 			= ams:create_dref("smartfly/master/throttle", "FloatArray", 8),
			beacon_lights_on 		= ams:create_dref("smartfly/master/beacon_lights_on", "Int"),
			landing_lights_on 		= ams:create_dref("smartfly/master/landing_lights_on", "Int"),
			nav_lights_on 			= ams:create_dref("smartfly/master/nav_lights_on", "Int"),
			strobe_lights_on 		= ams:create_dref("smartfly/master/strobe_lights_on", "Int"),
			taxi_light_on 			= ams:create_dref("smartfly/master/taxi_light_on", "Int"),

			yoke_pitch_ratio 		= ams:create_dref("smartfly/master/controls/yoke_pitch_ratio", "Float"),
			yoke_roll_ratio 		= ams:create_dref("smartfly/master/controls/yoke_roll_ratio", "Float"),
			yoke_heading_ratio 		= ams:create_dref("smartfly/master/controls/yoke_heading_ratio", "Float"),
			gear_request 			= ams:create_dref("smartfly/master/controls/gear_request", "Int"),
			flap_request 			= ams:create_dref("smartfly/master/controls/flap_request", "Float"),
			speed_brake_request 		= ams:create_dref("smartfly/master/controls/speed_brake_request", "Float"),
			vector_request 			= ams:create_dref("smartfly/master/controls/vector_request", "Float"),
			sweep_request 			= ams:create_dref("smartfly/master/controls/sweep__request", "Float"),
			incidence_request 		= ams:create_dref("smartfly/master/controls/incidence_request", "Float"),
			dihedral_request 		= ams:create_dref("smartfly/master/controls/dihedral_request", "Float"),
			tail_lock_ratio 		= ams:create_dref("smartfly/master/controls/tail_lock_ratio", "Float"),
			l_brake_add 			= ams:create_dref("smartfly/master/controls/l_brake_add", "Float"),
			r_brake_add 			= ams:create_dref("smartfly/master/controls/r_brake_add", "Float"),
			parking_brake 			= ams:create_dref("smartfly/master/controls/parking_brake", "Float"),
			aileron_trim 			= ams:create_dref("smartfly/master/controls/aileron_trim", "Float"),
			elevator_trim 			= ams:create_dref("smartfly/master/controls/elevator_trim", "Float"),
			rotor_trim 			= ams:create_dref("smartfly/master/controls/rotor_trim", "Float"),
			rudder_trim 			= ams:create_dref("smartfly/master/controls/rudder_trim", "Float"),
			engine_throttle_request 	= ams:create_dref("smartfly/master/controls/engine_throttle_request", "Float"),
			engine_prop_request 		= ams:create_dref("smartfly/master/controls/engine_prop_request", "Float"),
			engine_pitch_request 		= ams:create_dref("smartfly/master/controls/engine_pitch_request", "Float"),
			engine_mixture_request 		= ams:create_dref("smartfly/master/controls/engine_mixture_request", "Float"),
		},
		slave_data = {
			lat 				= ams:create_dref("smartfly/slave/latitude", "Double"),
			lon 				= ams:create_dref("smartfly/slave/longitude", "Double"),
			elev 				= ams:create_dref("smartfly/slave/elevation", "Double"),
			the 				= ams:create_dref("smartfly/slave/the", "Float"),
			phi 				= ams:create_dref("smartfly/slave/phi", "Float"),
			psi 				= ams:create_dref("smartfly/slave/psi", "Float"),
			v_x 				= ams:create_dref("smartfly/slave/v_x", "Float"),
			v_y 				= ams:create_dref("smartfly/slave/v_y", "Float"),
			v_z 				= ams:create_dref("smartfly/slave/v_z", "Float"),
			gear_deploy 			= ams:create_dref("smartfly/slave/gear_deploy", "FloatArray", 10),
			flap_ratio 			= ams:create_dref("smartfly/slave/flap_ratio", "Float"),
			flap_ratio2 			= ams:create_dref("smartfly/slave/flap_ratio2", "Float"),
			spoiler_ratio 			= ams:create_dref("smartfly/slave/spoiler_ratio", "Float"),
			speedbrake_ratio 		= ams:create_dref("smartfly/slave/speedbrake_ratio", "Float"),
			slat_ratio 			= ams:create_dref("smartfly/slave/slat_ratio", "Float"),
			wing_sweep 			= ams:create_dref("smartfly/slave/wing_sweep", "Float"),
			throttle 			= ams:create_dref("smartfly/slave/throttle", "FloatArray", 8),
			beacon_lights_on 		= ams:create_dref("smartfly/slave/beacon_lights_on", "Int"),
			landing_lights_on 		= ams:create_dref("smartfly/slave/landing_lights_on", "Int"),
			nav_lights_on 			= ams:create_dref("smartfly/slave/nav_lights_on", "Int"),
			strobe_lights_on 		= ams:create_dref("smartfly/slave/strobe_lights_on", "Int"),
			taxi_light_on 			= ams:create_dref("smartfly/slave/taxi_light_on", "Int"),

			yoke_pitch_ratio 		= ams:create_dref("smartfly/slave/controls/yoke_pitch_ratio", "Float"),
			yoke_roll_ratio 		= ams:create_dref("smartfly/slave/controls/yoke_roll_ratio", "Float"),
			yoke_heading_ratio 		= ams:create_dref("smartfly/slave/controls/yoke_heading_ratio", "Float"),
			gear_request 			= ams:create_dref("smartfly/slave/controls/gear_request", "Int"),
			flap_request 			= ams:create_dref("smartfly/slave/controls/flap_request", "Float"),
			speed_brake_request 		= ams:create_dref("smartfly/slave/controls/speed_brake_request", "Float"),
			vector_request 			= ams:create_dref("smartfly/slave/controls/vector_request", "Float"),
			sweep_request 			= ams:create_dref("smartfly/slave/controls/sweep__request", "Float"),
			incidence_request 		= ams:create_dref("smartfly/slave/controls/incidence_request", "Float"),
			dihedral_request 		= ams:create_dref("smartfly/slave/controls/dihedral_request", "Float"),
			tail_lock_ratio 		= ams:create_dref("smartfly/slave/controls/tail_lock_ratio", "Float"),
			l_brake_add 			= ams:create_dref("smartfly/slave/controls/l_brake_add", "Float"),
			r_brake_add 			= ams:create_dref("smartfly/slave/controls/r_brake_add", "Float"),
			parking_brake 			= ams:create_dref("smartfly/slave/controls/parking_brake", "Float"),
			aileron_trim 			= ams:create_dref("smartfly/slave/controls/aileron_trim", "Float"),
			elevator_trim 			= ams:create_dref("smartfly/slave/controls/elevator_trim", "Float"),
			rotor_trim 			= ams:create_dref("smartfly/slave/controls/rotor_trim", "Float"),
			rudder_trim 			= ams:create_dref("smartfly/slave/controls/rudder_trim", "Float"),
			engine_throttle_request 	= ams:create_dref("smartfly/slave/controls/engine_throttle_request", "Float"),
			engine_prop_request 		= ams:create_dref("smartfly/slave/controls/engine_prop_request", "Float"),
			engine_pitch_request 		= ams:create_dref("smartfly/slave/controls/engine_pitch_request", "Float"),
			engine_mixture_request 		= ams:create_dref("smartfly/slave/controls/engine_mixture_request", "Float"),
		},
		user_plane = {
			lat 				= ams:map_dref("sim/flightmodel/position/latitude"),
			lon 				= ams:map_dref("sim/flightmodel/position/longitude"),
			elev 				= ams:map_dref("sim/flightmodel/position/elevation"),
			the 				= ams:map_dref("sim/flightmodel/position/theta"),
			phi 				= ams:map_dref("sim/flightmodel/position/phi"),
			psi 				= ams:map_dref("sim/flightmodel/position/psi"),
			v_x 				= ams:map_dref("sim/flightmodel/position/local_vx"),
			v_y 				= ams:map_dref("sim/flightmodel/position/local_vy"),
			v_z 				= ams:map_dref("sim/flightmodel/position/local_vz"),
			gear_deploy 			= ams:map_dref("sim/aircraft/parts/acf_gear_deploy"),
			flap_ratio 			= ams:map_dref("sim/flightmodel2/controls/flap1_deploy_ratio"),
			flap_ratio2 			= ams:map_dref("sim/flightmodel2/controls/flap2_deploy_ratio"),
			spoiler_ratio 			= ams:map_dref("sim/flightmodel/controls/splr_def"),
			speedbrake_ratio 		= ams:map_dref("sim/flightmodel2/controls/speedbrake_ratio"),
			slat_ratio 			= ams:map_dref("sim/flightmodel/controls/slatrat"),
			wing_sweep 			= ams:map_dref("sim/flightmodel2/controls/wingsweep_ratio"),
			throttle 			= ams:map_dref("sim/flightmodel/engine/ENGN_thro"),
			beacon_lights_on 		= ams:map_dref("sim/cockpit/electrical/beacon_lights_on"),
			landing_lights_on 		= ams:map_dref("sim/cockpit/electrical/landing_lights_on"),
			nav_lights_on 			= ams:map_dref("sim/cockpit/electrical/nav_lights_on"),
			strobe_lights_on 		= ams:map_dref("sim/cockpit/electrical/strobe_lights_on"),
			taxi_light_on 			= ams:map_dref("sim/cockpit/electrical/taxi_light_on"),
		},
		ai_plane_local = { 	-- added structure to FIX issue #4
			loc_x 				= ams:map_dref("sim/multiplayer/position/plane1_x"),
			loc_y 				= ams:map_dref("sim/multiplayer/position/plane1_y"),
			loc_z 				= ams:map_dref("sim/multiplayer/position/plane1_z"),
		},
		ai_plane = {
			the 				= ams:map_dref("sim/multiplayer/position/plane1_the"),
			phi 				= ams:map_dref("sim/multiplayer/position/plane1_phi"),
			psi 				= ams:map_dref("sim/multiplayer/position/plane1_psi"),
			v_x 				= ams:map_dref("sim/multiplayer/position/plane1_v_x"),
			v_y 				= ams:map_dref("sim/multiplayer/position/plane1_v_y"),
			v_z 				= ams:map_dref("sim/multiplayer/position/plane1_v_x"),
			gear_deploy 			= ams:map_dref("sim/multiplayer/position/plane1_gear_deploy"),
			flap_ratio 			= ams:map_dref("sim/multiplayer/position/plane1_flap_ratio"),
			flap_ratio2 			= ams:map_dref("sim/multiplayer/position/plane1_flap_ratio2"),
			spoiler_ratio 			= ams:map_dref("sim/multiplayer/position/plane1_spoiler_ratio"),
			speedbrake_ratio 		= ams:map_dref("sim/multiplayer/position/plane1_speedbrake_ratio"),
			slat_ratio 			= ams:map_dref("sim/multiplayer/position/plane1_slat_ratio"),
			wing_sweep 			= ams:map_dref("sim/multiplayer/position/plane1_wing_sweep"),
			throttle 			= ams:map_dref("sim/multiplayer/position/plane1_throttle"),
			beacon_lights_on 		= ams:map_dref("sim/multiplayer/position/plane1_beacon_lights_on"),
			landing_lights_on 		= ams:map_dref("sim/multiplayer/position/plane1_landing_lights_on"),
			nav_lights_on 			= ams:map_dref("sim/multiplayer/position/plane1_nav_lights_on"),
			strobe_lights_on 		= ams:map_dref("sim/multiplayer/position/plane1_strobe_lights_on"),
			taxi_light_on 			= ams:map_dref("sim/multiplayer/position/plane1_taxi_light_on"),
		},
		controls = {
			yoke_pitch_ratio 		= ams:map_dref("sim/multiplayer/controls/yoke_pitch_ratio"),
			yoke_roll_ratio 		= ams:map_dref("sim/multiplayer/controls/yoke_roll_ratio"),
			yoke_heading_ratio 		= ams:map_dref("sim/multiplayer/controls/yoke_heading_ratio"),
			gear_request 			= ams:map_dref("sim/multiplayer/controls/gear_request"),
			flap_request 			= ams:map_dref("sim/multiplayer/controls/flap_request"),
			speed_brake_request 		= ams:map_dref("sim/multiplayer/controls/speed_brake_request"),
			vector_request 			= ams:map_dref("sim/multiplayer/controls/vector_request"),
			sweep_request 			= ams:map_dref("sim/multiplayer/controls/sweep__request"),
			incidence_request 		= ams:map_dref("sim/multiplayer/controls/incidence_request"),
			dihedral_request 		= ams:map_dref("sim/multiplayer/controls/dihedral_request"),
			tail_lock_ratio 		= ams:map_dref("sim/multiplayer/controls/tail_lock_ratio"),
			l_brake_add 			= ams:map_dref("sim/multiplayer/controls/l_brake_add"),
			r_brake_add 			= ams:map_dref("sim/multiplayer/controls/r_brake_add"),
			parking_brake 			= ams:map_dref("sim/multiplayer/controls/parking_brake"),
			aileron_trim 			= ams:map_dref("sim/multiplayer/controls/aileron_trim"),
			elevator_trim 			= ams:map_dref("sim/multiplayer/controls/elevator_trim"),
			rotor_trim 			= ams:map_dref("sim/multiplayer/controls/rotor_trim"),
			rudder_trim 			= ams:map_dref("sim/multiplayer/controls/rudder_trim"),
			engine_throttle_request 	= ams:map_dref("sim/multiplayer/controls/engine_throttle_request"),
			engine_prop_request 		= ams:map_dref("sim/multiplayer/controls/engine_prop_request"),
			engine_pitch_request 		= ams:map_dref("sim/multiplayer/controls/engine_pitch_request"),
			engine_mixture_request 		= ams:map_dref("sim/multiplayer/controls/engine_mixture_request"),
		},
		plane_data_size = {
			gear_deploy = 10,
			throttle = 8,
		},
	},
	C = {
	},
	buf = {
		ai_loc_x,
		at_loc_y,
		ai_loc_z,
	},
}

function smartfly.init()
	if smartfly._inited then
		return true
	end

	if XPLMFindDataRef(smartfly.CONF.SCP_MASTER) == nil then
		smartfly.is_master = 1
		smartfly.scp_installed = false
		return false
	end
	smartfly.dref.is_master = ams:map_dref(smartfly.CONF.SCP_MASTER)
	smartfly.scp_installed = true

	smartfly._inited = true
	return true
end

function smartfly.release_all()
	XPLM.XPLMReleasePlanes()
end


function smartfly.smooth_pos(x, y, z)
	local buf = smartfly.buf
	if buf.ai_loc_x ~= nil then
		x = (x + buf.ai_loc_x)/2.0
		y = (y + buf.ai_loc_y)/2.0
		z = (z + buf.ai_loc_z)/2.0
	end
	buf.ai_loc_x = x
	buf.ai_loc_y = y
	buf.ai_loc_z = z

	return x, y, z
end


smartfly.loop = {}
function smartfly.loop.idle(self)
	if smartfly.init() == false then
		self:kill()
		return
	end

	if smartfly.dref.is_master[0] > 0 then
		smartfly.buf.ai_loc_x = nil
		smartfly.buf.ai_loc_y = nil
		smartfly.buf.ai_loc_z = nil
		XPLM.XPLMAcquirePlanes(nil, nil, nil)
		XPLM.XPLMDisableAIForPlane(1)
		ams:exec(smartfly.loop.update_all, "Smart Flying: syncronizing data", ams.C.FRAME_LOOP)
		self:kill()
	end
end

function smartfly.loop.update_all(self)
	smartfly.is_master = smartfly.dref.is_master[0]
	if smartfly.is_master == 0 then
		smartfly.release_all()
		ams:exec(smartfly.loop.idle, "Smart Flying: idle", ams.C.OFTEN_LOOP)
		self:kill()
		return
	-- Checks if the user is master or slave, and set the pointers accordingly
	elseif smartfly.is_master == 2 then
		smartfly.dref.my_data = smartfly.dref.master_data
		smartfly.dref.his_data = smartfly.dref.slave_data
	else
		smartfly.dref.my_data = smartfly.dref.slave_data
		smartfly.dref.his_data = smartfly.dref.master_data
	end

	-- Copy the 'user_plane' dataref's value to 'my_data' which points to the right custom dataref (master or slave)
	for k, v in pairs(smartfly.dref.user_plane) do
		local size = smartfly.dref.plane_data_size[k] or 1
		size = size - 1
		for i = 0,size do
			smartfly.dref.my_data[k][i] = tonumber(v[i])
		end
	end

	-- Converts global lat/lon/elev coordinates to loca x/y/z. [FIX issue #4]
	local loc_x, loc_y, loc_z = graph.world_to_local(smartfly.dref.his_data.lat[0], smartfly.dref.his_data.lon[0], smartfly.dref.his_data.elev[0])
	loc_x, loc_y, loc_z = smartfly.smooth_pos(loc_x, loc_y, loc_z)
	smartfly.dref.ai_plane_local.loc_x[0] = loc_x
	smartfly.dref.ai_plane_local.loc_y[0] = loc_y
	smartfly.dref.ai_plane_local.loc_z[0] = loc_z

	-- Copy the custom dataref's value (master or slave) to the datarefs of 'ai_plane'.
	for k, v in pairs(smartfly.dref.ai_plane) do
		local size = smartfly.dref.plane_data_size[k] or 1
		size = size - 1
		for i = 0,size do
			v[i] = tonumber(smartfly.dref.his_data[k][i])
		end
	end

	-- Copy the custom controls dataref's value (master or slave) to the controls dataref's of 'ai_plane' and
	--   copy the the controls dataref's of 'user_plane' to e custom control's dataref's (master or slave)
	for k, v in pairs(smartfly.dref.controls) do
		v[1] = tonumber(smartfly.dref.his_data[k][0])
		smartfly.dref.my_data[k][0] = tonumber(v[0])
	end
end


ams:exec(smartfly.loop.idle, "SmartFlying: idle", ams.C.OFTEN_LOOP)
ams:exec(smartfly.release_all, "SmartFlying Terminate", ams.C.EXIT_LOOP)

print("[SmartFlying] Loaded v."..smartfly.version.." ("..smartfly.stage..").")

