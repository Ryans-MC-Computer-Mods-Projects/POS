if not PhileOS then
    term.clear()
    shell.setAlias("POS", "/PhileOS/RTKrnl.lua")
    os.run(_ENV, "/PhileOS/RTKrnl.lua")
else
    coroutine.yield()
    local pUtils = require("PhileUtils")
    local sha256 = require("sha256")
    local function cut(str,len,pad)
        pad = pad or " "
        return str:sub(1,len) .. pad:rep(len - #str)
    end
    PhileOS.setName(PhileOS.ID, "Enter Password")

    local loggedIn = PhileOS.getUsername()
    local user = loggedIn
    local pass = ""
    local sel = nil
    local selY = 0
    local selX = 0
    local curpos = 0
    local passwords = 0

    local NoPass = false

    if not fs.exists("/PhileOS/.pass.set") then 
        term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
        term.clear()
        local pwf = fs.open("/PhileOS/.pass.set", "w")
        pwf.write("{}")
        pwf.close()
        NoPass = true
    else
        local pwf = fs.open("/PhileOS/.pass.set", "r")
        passwords = pwf.readAll()
        pwf.close()
        passwords = textutils.unserialise(passwords)
        if passwords == nil then
            term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
            term.clear()
            NoPass = true
        end

        local noUsers = true
        for i, v in pairs(passwords) do
            noUsers = false
        end

        if noUsers then
            term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
            term.clear()
            NoPass = true
        end
    end
    if NoPass then
        PhileOS.setStatus(PhileOS.ID, "Admin;Default")
        local user = "Default"
        if not fs.exists("PhileOS/Users/"..user) then 
            fs.makeDir("PhileOS/Users/"..user)
            fs.makeDir("PhileOS/Users/"..user.."/Documents")
        end
        if not fs.exists("PhileOS/Users/"..user.."/user.set") then
            local usrSet = {}
            usrSet.theme = PhileOS.getCategory("theme")
            usrSet.time = PhileOS.getCategory("time")
            local fh = fs.open("PhileOS/Users/"..user.."/user.set", "w")
            fh.write(textutils.serialise(usrSet))
            fh.close()
        end
        return
    end
    local on = false
    local idleTime = 0

    local Sx, Sy = term.getSize()

    while true do
        term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
        term.clear()
        local winc = colours.toBlit(PhileOS.getSetting("theme", "windowColour"))
        local bgc = colours.toBlit(PhileOS.getSetting("theme", "defBackgroundColour"))
        local tc = colours.toBlit(PhileOS.getSetting("theme", "defTextColour"))
        local logowidth = 4
        if on then
            if Sx < 48 and Sy < 19 then
                pUtils.renderPhimg("/PhileOS/Icons/Logo.phimg", 1, math.ceil(Sx / 2) - 12, 1, PhileOS.getSetting("theme", "defBackgroundColour"))
            else
                logowidth = 8
                pUtils.renderPhimg("/PhileOS/Icons/Logo.phimg", 2, math.ceil(Sx / 2) - 24, 1, PhileOS.getSetting("theme", "defBackgroundColour"))
            end

            if logowidth == 8 then
                term.setCursorPos(math.ceil(Sx / 2) - 10, logowidth + 1)
                term.blit("Username:", tc:rep(9), bgc:rep(9))
                term.setCursorPos(math.ceil(Sx / 2) - 11, logowidth + 2)
                term.blit("\159"..("\143"):rep(20).."\144", bgc:rep(21)..winc, winc:rep(21)..bgc)
                term.setCursorPos(math.ceil(Sx / 2) - 11, logowidth + 3)
                term.blit("\149"..cut(user, 20).."\149", bgc..tc:rep(20)..winc, winc..bgc:rep(21))
                term.setCursorPos(math.ceil(Sx / 2) - 11, logowidth + 4)
                term.blit("\130"..("\131"):rep(20).."\129", winc:rep(22), bgc:rep(22))

                term.setCursorPos(math.ceil(Sx / 2) - 10, logowidth + 6)
                term.blit("Password:", tc:rep(9), bgc:rep(9))
                term.setCursorPos(math.ceil(Sx / 2) - 11, logowidth + 7)
                term.blit("\159"..("\143"):rep(20).."\144", bgc:rep(21)..winc, winc:rep(21)..bgc)
                term.setCursorPos(math.ceil(Sx / 2) - 11, logowidth + 8)
                term.blit("\149"..cut(("*"):rep(#pass), 20).."\149", bgc..tc:rep(20)..winc, winc..bgc:rep(21))
                term.setCursorPos(math.ceil(Sx / 2) - 11, logowidth + 9)
                term.blit("\130"..("\131"):rep(20).."\129", winc:rep(22), bgc:rep(22))

                term.setCursorPos(math.ceil(Sx / 2) - 8, logowidth + 10)
                term.blit(("\131"):rep(16), bgc:rep(16), ("5"):rep(16))
                term.setCursorPos(math.ceil(Sx / 2) - 8, logowidth + 11)
                term.blit(" Enter Password ", tc:rep(16), ("5"):rep(16))
            else
                term.setCursorPos(math.ceil(Sx / 2) - 13, logowidth + 1)
                term.blit("Username:", tc:rep(9), bgc:rep(9))
                term.setCursorPos(math.ceil(Sx / 2) - 14, logowidth + 2)
                term.blit("\159"..("\143"):rep(12).."\144", bgc:rep(13)..winc, winc:rep(13)..bgc)
                term.setCursorPos(math.ceil(Sx / 2) - 14, logowidth + 3)
                term.blit("\149"..cut(user, 12).."\149", bgc..tc:rep(12)..winc, winc..bgc:rep(13))
                term.setCursorPos(math.ceil(Sx / 2) - 14, logowidth + 4)
                term.blit("\130"..("\131"):rep(12).."\129", winc:rep(14), bgc:rep(14))

                term.setCursorPos(math.ceil(Sx / 2) + 2, logowidth + 1)
                term.blit("Password:", tc:rep(9), bgc:rep(9))
                term.setCursorPos(math.ceil(Sx / 2) + 1, logowidth + 2)
                term.blit("\159"..("\143"):rep(12).."\144", bgc:rep(13)..winc, winc:rep(13)..bgc)
                term.setCursorPos(math.ceil(Sx / 2) + 1, logowidth + 3)
                term.blit("\149"..cut(("*"):rep(#pass), 12).."\149", bgc..tc:rep(12)..winc, winc..bgc:rep(13))
                term.setCursorPos(math.ceil(Sx / 2) + 1, logowidth + 4)
                term.blit("\130"..("\131"):rep(12).."\129", winc:rep(14), bgc:rep(14))

                term.setCursorPos(math.ceil(Sx / 2) - 8, logowidth + 5)
                term.blit(" Enter Password ", tc:rep(16), ("5"):rep(16))
            end
        else
            term.setCursorPos(math.ceil(Sx / 2) - 13, 1)
            term.blit("Press Ctrl + T To Log On...", tc:rep(27), bgc:rep(27))
            term.setCursorPos(math.ceil(Sx / 2) - 4, 2)
            term.blit("\159"..("\143"):rep(4).."\144\159\143\144", bgc:rep(5)..winc..bgc:rep(2)..winc, winc:rep(5)..bgc..winc:rep(2)..bgc)
            term.setCursorPos(math.ceil(Sx / 2) - 4, 3)
            term.blit("\149Ctrl\149\149T\149", bgc..tc:rep(4)..winc..bgc..tc..winc, winc:rep(5)..bgc..winc:rep(2)..bgc)
            term.setCursorPos(math.ceil(Sx / 2) - 4, 4)
            term.blit("\130"..("\131"):rep(4).."\129\130\131\129", winc:rep(9), bgc:rep(9))
        end
        if sel then
            term.setCursorPos(selX + curpos - 1, selY)
            term.setTextColour(PhileOS.getSetting("theme", "defTextColour"))
            term.setCursorBlink(true)
        else
            term.setCursorBlink(false)
        end
        e = table.pack(os.pullEventRaw())
        if e[1] == "terminate" and not on then
            on = true
            sel = nil
            idleTime = 0
        end
        if e[1] == "timer" and on then
            idleTime = idleTime + 0.2
            if idleTime >= 30 then
                on = false
                sel = nil
                user = loggedIn
                pass = ""
            end
        else
            idleTime = 0
        end
        if e[1] == "mouse_click" and on then
            if logowidth == 8 and e[3] >= math.ceil(Sx / 2) - 10  and e[3] <= math.ceil(Sx / 2) + 10 and e[4] == logowidth + 3 and loggedIn == "" then
                sel = "user"
                curpos = #user + 1
                selX = math.ceil(Sx / 2) - 10
                selY = logowidth + 3
            elseif  logowidth == 8 and e[3] >= math.ceil(Sx / 2) - 10  and e[3] <= math.ceil(Sx / 2) + 10 and e[4] == logowidth + 8 then
                sel = "pass"
                curpos = #pass + 1
                selX = math.ceil(Sx / 2) - 10
                selY = logowidth + 8
            elseif logowidth == 4 and e[3] >= math.ceil(Sx / 2) - 13 and e[3] <= math.ceil(Sx / 2) - 1 and e[4] == logowidth + 3 and loggedIn == "" then
                sel = "user"
                curpos = #user + 1
                selX = math.ceil(Sx / 2) - 13
                selY = logowidth + 3
            elseif logowidth == 4 and e[3] >= math.ceil(Sx / 2) + 2 and e[3] <= math.ceil(Sx / 2) + 14 and e[4] == logowidth + 3 then
                sel = "pass"
                curpos = #pass + 1
                selX = math.ceil(Sx / 2) + 2
                selY = logowidth + 3
            elseif (logowidth == 8 and e[3] >= math.ceil(Sx / 2) - 8 and e[3] <= math.ceil(Sx / 2) + 7 and (e[4] == logowidth + 10 or e[4] == logowidth + 11)) or (logowidth == 4 and e[3] >= math.ceil(Sx / 2) - 8 and e[3] <= math.ceil(Sx / 2) + 7 and (e[4] == logowidth + 5)) then
                sel = nil
                if passwords[user] then
                    local tbl = passwords[user]
                    local passHash = sha256.pbkdf2(pass, tbl.salt, tbl.iter)
                    local passHex = passHash:toHex()
                    if passHex == tbl.hash then
                        PhileOS.setStatus(PhileOS.ID, tbl.type..";"..user)
                        if not fs.exists("PhileOS/Users/"..user) then 
                            fs.makeDir("PhileOS/Users/"..user)
                            fs.makeDir("PhileOS/Users/"..user.."/Documents")
                        end
                        if not fs.exists("PhileOS/Users/"..user.."/user.set") then
                            local usrSet = {}
                            usrSet.theme = PhileOS.getCategory("theme")
                            usrSet.time = PhileOS.getCategory("time")
                            local fh = fs.open("PhileOS/Users/"..user.."/user.set", "w")
                            fh.write(textutils.serialise(usrSet))
                            fh.close()
                        end
                        return
                    else
                        PhileOS.openDialog(PhileOS.ID, "button", {"Incorrect Password", "Ok", "", "", ""})
                    end
                else
                    PhileOS.openDialog(PhileOS.ID, "button", {"Incorrect Username", "Ok", "", "", ""})
                end
                user = loggedIn
                pass = ""
            else
                sel = nil
            end
        elseif e[1] == "char" and curpos < ((logowidth == 8) and 20 or 12) and on then
            if sel == "user" then
                user = user:sub(1, curpos - 1)..e[2]..user:sub(curpos)
                curpos = curpos + 1
            elseif sel == "pass" then
                pass = pass:sub(1, curpos - 1)..e[2]..pass:sub(curpos)
                curpos = curpos + 1
            end
        elseif e[1] == "key" and on then
            if e[2] == keys.left and curpos > 1 then
                curpos = curpos - 1
            elseif e[2] == keys.right and curpos < ((logowidth == 8) and 20 or 12) then
                curpos = curpos + 1
            elseif e[2] == keys.enter then
                sel = nil
            end
            if sel == "user" and e[2] == keys.backspace and curpos > 1 then
                user = user:sub(1, curpos - 2)..user:sub(curpos)
                curpos = curpos - 1
            elseif sel == "pass" and e[2] == keys.backspace and curpos > 1 then
                pass = pass:sub(1, curpos - 2)..pass:sub(curpos)
                curpos = curpos - 1
            end
        end
    end
end