--Phile OS RT Kernel

local RTLog = {}

local OGTerm = term.current() --Terminal to return to after the program is finished

----Error handling
local ok, err = pcall(function()
if PhileOS then
	error("PhileOS is already running!")
end
----Variables

local clipboard = ""

--Old CC:T Version Support
if not colors.toBlit then
	local color_hex_lookup = {}
	for i = 0, 15 do
    	color_hex_lookup[2 ^ i] = string.format("%x", i)
	end
	function toBlit(color)
		expect(1, color, "number")
		return color_hex_lookup[color] or
			string.format("%x", math.floor(math.log(color) / math.log(2)))
	end
	colors.toBlit = toBlit
	colours.toBlit = toBlit
end

--Tables for processes and order to run coroutines and render
local processes = {}
local renderOrder = {}
local minied = {}
local locked = {}
local coroutineOrder = {}
local services = {}
local serviceArguments = {}
local taskbarTask = 0
local desktopTask = 0

--Terminals
local buffer = window.create(OGTerm, 1, 1, 1, 1, false) --Buffer terminal to return to after coroutines
--Dummy terminal to prevent background processes from writing to main terminal
local dummyTerm = setmetatable({
  isColor = function() return false end,
  getCursorPos = function() return 1, 1 end,
  getCursorBlink = function() return true end,
  getBackgroundColor = function() return colors.black end,
  getTextColor = function() return colors.white end,
  getPaletteColor = function() return 0, 0, 0 end,
  isColour = function() return false end,
  getBackgroundColour = function() return colors.black end,
  getTextColour = function() return colors.white end,
  getPaletteColour = function() return 0, 0, 0 end,
  getSize = function() return 51, 19 end,
}, {__index = function() return function() end end}) 

--Settings
local setfile = fs.open("/PhileOS/Settings/main.set", "r")
local settings = textutils.unserialize(setfile.readAll())
setfile.close()

--Exit To Shell
local Exit = false

--BlitToNum
local BlitToNum = {
  ["0"] = 1,
  ["1"] = 2,
  ["2"] = 4,
  ["3"] = 8,
  ["4"] = 16,
  ["5"] = 32,
  ["6"] = 64,
  ["7"] = 128,
  ["8"] = 256,
  ["9"] = 512, 
  a = 1024,
  b = 2048,
  c = 4096,
  d = 8192,
  e = 16384,
  f = 32768,
}

local isLocked = false

----Functions

--addProcress: Adds a process to the processes list and creates a window if needed
local function addProcress(Program, isBG, X, Y, Sx, Sy, hasWinDecor, SP, ...)
	local newProcess = {}
	local processID = nil
	while processID == nil do
		processID = math.random(2000000000)
		if processes[processID] then processID = nil end
	end
	local modOS = {}
	for i, v in pairs(os) do
		modOS[i] = v
	end
	if Program ~= "startup.lua" and Program ~= "/startup.lua" then
		modOS.pullEventRaw = os.pullEvent
	end
	local env = setmetatable({
	  PhileOS = {
		RootProgram = Program,
	    openProgram = function(name, X, Y, Sx, Sy, ...)
			local six, siy = buffer.getSize()
			Sx = Sx or 51
			if Sx > six - 20 then Sx = six - 20 end
			Sy = Sy or 19
			if Sy > siy - 10 then Sy = siy - 10 end
			X = X or math.ceil(six / 2) - math.floor(Sx / 2)
			Y = Y or math.ceil(siy / 2) - math.floor(Sy / 2)
			return addProcress(name, false, X, Y, Sx, Sy, true, false, table.unpack({...}))
	    end,
		openProgramAsSP = function(IDtC, name, X, Y, Sx, Sy, HasWinDecor, ...)
			if processes[IDtC] then
				if processes[IDtC].SP then
					local six, siy = term.getSize()
					Sx = Sx or 51
					Sy = Sy or 19
					X = X or six / 2 + math.floor(Sx / 2)
					Y = Y or siy / 2 + math.floor(Sy / 2)
					return true, addProcress(name, false, X, Y, Sx, Sy, HasWinDecor, true, table.unpack({...}))
				end
			end
			return false
	    end,
		getIsLocked = function()
			return isLocked
		end,
		setClipboard = function(CB)
			clipboard = CB
		end,
		getClipboard = function()
			return clipboard
		end,
		setStatus = function(ID, Status)
			processes[ID].status = Status
		end,
		getStatus = function(ID)
			return processes[ID].status
		end,
		setName = function(ID, Name)
			processes[ID].name = Name
		end,
		getName = function(ID)
			return processes[ID].name
		end,
		setCanResize = function(ID, CR)
			processes[ID].CR = CR
		end,
		setSize = function(ID, Sx, Sy)
			local x, y = processes[ID].win.getPosition()
			processes[ID].win.reposition(x, y, Sx, Sy)
		end,
		getIsBG = function(ID)
			return processes[ID].isBG
		end,
		getHasWinDecor = function(ID)
			return processes[ID].hasWinDecor
		end,
		openDialog = function(ID, style, options)
			local Tx, Ty = buffer.getSize()
			local PID = -10
			if style == "button" then
				PID = addProcress("/PhileOS/SysPrograms/Dialogs/Button.lua", false, math.ceil(Tx / 2) - 15, math.ceil(Ty / 2) - 4, 30, 10, true, false, table.unpack(options))
			elseif style == "textInput" then
				PID = addProcress("/PhileOS/SysPrograms/Dialogs/TextInput.lua", false, math.ceil(Tx / 2) - 15, math.ceil(Ty / 2) - 4, 30, 10, true, false, table.unpack(options))
			elseif style == "openFile" then
				local Sx = 51
				if Sx > Tx - 20 then Sx = Tx - 20 end
				local Sy = 19
				if Sy > Ty - 10 then Sy = Ty - 10 end
				PID = addProcress("/PhileOS/explorer.lua", false, math.ceil(Tx / 2) - 15, math.ceil(Ty / 2) - 4, Sx, Sy, true, true, options[1], "open")
			elseif style == "saveFile" then
				local Sx = 51
				if Sx > Tx - 20 then Sx = Tx - 20 end
				local Sy = 19
				if Sy > Ty - 10 then Sy = Ty - 10 end
				PID = addProcress("/PhileOS/explorer.lua", false, math.ceil(Tx / 2) - 15, math.ceil(Ty / 2) - 4, Sx, Sy, true, true, options[1], "save")
			end
			if PID ~= -10 then
				local moveon = false
				while not moveon do
					if not processes[PID] then
						return nil
					end
					if processes[PID].status ~= "" then moveon = true end
					if renderOrder[#renderOrder] == ID then
						for i, v in pairs(renderOrder) do
							if v == PID then
								table.remove(renderOrder, i)
								table.insert(renderOrder, v)
							end
						end
					end
					coroutine.yield()
				end
				local status = processes[PID].status
				for i, v in pairs(coroutineOrder) do
					if v == PID then
						table.remove(coroutineOrder, i)
						break
					end
				end
				if not processes[PID].isBG then
					for i, v in pairs(renderOrder) do
						if v == PID then
							table.remove(renderOrder, i)
							break
						end
					end
				end
				processes[PID] = nil
				return status
			end
		end,
		openRClick = function(ID, Xw, Yw, options, varWidth)
			table.insert(options, 1, ID)
			local Wx, Wy = processes[ID].win.getPosition()
			local Tx, Ty = buffer.getSize()
			local X = Wx + Xw - 1
			if X > Tx - 29 then X = Tx - 29 end
			local Y = Wy + Yw - 1
			if Y > Ty - (#options + 2) + 1 then Y = Ty - (#options + 2) + 1 end
			local Xs = 30
			if varWidth then
				Xs = 2
				for i, v in pairs(options) do
					if i ~= 1 then
						if #tostring(v) + 2 > Xs then
							Xs = #tostring(v) + 2
						end
					end
				end
			end
			coroutine.yield()
			local PID = addProcress("/PhileOS/SysPrograms/Dialogs/rClick.lua", false, X, Y, Xs, #options + 1, false, true, table.unpack(options))
			local moveon = false
			local rn = false
			while not moveon do
				if not processes[PID] then
					return nil
				end
				if renderOrder[#renderOrder] ~= PID then moveon = true rn = true end 
				if processes[PID].status ~= "" then moveon = true end
				coroutine.yield()
			end
			local status = processes[PID].status
			if rn then status = nil end
			for i, v in pairs(coroutineOrder) do
				if v == PID then
					table.remove(coroutineOrder, i)
					break
				end
			end
			if not processes[PID].isBG then
				for i, v in pairs(renderOrder) do
					if v == PID then
						table.remove(renderOrder, i)
						break
					end
				end
			end
			processes[PID] = nil
			return status
		end,
		UnMini = function(ID)
			if processes[ID].mini then
				for i,u in pairs(minied) do
					if u == ID then
						table.remove(minied, i)
						break
					end
				end
				table.insert(renderOrder, ID)
			end
		end,
		stop = function(ID)
			for i, v in pairs(coroutineOrder) do
				if v == ID then
					table.remove(coroutineOrder, i)
					break
				end
			end
			if not processes[ID].isBG then
				for i, v in pairs(renderOrder) do
					if v == ID then
						table.remove(renderOrder, i)
						break
					end
				end
			end
			processes[ID] = nil
		end,
		stopAll = function(IDtC)
			if not processes[IDtC].SP then return false end
			Exit = true
		end,
		getProcesses = function(ID)
			if processes[ID] then
				if processes[ID].SP then
					return true, coroutineOrder, renderOrder, minied
				end
			end
			return false
		end,
		pushToTop = function(IDtC, ID)
			if processes[IDtC] then
				if processes[IDtC].SP then
					for i, v in pairs(renderOrder) do
						if v == ID then
							table.remove(renderOrder, i)
							table.insert(renderOrder, v)
							return true, true
						end
					end
					return true, false
				end
			end
			return false
		end,
		getSettings = function()
			return settings
		end,
		getCategory = function(category)
			return settings[category]
		end,
		getSetting = function(category, setting)
			if settings[category][setting] ~= nil then
				return settings[category][setting], true
			end
			return nil, false
		end,
		setSetting = function(IDtC, category, setting, value)
			if processes[IDtC] then
				if processes[IDtC].SP then
					if settings[category][setting] ~= nil then
						settings[category][setting] = value
						setfile = fs.open("/PhileOS/Settings/main.set", "w")
						setfile.write(textutils.serialise(settings))
						setfile.close()
						return true, true
					end
					return true, false
				end
			end
			return false
		end,
		askForSP = function(ID)
			local Tx, Ty = buffer.getSize()
			local PID = -10
			PID = addProcress("/PhileOS/SysPrograms/Dialogs/Button.lua", false, math.floor(Tx / 2) - 15, math.floor(Ty / 2) - 4, 30, 20, true, false, "Do you want to give\n"..processes[ID].name.."\nSP permissions?", "Yes", "No", "", "")
			if PID ~= -10 then
				local moveon = false
				while not moveon do
					if not processes[PID] then
						return nil
					end
					if processes[PID].status ~= "" then moveon = true end
					if renderOrder[#renderOrder] == ID then
						for i, v in pairs(renderOrder) do
							if v == PID then
								table.remove(renderOrder, i)
								table.insert(renderOrder, v)
							end
						end
					end
					coroutine.yield()
				end
				local status = processes[PID].status
				for i, v in pairs(coroutineOrder) do
					if v == PID then
						table.remove(coroutineOrder, i)
						break
					end
				end
				if not processes[PID].isBG then
					for i, v in pairs(renderOrder) do
						if v == PID then
							table.remove(renderOrder, i)
							break
						end
					end
				end
				processes[PID] = nil
				if status == "Yes" then
					processes[ID].SP = true
					return true
				end
				return false
			end
		end,
		FormatTime = function(pattern, overrideTime)
			overrideTime = overrideTime or os.epoch("utc") / 1000
			if settings.time.autoTime then
				return os.date(pattern, overrideTime)
			elseif settings.time.autoDST then
				local tab = os.date("*t", overrideTime)
				local tta = settings.time.timezone * 3600
				if tab then tta = tta + 3600 end
				return os.date("!"..pattern, overrideTime + tta)
			else
				return os.date("!"..pattern, overrideTime + settings.time.timezone * 3600)
			end
		end,
		OpenFile = function(file)
			local dot = string.find(string.reverse(file), "%.")
            local ext = "File"
            if dot then
                dot = #file - dot + 1
                ext = string.sub(file, dot + 1)
            end
			if fs.isDir(file) then ext = "Folder" end
            local openWith = settings.openWith[ext]
            if settings.openWith[ext] then
                if openWith == "rom/execute" then
                    local six, siy = buffer.getSize()
					Sx = 51
					if Sx > six - 20 then Sx = six - 20 end
					Sy =  19
					if Sy > siy - 10 then Sy = siy - 10 end
					return addProcress(file, false, math.ceil(six / 2) - math.floor(Sx / 2), math.ceil(siy / 2) - math.floor(Sy / 2), Sx, Sy, true, false), openWith
                else
                    local six, siy = buffer.getSize()
					Sx = 51
					if Sx > six - 20 then Sx = six - 20 end
					Sy =  19
					if Sy > siy - 10 then Sy = siy - 10 end
					return addProcress(openWith, false, math.ceil(six / 2) - math.floor(Sx / 2), math.ceil(siy / 2) - math.floor(Sy / 2), Sx, Sy, true, false, file), openWith
                end
			else
				return nil
            end
		end,
		OpenWith = function(file)
			local dot = string.find(string.reverse(file), "%.")
            local ext = "File"
            if dot then
                dot = #file - dot + 1
                ext = string.sub(file, dot + 1)
            end
			if fs.isDir(file) then ext = "Folder" end

			local fileset = fs.open("/PhileOS/Settings/openWith.set", "r")
			local options = textutils.unserialise(fileset.readAll())
			table.insert(options, "rom/Other")
			fileset.close()
			local Tx, Ty = buffer.getSize()
			local PID = addProcress("/PhileOS/SysPrograms/Dialogs/openWith.lua", false, math.ceil(Tx / 2) - 15, math.ceil(Ty / 2) - math.floor((#options + 4) / 2), 30, #options + 4, false, true, table.unpack(options))
			local moveon = false
			local rn = false
			while not moveon do
				if not processes[PID] then
					return nil
				end
				if processes[PID].status ~= "" then moveon = true end
				coroutine.yield()
			end
			local status = processes[PID].status
			for i, v in pairs(coroutineOrder) do
				if v == PID then
					table.remove(coroutineOrder, i)
					break
				end
			end
			if not processes[PID].isBG then
				for i, v in pairs(renderOrder) do
					if v == PID then
						table.remove(renderOrder, i)
						break
					end
				end
			end
			processes[PID] = nil
			if fs.exists(status) then
				local PID = -10
				PID = addProcress("/PhileOS/SysPrograms/Dialogs/Button.lua", false, math.ceil(Tx / 2) - 15, math.ceil(Ty / 2) - 4, 30, 20, true, false, "Do you want this to be  the default way to open "..ext.." files?", "Yes", "No", "", "")
				local status2 = "No"
				if PID ~= -10 then
					local moveon = false
					while not moveon do
						if not processes[PID] then
							return nil
						end
						if processes[PID].status ~= "" then moveon = true end
						if renderOrder[#renderOrder] == ID then
							for i, v in pairs(renderOrder) do
								if v == PID then
									table.remove(renderOrder, i)
									table.insert(renderOrder, v)
								end
							end
						end
						coroutine.yield()
					end
					status2 = processes[PID].status
					for i, v in pairs(coroutineOrder) do
						if v == PID then
							table.remove(coroutineOrder, i)
							break
						end
					end
					if not processes[PID].isBG then
						for i, v in pairs(renderOrder) do
							if v == PID then
								table.remove(renderOrder, i)
								break
							end
						end
					end
					processes[PID] = nil
				end
				if status2 == "Yes" then
					settings.openWith[ext] = status
					setfile = fs.open("/PhileOS/Settings/start.set", "w")
					setfile.write(textutils.serialise(settings))
					setfile.close()
				end
				local six, siy = buffer.getSize()
				Sx = 51
				if Sx > six - 20 then Sx = six - 20 end
				Sy = 19
				if Sy > siy - 10 then Sy = siy - 10 end
				X = X or math.ceil(six / 2) - math.floor(Sx / 2)
				Y = Y or math.ceil(siy / 2) - math.floor(Sy / 2)
				return addProcress(status, false, X, Y, Sx, Sy, true, false, file)
			else
				
			end
		end,
		GetExt = function(file)
			local dot = string.find(string.reverse(file), "%.")
            local ext = "File"
            if dot then
                dot = #file - dot + 1
                ext = string.sub(file, dot + 1)
            end
			if fs.isDir(file) then ext = "Folder" end
			return ext
		end,
		HostService = function(ID, service)
			table.insert(services, {ID, service})
		end,
		UnhostService = function(ID, service)
			toDelete = {}
			for i, v in pairs(services) do
				if v[1] == ID and v[2] == service then
					table.insert(toDelete, i)
				end
			end
			for i = #toDelete, 1, -1 do
				v = toDelete[i]
				table.remove(services, v)
			end
		end,
		LookupService = function(service)
			local ret = {}
			for i, v in pairs(services) do
				if v[2] == service then
					table.insert(ret, i)
				end
			end
			return ret
		end,
		RequestService = function(ID, ...)
			serviceArguments[ID] = {false, ...}
			local compTime = os.clock()
			while true do
				if os.clock() - compTime >= 5000 then
					return false, "Request timed out."
				end
				if serviceArguments[ID][1] == true then
					table.remove(serviceArguments[ID], 1)
					return true, table.unpack(serviceArguments[ID])
				end
				sleep()
			end
		end,
		WaitForRequest = function(ID)
			hosted = {}
			for i, v in pairs(services) do
				if v[1] == ID then
					table.insert(hosted, i)
				end
			end
			while true do
				for i, v in pairs(hosted) do
					if serviceArguments[v] ~= nil then
						local ret = {}
						for n = 2, #serviceArguments[v] do
							ret[n - 1] = serviceArguments[v][n]
						end
						return v, table.unpack(ret)
					end
				end
				sleep()
			end
		end,
		ReturnRequest = function(ID, ...)
			serviceArguments[ID] = {true, ...}
		end,
		ID = processID
	  },
	  os = modOS,
	}, {__index = _ENV})
	local fn, err = loadfile(Program, nil, env)
	newProcess.cor = coroutine.create(function(...) 
		if not fn then printError(err) while true do coroutine.yield() end end
		local ok, err = pcall(fn, table.unpack({...}))
		if not ok and (err ~= "Terminated" and err ~= "") then
			term.clear()
			term.setCursorPos(1, 1)
			printError(err)
			while true do coroutine.yield() end
		end
		if Program == "startup.lua" or Program == "/startup.lua" then
			isLocked = false
			local i = 1
			while i <= #locked do
				table.insert(renderOrder, #renderOrder, locked[i])
				table.remove(locked, i)
			end
		end
	end)
	newProcess.isBG = isBG
	--newProcess.name = string.sub(Program, #Program + 2 - (string.find(string.reverse(Program), "/") or #Program + 1), string.find(Program, "%.") - 1)
	local dot = string.find(string.reverse(Program), "%.")
    if dot then
        dot = #Program - dot + 1
        local ext = string.sub(Program, dot + 1)
		newProcess.name = fs.getName(Program):sub(1, -(#ext + 2))
	else
		newProcess.name = fs.getName(Program)
    end
	if Program == "startup.lua" or Program == "/startup.lua" then
		isLocked = true
		newProcess.locker = true
		local i = 1
		while i <= #renderOrder do
			if renderOrder[i] ~= taskbarTask and renderOrder[i] ~= desktopTask then
				table.insert(locked, renderOrder[i])
				table.remove(renderOrder, i)
			else
				i = i + 1
			end
		end
	end
	newProcess.mini = false
	newProcess.maxi = false
	newProcess.SP = SP
	newProcess.CR = true
	newProcess.status = ""
	if not isBG then
		newProcess.win = window.create(buffer, X, Y, Sx, Sy, false)
		newProcess.hasWinDecor = hasWinDecor
	end
	processes[processID] = newProcess
	table.insert(coroutineOrder, processID)
	if not isBG then
		table.insert(renderOrder, processID)
	end
	if isBG then
		term.redirect(dummyTerm)
	else
		term.redirect(processes[processID].win)
	end
	coroutine.resume(processes[processID].cor, ...)
	term.redirect(buffer)
	return processID
end

--removeProcess: Removes a process and pointers in other tables
local function removeProcess(processID)
	for i, v in pairs(coroutineOrder) do
		if v == processID then
			table.remove(coroutineOrder, i)
			break
		end
	end
	if not processes[processID].isBG then
		for i, v in pairs(renderOrder) do
			if v == processID then
				table.remove(renderOrder, i)
				break
			end
		end
	end
	processes[processID] = nil
end

--Variables
local UserEvents = {["char"] = true, ["key"] = true, ["key_up"] = true, ["mouse_click"] = true, ["mouse_drag"] = true, ["mouse_scroll"] = true, ["mouse_up"] = true, ["paste"] = true, ["terminate"] = true, ["term_resize"] = true}
local bWin = nil
local bPos = {}

----update: The main update function
local function update(e)
	if isLocked then bWin = nil end
	if e[1] == "term_resize" then
		local Tx, Ty = OGTerm.getSize()
		buffer.reposition(1, 1, Tx, Ty)
		processes[taskbarTask].win.reposition(1, 1, 3, Ty)
		processes[desktopTask].win.reposition(4, 1, Tx - 3, Ty)
	end
	local toDelete = {}
	local toMini = {}
	local toFront = nil
	local nRO = {}
	for i, v in pairs(renderOrder) do
		table.insert(nRO, i, v)
	end
	for i, v in pairs(nRO) do
		if v == desktopTask then
			table.remove(nRO, i)
			table.insert(nRO, 1, v)
		end
	end
	--if e[1] == "char" and e[2] == "p" then
	--	for i, v in pairs(renderOrder) do
	--		table.insert(RTLog, processes[v].name)
	--	end
	--	error("")
	--end
	local thingToUpdate = renderOrder[#renderOrder]
	if e[1] == "mouse_scroll" then
		for i, v in pairs(renderOrder) do
			if v ~= desktopTask then 
				local process = processes[v]
				local Sx, Sy = process.win.getPosition()
				local Ex, Ey = process.win.getSize()
				Ex = Ex + Sx - 1
				Ey = Ey + Sy - 1
				if e[3] >= Sx and e[3] <= Ex and e[4] >= Sy and e[4] <= Ey then
					thingToUpdate = v
				end
			end
		end
	end
	for i, v in pairs(coroutineOrder) do
		if (not UserEvents[e[1]]) or v == thingToUpdate then
			local handled = false
			if e[1] == "terminate" and (v == taskbarTask or v == desktopTask) then
				handled = true
			end
			if string.find(e[1],"mouse") then
				if e[1] == "mouse_click" then
					--local tro = true
					for i = #nRO, 1, -1 do
						v = nRO[i]
						local process = processes[v]
						local Sx, Sy = process.win.getPosition()
						local Ex, Ey = process.win.getSize()
						Ex = Ex + Sx - 1
						Ey = Ey + Sy - 1
						if e[3] >= Sx and e[3] <= Ex and e[4] >= Sy and e[4] <= Ey then
							if v ~= thingToUpdate then
								toFront = v
								handled = true
								os.queueEvent("mouse_click", e[2], e[3], e[4])
							end
							break
						elseif e[3] >= Sx - 1 and e[3] <= Ex + 1 and e[4] >= Sy - 1 and e[4] <= Ey + 1 and process.hasWinDecor then
							if v ~= thingToUpdate then
								toFront = v
								handled = true
							end
							bWin = v
							local Wx, Wy = process.win.getSize()
							local mode = 0
							if e[3] == Sx - 1 and e[4] == Sy - 1 then mode = 1 end
							if e[3] == Ex + 1 and e[4] == Sy - 1 then mode = 2 end
							if e[3] == Sx - 1 and e[4] == Ey + 1 then mode = 3 end
							if e[3] == Ex + 1 and e[4] == Ey + 1 then mode = 4 end
							if e[3] == Sx + 5 and e[4] == Sy - 1 and process.CR then mode = 5 end
							if e[3] == Sx + 3 and e[4] == Sy - 1 then mode = 6 end
							if e[3] == Sx + 1 and e[4] == Sy - 1 then mode = 7 end
							bPos = {e[3] - Sx, e[4] - Sy, e[3], e[4], Wx, Wy, Sx, Sy, mode}
							break
						end
						--tro = false
					end
				elseif e[1] == "mouse_drag" and bWin then
					local cr = processes[bWin].CR
					if bPos[9] == 0 then
						if processes[bWin].maxi ~= false then
							local X, Y, Wx, Wy = table.unpack(processes[bWin].maxi)
							local Tx, Ty = term.getSize()
							local Sx = e[3] - math.floor(Wx / 2)
							if Sx < 4 then Sx = 4 end
							if Sx > Tx - Wx then Sx = Tx - Wx end
							local Sy = 2
							processes[bWin].win.reposition(Sx, Sy, Wx, Wy)
							processes[bWin].maxi = false
							bPos = {e[3] - Sx, e[4] - Sy, e[3], e[4], Wx, Wy, Sx, Sy, 0}
							os.queueEvent("term_resize")
						else
							processes[bWin].win.reposition(e[3] - bPos[1], e[4] - bPos[2])
						end
					elseif bPos[9] == 1 and cr then
						local Sx = bPos[5] + (bPos[3] - e[3])
						local Sy = bPos[6] + (bPos[4] - e[4])
						if Sx < 8 then Sx = 8 end
						if Sy < 5 then Sy = 5 end
						processes[bWin].win.reposition(e[3] + 1, e[4] + 1, Sx, Sy)
						os.queueEvent("term_resize")
					elseif bPos[9] == 2 and cr then
						local Sx = e[3] - bPos[7]
						local Sy = bPos[6] + (bPos[4] - e[4])
						if Sx < 8 then Sx = 8 end
						if Sy < 5 then Sy = 5 end
						processes[bWin].win.reposition(bPos[7], e[4] + 1, Sx, Sy)
						os.queueEvent("term_resize")
					elseif bPos[9] == 3 and cr then
						local Sx = bPos[5] + (bPos[3] - e[3])
						local Sy = e[4] - bPos[8]
						if Sx < 8 then Sx = 8 end
						if Sy < 5 then Sy = 5 end
						processes[bWin].win.reposition(e[3] + 1, bPos[8], Sx, Sy)
						os.queueEvent("term_resize")
					elseif bPos[9] == 4 and cr then
						local Sx = e[3] - bPos[7]
						local Sy = e[4] - bPos[8]
						if Sx < 8 then Sx = 8 end
						if Sy < 5 then Sy = 5 end
						processes[bWin].win.reposition(bPos[7], bPos[8], Sx, Sy)
						os.queueEvent("term_resize")
					end
				elseif e[1] == "mouse_up" and bWin then
					local cr = processes[bWin].CR
					if (bPos[9] > 0 and bPos[9] < 5 or bPos[9] == 6) and cr then os.queueEvent("term_resize") end
					if ((bPos[9] == 5 and cr) or (bPos[9] == 6 and not cr)) and e[3] == bPos[3] and e[4] == bPos[4] then --Close
						table.insert(toDelete, bWin)
					elseif bPos[9] == 6 and processes[bWin].maxi == false and e[3] == bPos[3] and e[4] == bPos[4] and cr then --Maximize
						local Sx, Sy = processes[bWin].win.getPosition()
						local Ex, Ey = processes[bWin].win.getSize()
						local Tx, Ty = term.getSize()
						processes[bWin].maxi = {Sx, Sy, Ex, Ey}
						processes[bWin].win.reposition(4, 2, Tx - 3, Ty - 1)
					elseif bPos[9] == 6 and e[3] == bPos[3] and e[4] == bPos[4] then --Unmaximize
						processes[bWin].win.reposition(table.unpack(processes[bWin].maxi))
						processes[bWin].maxi = false
					elseif bPos[9] == 7 and e[3] == bPos[3] and e[4] == bPos[4] then --Minimize
						table.insert(toMini, bWin)
					end
					bWin = nil
				end
				local process = processes[thingToUpdate]
				local Sx, Sy = process.win.getPosition()
				local Ex, Ey = process.win.getSize()
				Ex = Ex + Sx - 1
				Ey = Ey + Sy - 1
				if e[3] >= Sx and e[3] <= Ex and e[4] >= Sy and e[4] <= Ey and not handled then
					e[3] = e[3] - Sx + 1
					e[4] = e[4] - Sy + 1
				else
					handled = true
				end
			end
			if not handled and (not bWin or not string.find(e[1],"mouse")) then
				local process = processes[v]
				if process.isBG then
					term.redirect(dummyTerm)
				else
					term.redirect(process.win)
				end
				coroutine.resume(process.cor, table.unpack(e))
				if coroutine.status(process.cor) == "dead" then
					table.insert(toDelete, v)
				end
				term.redirect(buffer)
			end
		end
	end
	if toFront then
		for i, v in pairs(renderOrder) do
			if v == toFront then
				table.remove(renderOrder, i)
				table.insert(renderOrder, v)
			end
		end
	end
	for _, v in pairs(toDelete) do
		removeProcess(v)
	end
	for _, v in pairs(toMini) do
		processes[v].mini = true
		for i,u in pairs(renderOrder) do
			if u == v then
				table.remove(renderOrder, i)
				break
			end
		end
		table.insert(minied, v)
	end
end

----render: The main render function
local function render()
	term.setBackgroundColour(settings.theme.backgroundColour)
	term.clear()
	local NCx = 0
	local NCy = 0
	local NTc = colours.white
	local NCB = false
	local nRO = {}
	for _, v in pairs(renderOrder) do
		table.insert(nRO, v)
	end
	for i, v in pairs(nRO) do
		if v == taskbarTask then
			table.remove(nRO, i)
			table.insert(nRO, v)
		end
	end
	for i, v in pairs(nRO) do
		if v == desktopTask then
			table.remove(nRO, i)
			table.insert(nRO, 1, v)
		end
	end
	for i, v in pairs(nRO) do
		local process = processes[v]
		local win = process.win
		local X, Y = win.getPosition()
		local Sx, Sy = win.getSize()
		local Tx, Ty = term.getSize()
		term.setCursorPos(X - 1, Y - 1)
		term.setBackgroundColour(settings.theme.windowColour)
		local shownName = process.name:sub(1, Sx - 8)
		for i = 0, Sx + 1 do
			if not process.maxi then
				if (i == 0 or i > #shownName + 7 or i == Sx + 1) and X - 1 + i > 3 and X - 1 + i <= Tx and Y - 1 > 0 and Y - 1 <= Ty and process.hasWinDecor then
					local drchar = string.byte(select(1, term.current().getLine(Y - 1)):sub(X - 1 + i, X - 1 + i)) - 128
					local blitfg = select(2, term.current().getLine(Y - 1)):sub(X - 1 + i, X - 1 + i)
					local blitbg = select(3, term.current().getLine(Y - 1)):sub(X - 1 + i, X - 1 + i)
					if drchar >= 0 and drchar < 32 then
						if BlitToNum[blitbg] == settings.theme.windowColour then
							term.setTextColour(BlitToNum[blitfg])
							term.setCursorPos(X - 1 + i, Y - 1)
							term.write(string.char((drchar % 16) + 128))
						elseif BlitToNum[blitfg] == settings.theme.windowColour then
							term.setTextColour(BlitToNum[blitbg])
							term.setCursorPos(X - 1 + i, Y - 1)
							local ttp = 0
							if drchar % 2 == 0 then ttp = ttp + 1 end
							if drchar % 4 < 2 then ttp = ttp + 2 end
							if drchar % 8 < 4 then ttp = ttp + 4 end
							if drchar % 16 < 8 then ttp = ttp + 8 end
							term.write(string.char(ttp + 128))
						elseif drchar % 16 == 7 or drchar % 16 == 11 or drchar % 16 == 13 or drchar % 16 == 14 or drchar % 16 == 15 then
							term.setTextColour(BlitToNum[blitfg])
							term.setCursorPos(X - 1 + i, Y - 1)
							if settings.theme.roundedCorners and i == 0 then
								term.write("\159")
							elseif settings.theme.roundedCorners and i == Sx + 1 then
								local ttc = term.getTextColour()
								local tbc = term.getBackgroundColour()
								term.setTextColour(tbc)
								term.setBackgroundColour(ttc)
								term.write("\144")
								term.setTextColour(ttc)
								term.setBackgroundColour(tbc)
							else
								term.write("\143")
							end
						else
							term.setTextColour(BlitToNum[blitbg])
							term.setCursorPos(X - 1 + i, Y - 1)
							if settings.theme.roundedCorners and i == 0 then
								term.write("\159")
							elseif settings.theme.roundedCorners and i == Sx + 1 then
								local ttc = term.getTextColour()
								local tbc = term.getBackgroundColour()
								term.setTextColour(tbc)
								term.setBackgroundColour(ttc)
								term.write("\144")
								term.setTextColour(ttc)
								term.setBackgroundColour(tbc)
							else
								term.write("\143")
							end
						end
					else
						term.setTextColour(BlitToNum[blitbg])
						term.setCursorPos(X - 1 + i, Y - 1)
						if settings.theme.roundedCorners and i == 0 then
							term.write("\159")
						elseif settings.theme.roundedCorners and i == Sx + 1 then
							local ttc = term.getTextColour()
							local tbc = term.getBackgroundColour()
							term.setTextColour(tbc)
							term.setBackgroundColour(ttc)
							term.write("\144")
							term.setTextColour(ttc)
							term.setBackgroundColour(tbc)
						else
							term.write("\143")
						end
					end
				end
			else
				term.setBackgroundColour(settings.theme.windowColour)
				if v == nRO[#nRO - 1] then
					term.setBackgroundColour(settings.theme.selTitleBarColour)
				end
				term.write(" ")
			end
		end
		if process.hasWinDecor then
			for i = 1, Sy do
				term.setCursorPos(X - 1, Y - 1 + i)
				local blitbg = select(3, win.getLine(i)):sub(1, 1)
				term.setBackgroundColour(BlitToNum[blitbg])
				term.setTextColour(settings.theme.windowColour)
				term.write("\149")
				term.blit(win.getLine(i))
				blitbg = select(3, win.getLine(i)):sub(Sx, Sx)
				term.setBackgroundColour(settings.theme.windowColour)
				term.setTextColour(BlitToNum[blitbg])
				term.write("\149")
			end
		else
			for i = 1, Sy do
				term.setCursorPos(X, Y - 1 + i)
				term.blit(win.getLine(i))
			end
		end
		term.setCursorPos(X - 1, Y + Sy)
		term.setBackgroundColour(settings.theme.windowColour)
		if process.hasWinDecor then
			local blitbg = select(3, win.getLine(Sy)):sub(1, 1)
			term.setTextColour(BlitToNum[blitbg])
			if settings.theme.roundedCorners and Y + Sy <= Ty and X > 1 then
				local blitbg = select(3, buffer.getLine(Y + Sy)):sub(X - 1, X - 1)
				term.setBackgroundColour(BlitToNum[blitbg])
				term.setTextColour(settings.theme.windowColour)
				term.write("\139")
				local blitbg = select(3, win.getLine(Sy)):sub(1, 1)
				term.setTextColour(BlitToNum[blitbg])
				term.setBackgroundColour(settings.theme.windowColour)
				term.write("\139")
			else
				term.write("\138")
				term.write("\143")
			end
			for i = 2, Sx - 1 do
				local blitbg = select(3, win.getLine(Sy)):sub(i, i)
				term.setTextColour(BlitToNum[blitbg])
				term.write("\143")
			end
			local blitbg = select(3, win.getLine(Sy)):sub(Sx, Sx)
			term.setTextColour(BlitToNum[blitbg])
			if settings.theme.roundedCorners and Y + Sy <= Ty and X + Sx <= Tx then
				term.write("\135")
				local blitbg = select(3, buffer.getLine(Y + Sy)):sub(X + Sx, X + Sx)
				term.setBackgroundColour(BlitToNum[blitbg])
				term.setTextColour(settings.theme.windowColour)
				term.write("\135")
			else
				term.write("\143")
				term.write("\133")
			end
		end
		term.setCursorPos(X, Y - 1)
		if X > 0 and X <= Tx and Y - 1 > 0 and Y - 1 <= Ty and process.hasWinDecor then
			local drchar = string.byte(select(1, term.current().getLine(Y - 1)):sub(X, X)) - 128
			local blitfg = select(2, term.current().getLine(Y - 1)):sub(X, X)
			local blitbg = select(3, term.current().getLine(Y - 1)):sub(X, X)
			term.setBackgroundColour(settings.theme.windowColour)
			if v == nRO[#nRO - 1] then
				term.setBackgroundColour(settings.theme.selTitleBarColour)
			end
			if not process.maxi then
				if drchar >= 0 and drchar < 32 and drchar % 2 == 1 then
				term.setTextColour(BlitToNum[blitfg])
				else
				term.setTextColour(BlitToNum[blitbg])
				end
				term.write("\129")
			else
				term.write(" ")
			end
		end
		term.setBackgroundColour(settings.theme.windowColour)
		term.setTextColour(settings.theme.windowTextColour)
		if v == nRO[#nRO - 1] then
			term.setBackgroundColour(settings.theme.selTitleBarColour)
			term.setTextColour(settings.theme.selWindowTextColour)
		end
		if process.hasWinDecor then
			term.write("- ")
			if process.CR then term.write("+ ") end
			term.write("\215 ")
			if not process.CR then term.write("  ") end
			term.write(process.name:sub(1, Sx - 8))
		end
		if X + 7 + #shownName > 0 and X + 7 + #shownName <= Tx and Y - 1 > 0 and Y - 1 <= Ty and process.hasWinDecor then
			local drchar = string.byte(select(1, term.current().getLine(Y - 1)):sub(X + 7 + #shownName, X + 7 + #shownName)) - 128
			local blitfg = select(2, term.current().getLine(Y - 1)):sub(X + 7 + #shownName, X + 7 + #shownName)
			local blitbg = select(3, term.current().getLine(Y - 1)):sub(X + 7 + #shownName, X + 7 + #shownName)
			if not process.maxi then
				term.setBackgroundColour(settings.theme.windowColour)
				if v == nRO[#nRO - 1] then
					term.setBackgroundColour(settings.theme.selTitleBarColour)
				end
				if drchar >= 0 and drchar < 32 and drchar % 4 >= 2 then
					term.setTextColour(BlitToNum[blitfg])
				else
					term.setTextColour(BlitToNum[blitbg])
				end
				term.write("\130")
			end
		end
		if v == nRO[#nRO - 1] then
			if win.getCursorBlink() then
				NTc = win.getTextColour()
				NCx, NCy = win.getCursorPos()
				local Wx, Wy = win.getSize()
				if NCx > 0 and NCx <= Wx and NCy > 0 and NCy <= Wy then
					NCx = NCx + X - 1
					NCy = NCy + Y - 1
					NCB = true
				end
			end
		end
	end
	term.setTextColour(NTc)
	term.setCursorPos(NCx, NCy)
	term.setCursorBlink(NCB)
end

local Tx, Ty = OGTerm.getSize()
taskbarTask = addProcress("PhileOS/SysPrograms/Taskbar.lua", false, 1, 1, 3, Ty, false, true)
desktopTask = addProcress("PhileOS/SysPrograms/Desktop.lua", false, 4, 1, Tx - 3, Ty, false, true)
addProcress("PhileOS/SysPrograms/System.lua", true)
term.setBackgroundColour(settings.theme.backgroundColour)
term.clear()
buffer.reposition(1, 1, Tx, Ty)

while not Exit do
	update(table.pack(os.pullEventRaw()))
	render()
	term.redirect(OGTerm)
	local X, Y = buffer.getPosition()
	local Sx, Sy = buffer.getSize()
	for i = 1, Sy do
		term.setCursorPos(X, Y - 1 + i)
		term.blit(buffer.getLine(i))
	end
	term.setTextColour(buffer.getTextColour())
	local Cx, Cy = buffer.getCursorPos()
	term.setCursorPos(buffer.getCursorPos())
	if Cx <= 3 then
		term.setCursorBlink(false)
	else
		term.setCursorBlink(buffer.getCursorBlink())
	end
	term.redirect(buffer)
end
end)
----Error handling
term.redirect(OGTerm)
term.setBackgroundColour(colours. black)
term.clear()
term.setCursorPos(1, 1)
if not ok then
	printError("Error in Phile OS RT Kernel: "..err)
	print("RT Log:")
	for _, v in pairs(RTLog) do
		print(v)
	end
end