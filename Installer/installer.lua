PhileOS.setName(PhileOS.ID, "Install PhileOS")
local Sx, Sy = term.getSize()
local screen = 1

local function split(str, delimiter)
	local result = { }
	local from  = 1
	local delim_from, delim_to = string.find( str, delimiter, from  )
	while delim_from do
	  table.insert( result, string.sub( str, from , delim_from-1 ) )
	  from  = delim_to + 1
	  delim_from, delim_to = string.find( str, delimiter, from  )
	end
	table.insert( result, string.sub( str, from  ) )
	return result
end

local function cut(str,len,pad)
    pad = pad or " "
    return str:sub(1,len) .. pad:rep(len - #str)
  end

local function middlePrint(text, yp)
    local nlSplit = split(text, "\n")
    local i = 1
    while i < #nlSplit do
        while #nlSplit[i] > Sx do
            local spaceSplit = split(nlSplit[i], " ")
            local keep = ""
            local split = ""
            local keepBool = true
            for _, v in pairs(spaceSplit) do
                if #keep + #v + 1 > Sx then
                    keepBool = false
                end
                if keepBool then
                    keep = keep..v.." "
                else
                    split = split..v.." "
                end
            end
            table.insert(nlSplit, i + 1, split)
            nlSplit[i] = keep
            i = i + 1
        end
        i = i + 1
    end
    local sub = 0
    if yp + #nlSplit - 1 > Sy then
        sub = yp + #nlSplit - 1 - Sy
    end
    for i, v in pairs(nlSplit) do
        if i > sub then
            term.setCursorPos(math.ceil(Sx / 2) - math.floor(#v / 2), yp + i - 1 - sub)
            term.write(v)
        end
    end
    return #nlSplit
end
local varTable = {}
while true do
    term.setBackgroundColour(1)
	term.clear()

    if screen == 1 then
        term.setBackgroundColour(1)
        term.setTextColour(32768)
        local textLen = middlePrint("Hello. Welcome to the PhileOS Installer!\nThis program will help you install PhileOS easily!\n\nDo you want to install PhileOS?", 1)

        term.setCursorPos(math.ceil(Sx / 2) - 6, Sy - 2)
        term.blit(("\143"):rep(6).." "..("\143"):rep(6), ("0"):rep(13), ("5"):rep(6).."0"..("e"):rep(6))
        term.setCursorPos(math.ceil(Sx / 2) - 6, Sy - 1)
        term.blit(" Yeah   Nope ", ("f"):rep(13), "5555550eeeeee")
        term.setCursorPos(math.ceil(Sx / 2) - 6, Sy)
        term.blit(("\131"):rep(6).." "..("\131"):rep(6), "5555550eeeeee", ("0"):rep(13))

        e = table.pack(os.pullEventRaw())
        if e[1] == "mouse_click" then
            if e[3] >= math.ceil(Sx / 2) - 6 and e[3] <= math.ceil(Sx / 2) - 1 and e[4] >= Sy - 2 then
                screen = 2
                varTable = {toPrint = {"Downloading Files..."}}
                PhileOS.setStatus(PhileOS.ID, 1)
            elseif e[3] >= math.ceil(Sx / 2) + 1 and e[3] <= math.ceil(Sx / 2) + 6 and e[4] >= Sy - 2 then
		fs.delete("temp/")
                PhileOS.stopAll(PhileOS.ID)
            end
        end
    elseif screen == 2 then
        term.setBackgroundColour(1)
        term.setTextColour(32768)
        term.setCursorPos(1, 1)
        for i, v in pairs(varTable.toPrint) do
            print(v)
        end
        if not varTable.files then
            local files = http.get("https://raw.githubusercontent.com/Ryans-MC-Computer-Mods-Projects/POS/main/files.set")
            varTable.files = textutils.unserialise(files.readAll())
        end
        local files = varTable.files
        if #files > 0 then
            local mode = "w"
            if files[1]:sub(-6) == ".phimg" then mode = "wb" end
            local file = http.get("https://raw.githubusercontent.com/Ryans-MC-Computer-Mods-Projects/POS/main/Files/"..files[1], nil, mode == "wb")
            local fh = fs.open(files[1], mode)
            fh.write(file.readAll())
            fh.close()
            table.insert(varTable.toPrint, files[1]..".")
            table.remove(files, 1)
        else
            screen = 3
            varTable = {}
            PhileOS.setStatus(PhileOS.ID, 2)
            fs.makeDir("/PhileOS/.Trash")
            local fh = fs.open("/PhileOS/.pass.set", "w")
            fh.write("{}")
            fh.close()
        end
        --e = table.pack(os.pullEventRaw())
    elseif screen == 3 then
        local textLen = middlePrint("Current system time:\n"..PhileOS.FormatTime("%a %b %d %Y %I:%M:%S %p"), 1)
        local half = " "
	    local tz = PhileOS.getSetting("time", "timezone")
	    local autoDST = PhileOS.getSetting("time", "autoDST")
	    local autoZone = PhileOS.getSetting("time", "autoTime")
	    if math.floor(tz) ~= tz then half = "\189" end
        term.setCursorPos(math.ceil(Sx / 2) - 9 + 2, textLen + 1)
	    if autoZone then term.setTextColour(PhileOS.getSetting("theme", "defDeselTextColour")) end
	    if tz > 0 then
	    	term.write("Timezone:<"..cut("+"..tostring(math.floor(tz)), 3)..half..">")
	    else
	    	term.write("Timezone:<"..cut(tostring(math.ceil(tz)), 3)..half..">")
	    end
        term.setTextColour(PhileOS.getSetting("theme", "taskbarTextColour"))
	    term.setCursorPos(math.ceil(Sx / 2) - 9 + 2, textLen + 2)
	    term.write("     Auto Zone")
	    if autoZone then term.write("*") end
	    term.setCursorPos(math.ceil(Sx / 2) - 9 + 2, textLen + 3)
	    term.write("      Auto DST")
	    if not autoZone and autoDST then term.write("*") end
	    term.setCursorPos(math.ceil(Sx / 2) - 9 + 2, textLen + 4)
	    term.write("       Manual")
	    if not autoZone and not autoDST then term.write("*") end

        term.setCursorPos(math.ceil(Sx / 2) - 5, Sy - 2)
        term.blit(("\143"):rep(10), ("0"):rep(10), ("5"):rep(10))
        term.setCursorPos(math.ceil(Sx / 2) - 5, Sy - 1)
        term.blit(" Continue ", ("f"):rep(10), ("5"):rep(10))
        term.setCursorPos(math.ceil(Sx / 2) - 5, Sy)
        term.blit(("\131"):rep(10), ("5"):rep(10), ("0"):rep(10))
        e = table.pack(os.pullEventRaw())
        if e[1] == "mouse_click" then
            local state = 0
            if e[3] == math.ceil(Sx / 2) - 9 + 11 and e[4] == textLen + 1 and (not autoZone) then state = 1 end
            if e[3] == math.ceil(Sx / 2) - 9 + 16 and e[4] == textLen + 1 and (not autoZone) then state = 2 end
            if e[3] >= math.ceil(Sx / 2) - 9 and e[3] <= math.ceil(Sx / 2) + 8 and e[4] == textLen + 2 then state = 3 end
            if e[3] >= math.ceil(Sx / 2) - 9 and e[3] <= math.ceil(Sx / 2) + 8 and e[4] == textLen + 3 then state = 4 end
            if e[3] >= math.ceil(Sx / 2) - 9 and e[3] <= math.ceil(Sx / 2) + 8 and e[4] == textLen + 4 then state = 5 end
            if e[3] >= math.ceil(Sx / 2) - 5 and e[3] <= math.ceil(Sx / 2) + 4 and e[4] >= Sy - 2 then
                screen = 4
                varTable = {}
                local fh = fs.open("/PhileOS/Settings/main.set", "r")
                local sets = textutils.unserialise(fh.readAll())
                fh.close()
                sets.time.timezone = PhileOS.getSetting("time", "timezone")
                sets.time.autoDST = PhileOS.getSetting("time", "autoDST")
                sets.time.autoTime = PhileOS.getSetting("time", "autoTime")
                local fh = fs.open("/PhileOS/Settings/main.set", "w")
                fh.write(textutils.serialise(sets))
                fh.close()
            end
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
    elseif screen == 4 then
        term.setBackgroundColour(1)
        term.setTextColour(32768)
        local textLen = middlePrint("Would you like to setup a user account?\nIf you don't, there will be\nno password protection.", 1)
        
        term.setCursorPos(math.ceil(Sx / 2) - 6, Sy - 2)
        term.blit(("\143"):rep(6).." "..("\143"):rep(6), ("0"):rep(13), ("5"):rep(6).."0"..("e"):rep(6))
        term.setCursorPos(math.ceil(Sx / 2) - 6, Sy - 1)
        term.blit(" Yeah   Nope ", ("f"):rep(13), "5555550eeeeee")
        term.setCursorPos(math.ceil(Sx / 2) - 6, Sy)
        term.blit(("\131"):rep(6).." "..("\131"):rep(6), "5555550eeeeee", ("0"):rep(13))
        
        e = table.pack(os.pullEventRaw())
        if e[1] == "mouse_click" then
            if e[3] >= math.ceil(Sx / 2) - 6 and e[3] <= math.ceil(Sx / 2) - 1 and e[4] >= Sy - 2 then
                screen = 5
                varTable = {user = "", pass = "", pass2 = "", sel = nil, selX = 0, selY = 0}
            elseif e[3] >= math.ceil(Sx / 2) + 1 and e[3] <= math.ceil(Sx / 2) + 6 and e[4] >= Sy - 2 then
                screen = 6
                varTable = {os.clock()}
            end
        end
    elseif screen == 5 then
        local winc = colours.toBlit(PhileOS.getSetting("theme", "windowColour"))
        local bgc = colours.toBlit(PhileOS.getSetting("theme", "defBackgroundColour"))
        local tc = colours.toBlit(PhileOS.getSetting("theme", "defTextColour"))
        local logowidth = 8
        local textLen = 1
        if Sx < 48 and Sy < 19 then
            logowidth = 4
            textLen = middlePrint("Enter username and password", 1)
            term.setCursorPos(math.ceil(Sx / 2) - 13, textLen + 1)
            term.blit("Username:", tc:rep(9), bgc:rep(9))
            term.setCursorPos(math.ceil(Sx / 2) - 14, textLen + 2)
            term.blit("\159"..("\143"):rep(12).."\144", bgc:rep(13)..winc, winc:rep(13)..bgc)
            term.setCursorPos(math.ceil(Sx / 2) - 14, textLen + 3)
            term.blit("\149"..cut(varTable.user, 12).."\149", bgc..tc:rep(12)..winc, winc..bgc:rep(13))
            term.setCursorPos(math.ceil(Sx / 2) - 14, textLen + 4)
            term.blit("\130"..("\131"):rep(12).."\129", winc:rep(14), bgc:rep(14))
            
            term.setCursorPos(math.ceil(Sx / 2) + 2, textLen + 1)
            term.blit("Password:", tc:rep(9), bgc:rep(9))
            term.setCursorPos(math.ceil(Sx / 2) + 1, textLen + 2)
            term.blit("\159"..("\143"):rep(12).."\144", bgc:rep(13)..winc, winc:rep(13)..bgc)
            term.setCursorPos(math.ceil(Sx / 2) + 1, textLen + 3)
            term.blit("\149"..cut(("*"):rep(#varTable.pass), 12).."\149", bgc..tc:rep(12)..winc, winc..bgc:rep(13))
            term.setCursorPos(math.ceil(Sx / 2) + 1, textLen + 4)
            term.blit("\130"..("\131"):rep(12).."\129", winc:rep(14), bgc:rep(14))

            term.setCursorPos(math.ceil(Sx / 2) - 13, textLen + 5)
            term.blit("Password again:", tc:rep(15), bgc:rep(15))
            term.setCursorPos(math.ceil(Sx / 2) - 14, textLen + 6)
            term.blit("\159"..("\143"):rep(12).."\144", bgc:rep(13)..winc, winc:rep(13)..bgc)
            term.setCursorPos(math.ceil(Sx / 2) - 14, textLen + 7)
            term.blit("\149"..cut(("*"):rep(#varTable.pass2), 12).."\149", bgc..tc:rep(12)..winc, winc..bgc:rep(13))
            term.setCursorPos(math.ceil(Sx / 2) - 14, textLen + 8)
            term.blit("\130"..("\131"):rep(12).."\129", winc:rep(14), bgc:rep(14))

            term.setCursorPos(math.ceil(Sx / 2) + 3, textLen + 7)
            term.blit(" Continue ", tc:rep(10), ("5"):rep(10))
        else
            textLen = middlePrint("Please enter username and password", 1)
            term.setCursorPos(math.ceil(Sx / 2) - 10, textLen + 1)
            term.blit("Username:", tc:rep(9), bgc:rep(9))
            term.setCursorPos(math.ceil(Sx / 2) - 11, textLen + 2)
            term.blit("\159"..("\143"):rep(20).."\144", bgc:rep(21)..winc, winc:rep(21)..bgc)
            term.setCursorPos(math.ceil(Sx / 2) - 11, textLen + 3)
            term.blit("\149"..cut(varTable.user, 20).."\149", bgc..tc:rep(20)..winc, winc..bgc:rep(21))
            term.setCursorPos(math.ceil(Sx / 2) - 11, textLen + 4)
            term.blit("\130"..("\131"):rep(20).."\129", winc:rep(22), bgc:rep(22))
            
            term.setCursorPos(math.ceil(Sx / 2) - 10, textLen + 6)
            term.blit("Password:", tc:rep(9), bgc:rep(9))
            term.setCursorPos(math.ceil(Sx / 2) - 11, textLen + 7)
            term.blit("\159"..("\143"):rep(20).."\144", bgc:rep(21)..winc, winc:rep(21)..bgc)
            term.setCursorPos(math.ceil(Sx / 2) - 11, textLen + 8)
            term.blit("\149"..cut(("*"):rep(#varTable.pass), 20).."\149", bgc..tc:rep(20)..winc, winc..bgc:rep(21))
            term.setCursorPos(math.ceil(Sx / 2) - 11, textLen + 9)
            term.blit("\130"..("\131"):rep(20).."\129", winc:rep(22), bgc:rep(22))

            term.setCursorPos(math.ceil(Sx / 2) - 10, textLen + 12)
            term.blit("Re enter password:", tc:rep(18), bgc:rep(18))
            term.setCursorPos(math.ceil(Sx / 2) - 11, textLen + 13)
            term.blit("\159"..("\143"):rep(20).."\144", bgc:rep(21)..winc, winc:rep(21)..bgc)
            term.setCursorPos(math.ceil(Sx / 2) - 11, textLen + 14)
            term.blit("\149"..cut(("*"):rep(#varTable.pass2), 20).."\149", bgc..tc:rep(20)..winc, winc..bgc:rep(21))
            term.setCursorPos(math.ceil(Sx / 2) - 11, textLen + 15)
            term.blit("\130"..("\131"):rep(20).."\129", winc:rep(22), bgc:rep(22))

            term.setCursorPos(math.ceil(Sx / 2) - 5, textLen + 17)
            term.blit(("\131"):rep(10), bgc:rep(10), ("5"):rep(10))
            term.setCursorPos(math.ceil(Sx / 2) - 5, textLen + 18)
            term.blit(" Continue ", tc:rep(10), ("5"):rep(10))
        end
        if varTable.sel then
            term.setCursorPos(varTable.selX + varTable.curpos - 1, varTable.selY)
            term.setTextColour(PhileOS.getSetting("theme", "defTextColour"))
            term.setCursorBlink(true)
        else
            term.setCursorBlink(false)
        end
        e = table.pack(os.pullEventRaw())
        if e[1] == "mouse_click"  then
            if logowidth == 8 and e[3] >= math.ceil(Sx / 2) - 10  and e[3] <= math.ceil(Sx / 2) + 10 and e[4] == textLen + 3 then
                varTable.sel = "user"
                varTable.curpos = #varTable.user + 1
                varTable.selX = math.ceil(Sx / 2) - 10
                varTable.selY = textLen + 3
            elseif  logowidth == 8 and e[3] >= math.ceil(Sx / 2) - 10  and e[3] <= math.ceil(Sx / 2) + 10 and e[4] == textLen + 8 then
                varTable.sel = "pass"
                varTable.curpos = #varTable.pass + 1
                varTable.selX = math.ceil(Sx / 2) - 10
                varTable.selY = textLen + 8
            elseif  logowidth == 8 and e[3] >= math.ceil(Sx / 2) - 10  and e[3] <= math.ceil(Sx / 2) + 10 and e[4] == textLen + 14 then
                varTable.sel = "pass2"
                varTable.curpos = #varTable.pass2 + 1
                varTable.selX = math.ceil(Sx / 2) - 10
                varTable.selY = textLen + 14
            elseif logowidth == 4 and e[3] >= math.ceil(Sx / 2) - 13 and e[3] <= math.ceil(Sx / 2) - 1 and e[4] == textLen + 3 then
                varTable.sel = "user"
                varTable.curpos = #varTable.user + 1
                varTable.selX = math.ceil(Sx / 2) - 13
                varTable.selY = textLen + 3
            elseif logowidth == 4 and e[3] >= math.ceil(Sx / 2) + 2 and e[3] <= math.ceil(Sx / 2) + 14 and e[4] == textLen + 3 then
                varTable.sel = "pass"
                varTable.curpos = #varTable.pass + 1
                varTable.selX = math.ceil(Sx / 2) + 2
                varTable.selY = textLen + 3
            elseif logowidth == 4 and e[3] >= math.ceil(Sx / 2) - 13 and e[3] <= math.ceil(Sx / 2) - 1 and e[4] == textLen + 7 then
                varTable.sel = "pass2"
                varTable.curpos = #varTable.pass2 + 1
                varTable.selX = math.ceil(Sx / 2) - 13
                varTable.selY = textLen + 7
            elseif (logowidth == 8 and e[3] >= math.ceil(Sx / 2) - 8 and e[3] <= math.ceil(Sx / 2) + 7 and (e[4] == textLen + 17 or e[4] == textLen + 18)) or (logowidth == 4 and e[3] >= math.ceil(Sx / 2) + 3 and e[3] <= math.ceil(Sx / 2) + 12 and (e[4] == textLen + 7)) then
                term.setCursorBlink(false)
                local promptUser = true
                if varTable.user ~= "" then
                    if varTable.pass ~= "" then
                        if varTable.pass2 ~= "" then
                            promptUser = false
                            if varTable.user == "Add User..." then
                                PhileOS.openDialog(PhileOS.ID, "button", {"Sorry, but this username isn't allowed!", "Ok", "", "", ""})
                            else
                                if varTable.pass ~= varTable.pass2 then
                                    PhileOS.openDialog(PhileOS.ID, "button", {"Passwords dont match!", "Ok", "", "", ""})
                                else
                                    local sha256 = require("sha256")
                                    function randomString(length, Si, Ei)
                                        local ret = ""
                                        for i = 1,length do
                                          ret = ret..string.char(math.random(Si, Ei))
                                        end
                                        return ret
                                    end
                                    passwords = {}
                                    passwords[varTable.user] = {}
                                    local salt = randomString(32, 48, 127)
                                    local passHash = sha256.pbkdf2(varTable.pass, salt, 100)
                                    local passHex = passHash:toHex()
                                    passwords[varTable.user].hash = passHex 
                                    passwords[varTable.user].salt = salt
                                    passwords[varTable.user].iter = 100
                                    passwords[varTable.user].type = "Admin"
                                    local pwf = fs.open("/PhileOS/.pass.set", "w")
                                    pwf.write(textutils.serialise(passwords))
                                    pwf.close()
                                    screen = 6
                                    varTable = {os.clock()}
                                end
                            end
                        end
                    end
                end
                if promptUser then
                    PhileOS.openDialog(PhileOS.ID, "button", {"Please fill in all 3\ntext fields", "Ok", "", "", ""})
                end
                varTable.sel = nil
            else
                varTable.sel = nil
            end
        elseif e[1] == "char" and varTable.curpos < ((logowidth == 8) and 20 or 12) then
            if varTable.sel == "user" then
                varTable.user = varTable.user:sub(1, varTable.curpos - 1)..e[2]..varTable.user:sub(varTable.curpos)
                varTable.curpos = varTable.curpos + 1
            elseif varTable.sel == "pass" then
                varTable.pass = varTable.pass:sub(1, varTable.curpos - 1)..e[2]..varTable.pass:sub(varTable.curpos)
                varTable.curpos = varTable.curpos + 1
            elseif varTable.sel == "pass2" then
                varTable.pass2 = varTable.pass2:sub(1, varTable.curpos - 1)..e[2]..varTable.pass2:sub(varTable.curpos)
                varTable.curpos = varTable.curpos + 1
            end
        elseif e[1] == "key" then
            if e[2] == keys.left and varTable.curpos > 1 then
                varTable.curpos = varTable.curpos - 1
            elseif e[2] == keys.right and curpos < ((logowidth == 8) and 20 or 12) then
                varTable.curpos = varTable.curpos + 1
            elseif e[2] == keys.enter then
                varTable.sel = nil
            end
            if varTable.sel == "user" and e[2] == keys.backspace and varTable.curpos > 1 then
                varTable.user = varTable.user:sub(1, varTable.curpos - 2)..varTable.user:sub(varTable.curpos)
                varTable.curpos = varTable.curpos - 1
            elseif varTable.sel == "pass" and e[2] == keys.backspace and varTable.curpos > 1 then
                varTable.pass = varTable.pass:sub(1, varTable.curpos - 2)..varTable.pass:sub(varTable.curpos)
                varTable.curpos = varTable.curpos - 1
            elseif varTable.sel == "pass2" and e[2] == keys.backspace and varTable.curpos > 1 then
                varTable.pass2 = varTable.pass2:sub(1, varTable.curpos - 2)..varTable.pass2:sub(varTable.curpos)
                varTable.curpos = varTable.curpos - 1
            end
        end
    elseif screen == 6 then
        term.setBackgroundColour(1)
        term.setTextColour(32768)
        local textLen = middlePrint("Setup complete!\nSystem restarting in\n".. 3 - math.floor(os.clock() - varTable[1]) .." seconds...", 1)
        if math.floor(os.clock() - varTable[1]) == 3 then 
            fs.delete("temp/")
            os.reboot() 
        end
        e = table.pack(os.pullEventRaw())
    end
end
