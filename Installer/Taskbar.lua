package.path = "/PhileOS/APIs/?.lua;"..package.path
local function cut(str,len,pad)
  pad = pad or " "
  return str:sub(1,len) .. pad:rep(len - #str)
end
local click = 0
local Sx, Sy = term.getSize()
local TimeID = nil
local scroll = 0
local openInstall = true
local ID = 0

while true do
	term.setBackgroundColour(1)
	term.clear()

	term.setCursorPos(1, 1)
	term.blit("\136\149\132", "0e0", "edd")
	term.setCursorPos(1, 2)
	term.blit("\133\136\140", "e00", "0bb")
	term.setCursorPos(1, 3)
	term.blit("\140\140\142", "bbb", "000")
	term.setBackgroundColour(1)
	term.setTextColour(32768)
	local status = 0
	if not openInstall then 
		status = PhileOS.getStatus(ID)
	end
	if status == 1 then
		term.setBackgroundColour(8)
	elseif status == 2 then
		term.setBackgroundColour(2048)
	end
	term.setCursorPos(1, 4)
	term.write("\183Do")
	term.setCursorPos(1, 5)
	term.write("wnl")
	term.setCursorPos(1, 6)
	term.write("oad")
	term.setCursorPos(1, 7)
	term.write("fil")
	term.setCursorPos(1, 8)
	term.write("es.")
	if status == 1 then
		term.setBackgroundColour(1)
	elseif status == 2 then
		term.setBackgroundColour(8)
	elseif status == 3 then
		term.setBackgroundColour(2048)
	end
	term.setCursorPos(1, 10)
	term.write("\183Se")
	term.setCursorPos(1, 11)
	term.write("tup")
	term.setCursorPos(1, 12)
	term.write("the")
	term.setCursorPos(1, 13)
	term.write("OS.")

	term.setCursorPos(1, Sy - 1)
	term.setBackgroundColour(1)
	term.setTextColour(32768)
	local hour = PhileOS.FormatTime("%I")
	if #hour == 1 then
		hour = "0"..hour
	end
	term.write(hour..PhileOS.FormatTime("%p"):sub(1, 1))
	term.setCursorPos(1, Sy)
	term.write(PhileOS.FormatTime("%MM"))

	e = table.pack(os.pullEvent())
	Sx, Sy = term.getSize()
	if openInstall then
		_, ID = PhileOS.openProgramAsSP(PhileOS.ID, "temp/installer.lua")
        openInstall = false
    end
end
