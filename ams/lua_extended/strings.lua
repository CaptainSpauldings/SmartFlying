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

function string.split(str, sep)
	local result = {}
	local regex = ("([^%s]+)"):format(sep)
	for each in str:gmatch(regex) do
		table.insert(result, each)
	end
	return result
end

function string.parseCSVLine(self, sep)
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do
		local c = string.sub(self,pos,pos)
		if (c == "") then break end
		if (c == '"') then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(self,'^%b""',pos)
				txt = txt..string.sub(self,startp+1,endp-1)
				pos = endp + 1
				c = string.sub(self,pos,pos)
				if (c == '"') then txt = txt..'"' end
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			pos = pos + 1
		else
			-- no quotes used, just look for the first separator
			local startp,endp = string.find(self,sep,pos)
			if (startp) then
				table.insert(res,string.sub(self,pos,startp-1))
				pos = endp + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(self,pos))
				break
			end
		end
	end
	return res
end

function string.tokenize(self)
	local ret = {}
	for word in self:gmatch("%S+") do
		table.insert(ret, word)
	end
	return ret
end

function string.contains(self, pattern)
	if type(pattern) ~= "table" then
		pattern = { pattern }
	end
	for _, v in pairs(pattern) do
		if self:find(".*"..v..".*") ~= nil then
			return true
		end
	end
	return false
end


