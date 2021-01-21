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

require("ams.core.kernel")
local ffi = require("ffi")
local XPLM = require("ams.SDK.XPLM")


--
-- FFI Implementation of XPLMMap.h
--
ffi.cdef("typedef void * XPLMMapProjectionID")
ffi.cdef("typedef void * XPLMMapLayerID")
ffi.cdef("typedef int XPLMMapStyle")
ffi.cdef("typedef int XPLMMapLayerType")
ffi.cdef("typedef int XPLMMapOrientation")
ffi.cdef("typedef void (* XPLMMapCreatedCallback_f)( const char * mapIdentifier, void * refcon )")

ffi.cdef[[ typedef void (* XPLMMapDrawingCallback_f)(
		 XPLMMapLayerID       			inLayer,
		 const float *        			inMapBoundsLeftTopRightBottom,
		 float                			zoomRatio,
		 float                			mapUnitsPerUserInterfaceUnit,
		 XPLMMapStyle         			mapStyle,
		 XPLMMapProjectionID  			projection,
		 void *               			inRefcon
	);
]]
ffi.cdef[[ typedef void (* XPLMMapIconDrawingCallback_f)(
		 XPLMMapLayerID 			inLayer,
		 const float * 				inMapBoundsLeftTopRightBottom,
		 float 					zoomRatio,
		 float 					mapUnitsPerUserInterfaceUnit,
		 XPLMMapStyle 				mapStyle,
		 XPLMMapProjectionID			projection,
		 void *					inRefcon
	 );
]]
ffi.cdef[[ typedef void (* XPLMMapLabelDrawingCallback_f)(
		XPLMMapLayerID       			inLayer,
		const float *        			inMapBoundsLeftTopRightBottom,
		float 					zoomRatio,
		float 					mapUnitsPerUserInterfaceUnit,
		XPLMMapStyle 				mapStyle,
		XPLMMapProjectionID 			projection,
		void * 					inRefcon
	);
]]
ffi.cdef[[ typedef void (* XPLMMapPrepareCacheCallback_f)(
		 XPLMMapLayerID 			inLayer,
		 const float * 				inTotalMapBoundsLeftTopRightBottom,
		 XPLMMapProjectionID 			projection,
		 void * 				inRefcon
	 );
]]
ffi.cdef[[ typedef void (* XPLMMapWillBeDeletedCallback_f)(
		 XPLMMapLayerID 			inLayer,
		 void * 				inRefcon
	 );
]]
ffi.cdef[[ typedef struct {
		int 					structSize;
		const char * 				mapToCreateLayerIn;
		XPLMMapLayerType 	 		layerType;
		XPLMMapWillBeDeletedCallback_f 		willBeDeletedCallback;
		XPLMMapPrepareCacheCallback_f 		prepCacheCallback;
		XPLMMapDrawingCallback_f 		drawCallback;
		XPLMMapIconDrawingCallback_f 		iconCallback;
		XPLMMapLabelDrawingCallback_f 		labelCallback;
		int 					showUiToggle;
		const char * 				layerName;
		void * 					refcon;
	} XPLMCreateMapLayer_t;
]]

ffi.cdef("void XPLMDrawMapLabel( XPLMMapLayerID layer, const char * inText, float mapX, float mapY, XPLMMapOrientation orientation, float rotationDegrees )")
ffi.cdef[[ void XPLMDrawMapIconFromSheet( XPLMMapLayerID layer, const char * inPngPath,
			int s, int t, int ds, int dt,
			float mapX, float mapY,
			XPLMMapOrientation orientation,
			float rotationDegrees, float mapWidth
	);
]]

ffi.cdef("void XPLMRegisterMapCreationHook( XPLMMapCreatedCallback_f callback, void * refcon )")
ffi.cdef("int XPLMMapExists( const char * mapIdentifier )")

ffi.cdef("XPLMMapLayerID XPLMCreateMapLayer( XPLMCreateMapLayer_t * inParams )")
ffi.cdef("int XPLMDestroyMapLayer( XPLMMapLayerID inLayer )")

ffi.cdef("void XPLMMapProject( XPLMMapProjectionID projection, double latitude, double longitude, float * outX, float * outY )")
ffi.cdef("void XPLMMapUnproject( XPLMMapProjectionID  projection, float mapX, float mapY, double * outLatitude, double * outLongitude);")
ffi.cdef("float XPLMMapScaleMeter( XPLMMapProjectionID  projection, float mapX, float mapY )")


--
-- Local functions
--
local function create_map(self)
	local create_map_cb = ffi.cast( "XPLMMapCreatedCallback_f", function(mapID) print("[ams/SDK/map] Executing callback for layer '"..self.name.."'.") return self:create_lay_f(mapID) end )
 	XPLM.XPLMRegisterMapCreationHook(create_map_cb, ffi.NULL)

	if XPLM.XPLMMapExists(self.mapType) == 1 then
		print("[ams/SDK/map] Creating layer '"..self.name.."'.")
		self:create_lay_f()
	end
