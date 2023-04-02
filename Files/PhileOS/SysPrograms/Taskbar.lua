package.path = "/PhileOS/APIs/?.lua;"..package.path
local Phicon = require("Phicon")

local function cut(str,len,pad)
  pad = pad or " "
  if len > #str then
	return str:sub(1,len) .. pad:rep(len - #str)
  else
  	return str:sub(1,len)
  end
end
local click = 0
local Sx, Sy = term.getSize()
local TimeID = nil
local scroll = 0

while true do
	term.setBackgroundColour(PhileOS.getSetting("theme", "taskbarBGColour"))
	term.clear()
	local success, processIDs, render, mini = PhileOS.getProcesses(PhileOS.ID)
	if PhileOS.getIsLocked() then processIDs = {} end
	local isMinied = {}
	for i, v in pairs(mini) do
		isMinied[v] = true
	end
	local thing = 0
	local TimeIsStillThere = false
	for i, v in pairs(processIDs) do
		if v == TimeID then
			TimeIsStillThere = true
		elseif not PhileOS.getIsBG(v) and v ~= PhileOS.ID and PhileOS.getHasWinDecor(v) then
			thing = thing + 1
			if isMinied[v] then
				term.setBackgroundColour(PhileOS.getSetting("theme", "taskbarBGColour"))
			else
				term.setBackgroundColour(PhileOS.getSetting("theme", "taskbarShownWinIconColour"))
			end
			term.setTextColour(PhileOS.getSetting("theme", "taskbarTextColour"))
			term.setCursorPos(1, thing * 3 + 1 - scroll)
			term.write(cut(PhileOS.getName(v), 3))
			term.setCursorPos(1, thing * 3 + 2 - scroll)
			term.write(cut(PhileOS.getName(v):sub(4), 3))
		end
	end
	Phicon.renderFile(1, 1, PhileOS.getSetting("theme", "taskbarBGColour"), "/PhileOS/Icons/POS.phico")
	if not TimeIsStillThere then TimeID = nil end
	term.setCursorPos(1, Sy - 1)
	term.setBackgroundColour(PhileOS.getSetting("theme", "taskbarBGColour"))
	term.setTextColour(PhileOS.getSetting("theme", "taskbarTextColour"))
	local hour = PhileOS.FormatTime("%I")
	--if tonumber(hour) < 10 then hour = "0"..hour end
	term.write(hour..PhileOS.FormatTime("%p"):sub(1, 1))
	term.setCursorPos(1, Sy)
	term.write(PhileOS.FormatTime("%MM"))
	e = table.pack(os.pullEvent())
	Sx, Sy = term.getSize()
	if e[1] == "mouse_click" and not PhileOS.getIsLocked() then
		if e[4] >= Sy - 1 then click = -2 else
			click = math.floor(e[4] / 3)
			if click ~= 0 and e[4] % 3 == 0 then click = -1 end
		end
	else click = nil end
	if e[1] == "mouse_scroll" and not PhileOS.getIsLocked() then
		scroll = scroll + e[2]
		if scroll > thing * 3 - (Sy - 4) then scroll = thing * 3 - (Sy - 4) end
		if scroll < 0 then scroll = 0 end
	end
	if e[1] == "mouse_up" and not PhileOS.getIsLocked() then
		local clicktc = 0
		if e[4] >= Sy - 1 then clicktc = -2 else
			clicktc = math.floor(e[4] / 3)
			if clicktc ~= 0 and e[4] % 3 == 0 then clicktc = -1 end
		end
		if clicktc == click or click == nil then
			if clicktc == 0 then--Click Start Menu
				local file = fs.open("/PhileOS/Settings/start.set", "r")
				local pins = textutils.unserialise(file.readAll())
				file.close()
				local pinnames = {}
				for i, v in pairs(pins) do
					table.insert(pinnames, i, fs.getName(v))
				end
				local option = nil
				local ets = "Exit To Shell"
				local usertype = PhileOS.getUserType()
				if usertype ~= "Admin" and usertype ~= "No Users" then
					ets = nil
				end
				if #pins == 0 then
					option = PhileOS.openRClick(PhileOS.ID, 4, 1, {"Explorer", "Lock", "Shutdown", "Reboot", ets})
				else
					local smt = {"", "Remove Pin", "", "Explorer", "Lock", "Shutdown", "Reboot", ets}
					for i, v in pairs(pinnames) do
						table.insert(smt, i, v)
					end
					option = PhileOS.openRClick(PhileOS.ID, 4, 1, smt)
				end
				if option == "Explorer" then
					PhileOS.openProgram("PhileOS/explorer.lua")
				elseif option == "Lock" then
					PhileOS.openProgram("startup.lua")
				elseif option == "Shutdown" then
					os.shutdown()
				elseif option == "Reboot" then
					os.reboot()
				elseif option == "Exit To Shell" then
					PhileOS.stopAll(PhileOS.ID)
				elseif option == "Remove Pin" then
					local ppr = PhileOS.openRClick(PhileOS.ID, 4, 1, pinnames)
					for i, v in pairs(pinnames) do
						if ppr == v then
							table.remove(pins, i)
							table.remove(pinnames, i)
							local file = fs.open("/PhileOS/Settings/start.set", "w")
							file.write(textutils.serialise(pins))
							file.close()
						end
					end
				else
					for i, v in pairs(pinnames) do
						if option == v then
							PhileOS.OpenFile(pins[i])
						end
					end
				end
			elseif clicktc == -2 then--Click the time
				_, TimeID = PhileOS.openProgramAsSP(PhileOS.ID, "/PhileOS/SysPrograms/Time.lua", 4, Sy - 5, 16, 6, false)
			elseif clicktc > 0 then--Click Icon
				local thing = 0
				for i, v in pairs(processIDs) do
					if not PhileOS.getIsBG(v) and v ~= PhileOS.ID and PhileOS.getHasWinDecor(v) then
						thing = thing + 1
						if thing == clicktc then
							PhileOS.UnMini(v)
							PhileOS.pushToTop(PhileOS.ID, v)
						end
					end
				end
			end
		end
	end
end