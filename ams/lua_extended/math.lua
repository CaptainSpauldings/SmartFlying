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

math.STANDARD_EARTH_RADIUS_KM = 6378

function math.round(num, floats)
	floats = floats or 0
	local exp = 10^floats

	return math.floor(num*exp+0.5)/exp
end

function math.geo_distance(lat1, lon1, lat2, lon2)
	--This function returns great circle distance between 2 points.
	--Found here: http://bluemm.blogspot.gr/2007/01/excel-formula-to-calculate-distance.html
	--lat1, lon1 = the coords from start position (or aircraft's) / lat2, lon2 coords of the target waypoint.
	--6371km is the mean radius of earth in meters. Since X-Plane uses 6378 km as radius, which does not makes a big difference,
	--(about 5 NM at 6000 NM), we are going to use the same.
	--Other formulas I've tested, seem to break when latitudes are in different hemisphere (west-east).
	local distance = math.acos(math.cos(math.rad(90-lat1))*math.cos(math.rad(90-lat2))+
		math.sin(math.rad(90-lat1))*math.sin(math.rad(90-lat2))*math.cos(math.rad(lon1-lon2))) * math.STANDARD_EARTH_RADIUS_KM
	return distance --> in kilometers
end