end

local function destroy_layer(self)
	print("[ams/SDK/map] Destroying Map Layer "..tostring(self.mapLayer_h))
	XPLM.XPLMDestroyMapLayer(self.mapLayer_h)
end

local function create_layer(self, mapID)
	local layer_struct = ffi.new("XPLMCreateMapLayer_t ", {
		structSize= 			ffi.sizeof("XPLMCreateMapLayer_t"),
		mapToCreateLayerIn= 		self.mapType,
		layerType= 			self.layerType,
		willBeDeletedCallback= 		ffi.cast("XPLMMapWillBeDeletedCallback_f", self.destroy_cb or ffi.NULL),
		prepCacheCallback= 		ffi.cast("XPLMMapPrepareCacheCallback_f", self.buildCache_cb or ffi.NULL),
		drawCallback= 			ffi.cast("XPLMMapDrawingCallback_f", self.draw_cb or ffi.NULL),
		iconCallback= 			ffi.cast("XPLMMapIconDrawingCallback_f", self.drawIcon_cb or ffi.NULL),
		labelCallback= 			ffi.cast("XPLMMapLabelDrawingCallback_f", self.drawLabel_cb or ffi.NULL),
		showUiToggle= 			self.show,
		layerName= 			self.name,
		refcon= 			ffi.NULL,
	})

	if mapID ~= nil then
		local ident = ffi.string(mapID, ffi.sizeof(mapID))
		print("[ams/SDK/map] Active map type is: "..ident)
		if ident == "XPLM_MAP" then
			self.mapLayer_h = XPLM.XPLMCreateMapLayer(layer_struct)
		end
	else
		print("[ams/SDK/map] No active map available")
		self.mapLayer_h = XPLM.XPLMCreateMapLayer(layer_struct)
	end
	print("[ams/SDK/map] Created layer '"..self.name.."'.")

	ams:exec(destroy_layer, "MapLayer '"..self.name.."': Terminator", ams.C.EXIT_LOOP).mapLayer_h = self.mapLayer_h
	return true
end


--
-- Public functions
--
local map = {
	-- enums for Map Type (to create layer in)
	MAP_USER_INTERFACE 		= "XPLM_MAP_USER_INTERFACE",
	MAP_IOS 			= "XPLM_MAP_IOS",
	-- enums for XPLMMapLayerType
	MapLayer_Fill 			= 0,
	MapLayer_Markings 		= 1,
	-- enums for XPLMMapOrientation
	MapOrientation_Map 		= 0,
	MapOrientation_UI 		= 1,
	-- enums for XPLMMapStyle
	MapStyle_VFR_Sectional 		= 0,
	MapStyle_IFR_LowEnroute 	= 1,
	MapStyle_IFR_HighEnroute 	= 2,
}

map.class = {
	mapType 		= map.MAP_USER_INTERFACE,
	layerType 		= map.MapLayer_Markings,
	destroy_cb 		= nil,
	buildCache_cb 		= nil,
	draw_cb 		= nil,
	drawIcon_cb 		= nil,
	drawLabel_cb 		= nil,
	show 			= 1,
	name 			= "",
	create 			= create_map,
	create_lay_f 		= create_layer,
}

function map.new(name, options)
	name = name or "LAYER"
	options = options or {}
	local new_map = setmetatable(options, { __index = map.class})
	new_map.name = name

	return new_map
end

function map.coord_in_bound(x, y, bound)
	return (x >= bound[0]) and (x < bound[2]) and (y >= bound[3]) and (y < bound[1])
end

function map.project(projection, lat, lon)
	local out_x = ffi.new("float[1]", 0)
	local out_y = ffi.new("float[1]", 0)
	local in_lat = ffi.new("double", tonumber(lat))
	local in_lon = ffi.new("double", tonumber(lon))
	XPLM.XPLMMapProject(projection, in_lat, in_lon, out_x, out_y)

	return out_x[0], out_y[0]
end

function map.scale_meter(projection, bound)
	local mid_x = (bound[0]-bound[2])/2
	local mid_y = (bound[1]-bound[3])/2

	return XPLM.XPLMMapScaleMeter(projection, mid_x, mid_y)
end

function map.draw_label(layer, text, map_x, map_y, orient, rotate)
	orient = orient or 0
	rotate = rotate or 0

	XPLM.XPLMDrawMapLabel(layer, text, map_x, map_y, orient, rotate)
end

function map.draw_icon(layer, icon_file, width, map_x, map_y, orient, rotate, s, t, ds, dt )
	orient = orient or 0
	rotate = rotate or 0
	s = s or 0
	t = t or 0
	ds = ds or 1
	dt = dt or 1

	XPLM.XPLMDrawMapIconFromSheet(layer, icon_file, s, t, ds, dt, map_x, map_y, orient, rotate, width)
end


print("[ams/SDK/maps] XPLMMap Module loaded.")

return map, XPLM

