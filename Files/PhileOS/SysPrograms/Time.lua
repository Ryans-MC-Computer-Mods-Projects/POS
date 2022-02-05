local function cut(str,len,pad)
	pad = pad or " "
	return pad:rep(len - #str) .. str:sub(1,len)
end

local state = 0

while true do
	term.setBackgroundColour(PhileOS.getSetting("theme", "taskbarBGColour"))
	term.setTextColour(PhileOS.getSetting("theme", "taskbarTextColour"))
	term.clear()
	local half = " "
	local tz = PhileOS.getSetting("time", "timezone")
	local autoDST = PhileOS.getSetting("time", "autoDST")
	local autoZone = PhileOS.getSetting("time", "autoTime")
	if math.floor(tz) ~= tz then half = "\189" end
	term.setCursorPos(2, 1)
	if autoZone then term.setTextColour(PhileOS.getSetting("theme", "defDeselTextColour")) end
	if tz > 0 then
		term.write("Timezone:<"..cut("+"..tostring(math.floor(tz)), 3)..half..">")
	else
		term.write("Timezone:<"..cut(tostring(math.ceil(tz)), 3)..half..">")
	end
	term.setTextColour(PhileOS.getSetting("theme", "taskbarTextColour"))
	term.setCursorPos(2, 2)
	term.write("     Auto Zone")
	if autoZone then term.write("*") end
	term.setCursorPos(2, 3)
	term.write("      Auto DST")
	if not autoZone and autoDST then term.write("*") end
	term.setCursorPos(2, 4)
	term.write("       Manual")
	if not autoZone and not autoDST then term.write("*") end
	term.setCursorPos(2, 5)
	term.write(PhileOS.FormatTime("%I:%M:%S %p", os.epoch("utc") / 1000))
	term.setCursorPos(2, 6)
	term.write(PhileOS.FormatTime("%a %b %d %Y", os.epoch("utc") / 1000))
	local e = table.pack(os.pullEvent())
	if e[1] == "mouse_click" then
		if e[3] == 11 and e[4] == 1 and (not autoZone) then state = 1 end
		if e[3] == 16 and e[4] == 1 and (not autoZone) then state = 2 end
		if e[4] == 2 then state = 3 end
		if e[4] == 3 then state = 4 end
		if e[4] == 4 then state = 5 end
	end
	if e[1] == "mouse_up" then
		local statetc = 0
		if e[3] == 11 and e[4] == 1 and (not autoZone) then statetc = 1 end
		if e[3] == 16 and e[4] == 1 and (not autoZone) then statetc = 2 end
		if e[4] == 2 then statetc = 3 end
		if e[4] == 3 then statetc = 4 end
		if e[4] == 4 then statetc = 5 end
		if statetc == state then
			if state == 1 and tz > -12 then
				PhileOS.setSetting(PhileOS.ID, "time", "timezone", PhileOS.getSetting("time", "timezone") - 0.5)
			end
			if state == 2 and tz < 14 then
				PhileOS.setSetting(PhileOS.ID, "time", "timezone", PhileOS.getSetting("time", "timezone") + 0.5)
			end
			if state == 3 then
				PhileOS.setSetting(PhileOS.ID, "time", "autoTime", true)
				PhileOS.setSetting(PhileOS.ID, "time", "autoDST", true)
			end
			if state == 4 then
				PhileOS.setSetting(PhileOS.ID, "time", "autoTime", false)
				PhileOS.setSetting(PhileOS.ID, "time", "autoDST", true)
			end
			if state == 5 then
				PhileOS.setSetting(PhileOS.ID, "time", "autoTime", false)
				PhileOS.setSetting(PhileOS.ID, "time", "autoDST", false)
			end
		end
	end
	local _, _, ro = PhileOS.getProcesses(PhileOS.ID)
	if ro[#ro] ~= PhileOS.ID then PhileOS.stop(PhileOS.ID) end
end