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

local ffi = require("ffi")
local XPLM = require("ams.SDK.XPLM")
print("[ams/SDK/menus] XPLM module loaded.")

ffi.cdef("typedef void * XPLMMenuID")
ffi.cdef("typedef int XPLMMenuCheck")
ffi.cdef("typedef void (* XPLMMenuHandler_f)( void * inMenuRef, void * inItemRef)")
ffi.cdef("typedef void * XPLMCommandRef")

ffi.cdef("XPLMMenuID XPLMFindAircraftMenu( void )")
ffi.cdef("XPLMMenuID XPLMFindPluginsMenu( void )")

ffi.cdef("XPLMMenuID XPLMCreateMenu( const char * inName, XPLMMenuID inParentMenu, int inParentItem, XPLMMenuHandler_f inHandler, void * inMenuRef )")
ffi.cdef("void XPLMDestroyMenu( XPLMMenuID inMenuID )")

ffi.cdef("void XPLMClearAllMenuItems( XPLMMenuID inMenuID )")
ffi.cdef("int XPLMAppendMenuItem( XPLMMenuID inMenu, const char * inItemName, void * inItemRef, int inDeprecatedAndIgnored )")
ffi.cdef("int XPLMAppendMenuItemWithCommand( XPLMMenuID inMenu, const char * inItemName, XPLMCommandRef inCommandToExecute )")
ffi.cdef("void XPLMAppendMenuSeparator( XPLMMenuID inMenu )")
ffi.cdef("void XPLMSetMenuItemName( XPLMMenuID inMenu, int inIndex, const char * inItemName, int inDeprecatedAndIgnored )")
ffi.cdef("void XPLMCheckMenuItem( XPLMMenuID inMenu, int index, XPLMMenuCheck inCheck )")
ffi.cdef("void XPLMCheckMenuItemState( XPLMMenuID inMenu, int index, XPLMMenuCheck * outCheck )")
ffi.cdef("void XPLMEnableMenuItem( XPLMMenuID inMenu, int index, int enabled )")
ffi.cdef("void XPLMRemoveMenuItem( XPLMMenuID inMenu, int inIndex )")

return XPLM

