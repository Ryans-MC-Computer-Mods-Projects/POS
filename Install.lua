local RTKrnl = http.get("https://raw.githubusercontent.com/Ryan-CC-Projects/POS/main/Installer/RTKrnl.lua")
local fh = fs.open("/temp/RTKrnl.lua", "w")
fh.write(RTKrnl.readAll())
fh.close()

local Desktop = http.get("https://raw.githubusercontent.com/Ryan-CC-Projects/POS/main/Installer/Desktop.lua")
local fh = fs.open("/temp/Desktop.lua", "w")
fh.write(Desktop.readAll())
fh.close()

local Taskbar = http.get("https://raw.githubusercontent.com/Ryan-CC-Projects/POS/main/Installer/Taskbar.lua")
local fh = fs.open("/temp/Taskbar.lua", "w")
fh.write(Taskbar.readAll())
fh.close()

local System = http.get("https://raw.githubusercontent.com/Ryan-CC-Projects/POS/main/Installer/System.lua")
local fh = fs.open("/temp/System.lua", "w")
fh.write(System.readAll())
fh.close()

local installer = http.get("https://raw.githubusercontent.com/Ryan-CC-Projects/POS/main/Installer/installer.lua")
local fh = fs.open("/temp/installer.lua", "w")
fh.write(installer.readAll())
fh.close()

shell.run("/Temp/RTKrnl")