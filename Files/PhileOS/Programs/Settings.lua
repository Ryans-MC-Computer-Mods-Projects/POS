local sha256 = require("sha256")
local Sx, Sy = term.getSize()
local menu = "Theme"

function randomString(length, Si, Ei)
    local ret = ""
    for i = 1,length do
      ret = ret..string.char(math.random(Si, Ei))
    end
    return ret
end

local function cut(str,len,pad)
    pad = pad or " "
    if #str > len then
        return str:sub(1,len - 3).."..."
    else
        return str:sub(1,len) .. pad:rep(len - #str)
    end
end

term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
term.clear()

--local isSP = PhileOS.askForSP(PhileOS.ID)

--if not isSP then
--    PhileOS.openDialog(PhileOS.ID, "button", {"SP Permissions are\nrequired for this app to\nwork.", "Ok", "", "", ""})
--    return
--end

local coltable = {
    {colours.red, colours.orange, colours.yellow, colours.lime},
    {colours.green, colours.cyan, colours.lightBlue, colours.blue},
    {colours.purple, colours.magenta, colours.pink, colours.brown},
    {colours.black, colours.grey, colours.lightGrey, colours.white},
}

local comptable = {
    {colours.cyan, colours.lightBlue, colours.blue, colours.pink},
    {colours.purple, colours.red, colours.orange, colours.yellow},
    {colours.green, colours.brown, colours.lime, colours.magenta},
    {colours.white, colours.lightGrey, colours.grey, colours.black},
}

local option = "backgroundColour"
local usertype = ""
local protectedMeuns = {Logins = true}

while true do
    term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.clear()
    term.setCursorPos(1, 1)
    term.setBackgroundColour(PhileOS.getSetting("theme", "windowColour"))
    term.setTextColour(PhileOS.getSetting("theme", "windowTextColour"))
    term.write(menu.."\31"..(" "):rep(Sx - #menu - 1))

    local winc = colours.toBlit(PhileOS.getSetting("theme", "windowColour"))
    local bgc = colours.toBlit(PhileOS.getSetting("theme", "defBackgroundColour"))
    local tc = colours.toBlit(PhileOS.getSetting("theme", "defTextColour"))

    if menu == "Theme" then
        term.setCursorPos(2, 2)
        term.blit("\159"..("\143"):rep(20).."\144", bgc:rep(21)..winc, winc:rep(21)..bgc)
        term.setCursorPos(2, 3)
        term.blit("\149"..cut(option, 19).."\31".."\149", bgc..tc:rep(20)..winc, winc..bgc:rep(21))
        term.setCursorPos(2, 4)
        term.blit("\130"..("\131"):rep(20).."\129", winc:rep(22), bgc:rep(22))
        term.setCursorPos(2, 5)
        term.blit("  IMPORT      EXPORT  ", tc:rep(22), ("e"):rep(10)..bgc:rep(2)..("5"):rep(10))

        term.setCursorPos(Sx - 13, 2)
        term.blit("            ", "000000000000", colours.toBlit(coltable[1][1]):rep(3)..colours.toBlit(coltable[1][2]):rep(3)..colours.toBlit(coltable[1][3]):rep(3)..colours.toBlit(coltable[1][4]):rep(3))
        term.setCursorPos(Sx - 13, 3)
        term.blit("            ", "000000000000", colours.toBlit(coltable[1][1]):rep(3)..colours.toBlit(coltable[1][2]):rep(3)..colours.toBlit(coltable[1][3]):rep(3)..colours.toBlit(coltable[1][4]):rep(3))
        term.setCursorPos(Sx - 13, 4)
        term.blit("            ", "000000000000", colours.toBlit(coltable[2][1]):rep(3)..colours.toBlit(coltable[2][2]):rep(3)..colours.toBlit(coltable[2][3]):rep(3)..colours.toBlit(coltable[2][4]):rep(3))
        term.setCursorPos(Sx - 13, 5)
        term.blit("            ", "000000000000", colours.toBlit(coltable[2][1]):rep(3)..colours.toBlit(coltable[2][2]):rep(3)..colours.toBlit(coltable[2][3]):rep(3)..colours.toBlit(coltable[2][4]):rep(3))
        term.setCursorPos(Sx - 13, 6)
        term.blit("            ", "000000000000", colours.toBlit(coltable[3][1]):rep(3)..colours.toBlit(coltable[3][2]):rep(3)..colours.toBlit(coltable[3][3]):rep(3)..colours.toBlit(coltable[3][4]):rep(3))
        term.setCursorPos(Sx - 13, 7)
        term.blit("            ", "000000000000", colours.toBlit(coltable[3][1]):rep(3)..colours.toBlit(coltable[3][2]):rep(3)..colours.toBlit(coltable[3][3]):rep(3)..colours.toBlit(coltable[3][4]):rep(3))
        term.setCursorPos(Sx - 13, 8)
        term.blit("            ", "000000000000", colours.toBlit(coltable[4][1]):rep(3)..colours.toBlit(coltable[4][2]):rep(3)..colours.toBlit(coltable[4][3]):rep(3)..colours.toBlit(coltable[4][4]):rep(3))
        term.setCursorPos(Sx - 13, 9)
        term.blit("            ", "000000000000", colours.toBlit(coltable[4][1]):rep(3)..colours.toBlit(coltable[4][2]):rep(3)..colours.toBlit(coltable[4][3]):rep(3)..colours.toBlit(coltable[4][4]):rep(3))
        
        local selcol = PhileOS.getSetting("theme", option)
        for y = 1, 4 do
            for x = 1, 4 do
                if coltable[y][x] == selcol then
                    term.setCursorPos(Sx - 13 + (3 * (x - 1)), 2 + (2 * (y - 1)))
                    term.blit("\151\131\148", colours.toBlit(comptable[y][x]):rep(2)..colours.toBlit(coltable[y][x]), colours.toBlit(coltable[y][x]):rep(2)..colours.toBlit(comptable[y][x]))
                    term.setCursorPos(Sx - 13 + (3 * (x - 1)), 3 + (2 * (y - 1)))
                    term.blit("\138\143\133", colours.toBlit(coltable[y][x]):rep(3), colours.toBlit(comptable[y][x]):rep(3))
                end
            end
        end
    elseif menu == "Logins" then
        term.setCursorPos(2, 2)
        term.blit("\159"..("\143"):rep(20).."\144", bgc:rep(21)..winc, winc:rep(21)..bgc)
        term.setCursorPos(2, 3)
        term.blit("\149"..cut(option, 19).."\31".."\149", bgc..tc:rep(20)..winc, winc..bgc:rep(21))
        term.setCursorPos(2, 4)
        term.blit("\130"..("\131"):rep(20).."\129", winc:rep(22), bgc:rep(22))        

        if option ~= "" then
            term.setCursorPos(7, 5)
            term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
            term.setTextColour(PhileOS.getSetting("theme", "defTextColour"))
            term.write(usertype.." Account")

            term.setCursorPos(Sx - 17, 2)
            term.blit(("\143"):rep(16), bgc:rep(16), ("1"):rep(16))
            term.setCursorPos(Sx - 17, 3)
            term.blit(" Reset Password ", tc:rep(16), ("1"):rep(16))
            term.setCursorPos(Sx - 17, 4)
            term.blit(("\131"):rep(16), ("1"):rep(16), bgc:rep(16))
            
            term.setCursorPos(Sx - 17, 5)
            term.blit(("\143"):rep(16), bgc:rep(16), ("e"):rep(16))
            term.setCursorPos(Sx - 17, 6)
            term.blit(" Delete Account ", tc:rep(16), ("e"):rep(16))
            term.setCursorPos(Sx - 17, 7)
            term.blit(("\131"):rep(16), ("e"):rep(16), bgc:rep(16))
        end

    end
    local e = table.pack(os.pullEvent())
    if e[1] == "term_resize" then
        Sx, Sy = term.getSize()
    elseif e[1] == "mouse_click" and e[2] == 1 then
        if e[3] <= #menu + 1 and e[4] == 1 then
            local choice = PhileOS.openRClick(PhileOS.ID, 1, 2, {"Theme", "Logins"})
            if protectedMeuns[choice] and PhileOS.getUserType() == "User" then
                PhileOS.openDialog(PhileOS.ID, "button", {"Access to that menu\nrequires an admin\naccount.", "Ok", "", "", ""})
            else
                if choice ~= nil then menu = choice end
                if choice == "Theme" then option = "backgroundColour" end
                if choice == "Logins" then option = "" end
            end
        else
            if menu == "Theme" then
                if e[3] >= 3 and e[3] <= 23 and e[4] == 3 then
                    local theme = PhileOS.getCategory("theme")
                    local themeNames = {}
                    for i, v in pairs(theme) do
                        if #tostring(i) > 1 then
                            table.insert(themeNames, i)
                        end
                    end
                    local choice = PhileOS.openRClick(PhileOS.ID, 2, 4, themeNames, true)
                    if choice ~= nil then option = choice end
                elseif e[3] >= Sx - 13 and e[3] <= Sx - 2 and e[4] >= 2 and e[4] <= 11 then
                    local colX = math.floor((e[3] - (Sx - 13)) / 3) + 1
                    local colY = math.floor((e[4] - 2) / 2) + 1
                    PhileOS.setSetting(PhileOS.ID, "theme", option, coltable[colY][colX])
                elseif e[3] >= 2 and e[3] <= 12 and e[4] == 5 then
                    local file = PhileOS.openDialog(PhileOS.ID, "openFile", {"/PhileOS/Settings/Themes/"})
                    if file ~= nil then
                        local fh = fs.open(file, "r")
                        local newTheme = textutils.unserialise(fh.readAll()) or {}
                        fh.close()

                        for i, v in pairs(PhileOS.getCategory("theme")) do
                            if newTheme[i] then
                                PhileOS.setSetting(PhileOS.ID, "theme", i, newTheme[i])
                            end
                        end
                    end
                elseif e[3] >= 15 and e[3] <= 25 and e[4] == 5 then 
                    local file = PhileOS.openDialog(PhileOS.ID, "saveFile", {"/PhileOS/Settings/Themes/"})
                    if file ~= nil then
                        local fh = fs.open(file, "w")
                        fh.write(textutils.serialise(PhileOS.getCategory("theme")))
                        fh.close()
                    end
                end
            elseif menu == "Logins" then
                if e[3] >= 3 and e[3] <= 23 and e[4] == 3 then
                    local pwf = fs.open("/PhileOS/.pass.set", "r")
                    passwords = pwf.readAll()
                    pwf.close()
                    passwords = textutils.unserialise(passwords)
                    if passwords == nil then
                        local pwf = fs.open("/PhileOS/.pass.set", "w")
                        pwf.write("{}")
                        pwf.close()
                        passwords = {}
                    end
                    local userNames = {}
                    for i, v in pairs(passwords) do
                        table.insert(userNames, i)
                    end
                    table.insert(userNames, "")
                    table.insert(userNames, "Add User...")
                    local choice = PhileOS.openRClick(PhileOS.ID, 2, 4, userNames, true)
                    if choice == "Add User..." then
                        local isAdmin = "Admin"
                        if #userNames > 2 then
                            isAdmin = PhileOS.openDialog(PhileOS.ID, "button", {"Do you want this account to be a user or an \nadmin?", "User", "Admin", "", ""})
                        end
                        if isAdmin ~= nil then
                            local user = PhileOS.openDialog(PhileOS.ID, "textInput", {"Enter Username", ""})
                            if user == "Add User..." then
                                PhileOS.openDialog(PhileOS.ID, "button", {"Thought this would break something?", "Ok", "", "", ""})
                            elseif passwords[user] then
                                PhileOS.openDialog(PhileOS.ID, "button", {"That username already exists!", "Ok", "", "", ""})
                            elseif user ~= nil then
                                local pass1 = PhileOS.openDialog(PhileOS.ID, "textInput", {"Enter Password", "", "*"})
                                if pass1 ~= nil then
                                    local pass2 = PhileOS.openDialog(PhileOS.ID, "textInput", {"Re Enter Password", "", "*"})
                                    if pass2 ~= nil then
                                        if pass1 ~= pass2 then
                                            PhileOS.openDialog(PhileOS.ID, "button", {"Passwords dont match!", "Ok", "", "", ""})
                                        else
                                            passwords[user] = {}
                                            local salt = randomString(32, 48, 127)
                                            local passHash = sha256.pbkdf2(pass1, salt, 100)
                                            local passHex = passHash:toHex()
                                            passwords[user].hash = passHex 
                                            passwords[user].salt = salt
                                            passwords[user].iter = 100
                                            passwords[user].type = isAdmin
                                            local pwf = fs.open("/PhileOS/.pass.set", "w")
                                            pwf.write(textutils.serialise(passwords))
                                            pwf.close()
                                            option = user
                                            usertype = passwords[user].type
                                        end
                                    end
                                end
                            end
                        end
                    elseif choice ~= nil then
                        option = choice
                        usertype = passwords[option].type
                    end
                elseif option ~= "" and e[3] >= Sx - 17 and e[3] <= Sx - 1 and e[4] >= 2 and e[4] <= 4 then
                    local pass1 = PhileOS.openDialog(PhileOS.ID, "textInput", {"Enter New Password", "", "*"})
                    if pass1 ~= nil then
                        local pass2 = PhileOS.openDialog(PhileOS.ID, "textInput", {"Re Enter New Password", "", "*"})
                        if pass2 ~= nil then
                            if pass1 ~= pass2 then
                                PhileOS.openDialog(PhileOS.ID, "button", {"Passwords dont match!", "Ok", "", "", ""})
                            else
                                passwords[option] = {}
                                local salt = randomString(32, 48, 127)
                                local passHash = sha256.pbkdf2(pass1, salt, 100)
                                local passHex = passHash:toHex()
                                passwords[option].hash = passHex 
                                passwords[option].salt = salt
                                passwords[option].iter = 100
                                local pwf = fs.open("/PhileOS/.pass.set", "w")
                                pwf.write(textutils.serialise(passwords))
                                pwf.close()
                            end
                        end
                    end
                elseif option ~= "" and e[3] >= Sx - 17 and e[3] <= Sx - 1 and e[4] >= 5 and e[4] <= 7 then
                    if PhileOS.getUsername() == option then
                        PhileOS.openDialog(PhileOS.ID, "button", {"You can't delete this\naccount because you're\non it right now.", "Ok", "", "", ""})
                    else
                        local ans = PhileOS.openDialog(PhileOS.ID, "button", {"Are you sure you want to delete this account?", "Yes", "No", "", ""})
                        if ans == "Yes" then
                            passwords[option] = nil
                            local pwf = fs.open("/PhileOS/.pass.set", "w")
                            pwf.write(textutils.serialise(passwords))
                            pwf.close()
                            option = ""
                        end
                    end
                end
            end
        end
    end
end