local Phicon = require("Phicon")
local pUtils = require("PhileUtils")
local function cut(str,len,pad, ddd)
    pad = pad or " "
    if #str > len and ddd then str = str:sub(1, len - 3).."..." end
    return pad:rep(math.ceil((len - #str) / 2)) .. str:sub(1,len) .. pad:rep(math.floor((len - #str) / 2))
end
local xs = 0
local ys = 0

local drag = true
local mx = 0
local my = 0
local mb = 0
local time = os.clock()
local firstRender = true

while true do
    local Sx, Sy = term.getSize()
    local bgc = PhileOS.getSetting("theme", "backgroundColour")
    local txc = PhileOS.getSetting("theme", "desktopTextColour")
    term.setBackgroundColour(bgc)
    term.clear()

    local file = fs.open("/PhileOS/Settings/desktop.set", "r")
	local pins = textutils.unserialise(file.readAll())
    if PhileOS.getIsLocked() or firstRender then pins = {} end
    if PhileOS.getIsLocked() then firstRender = false end
    file.close()

    for y, t in pairs(pins) do
        for x, v in pairs(t) do
            if v ~= nil then
                if x == xs and y == ys then
                    term.setBackgroundColour(PhileOS.getSetting("theme", "selBackgroundColour"))
                    term.setCursorPos((8 * x) - 6, (5 * y) - 4)
                    term.write("       ")
                    term.setCursorPos((8 * x) - 6, (5 * y) - 3)
                    term.write("       ")
                    term.setCursorPos((8 * x) - 6, (5 * y) - 2)
                    term.write("       ")
                else
                    term.setBackgroundColour(bgc)
                end
                local icon = "/PhileOS/Icons/Default.phico"
                local isPhimg = false
                if fs.exists("PhileOS/Icons/Programs/"..v[2]..".phico") then
                    icon = "PhileOS/Icons/Programs/"..v[2]..".phico"
                elseif fs.exists("PhileOS/Icons/Programs/"..v[2]..".phimg") then
                    icon = "PhileOS/Icons/Programs/"..v[2]..".phimg"
                    isPhimg = true
                elseif fs.exists("PhileOS/Icons/Extentions/"..PhileOS.GetExt(v[2])..".phico") then
                    icon = "PhileOS/Icons/Extentions/"..PhileOS.GetExt(v[2])..".phico"
                elseif fs.exists("PhileOS/Icons/Extentions/"..PhileOS.GetExt(v[2])..".phimg") then
                    icon = "PhileOS/Icons/Extentions/"..PhileOS.GetExt(v[2])..".phimg"
                    isPhimg = true
                end
                if isPhimg then
                    pUtils.renderPhimg(icon, 1, (8 * x) - 5, (5 * y) - 4, term.getBackgroundColour())
                else
                    Phicon.renderFile((8 * x) - 5, (5 * y) - 4, term.getBackgroundColour(), icon)
                end
                term.setBackgroundColour(bgc)
                term.setTextColour(txc)
                term.setCursorPos((8 * x) - 6, (5 * y) - 1)
                term.write(cut(v[1], 7, nil, true))
            end
        end
    end

    if pins[ys] then
        if pins[ys][xs] then
            local name = pins[ys][xs][1]
            local ypos = -1
            term.setBackgroundColour(PhileOS.getSetting("theme", "selBackgroundColour"))
            while #name > 0 do
                term.setCursorPos((8 * xs) - 6, (5 * ys) + ypos)
                term.write(cut(name, 7))
                name = name:sub(8)
                ypos = ypos + 1
            end
        end
    end
    
    term.setBackgroundColour(bgc)
    term.setTextColour(txc)
    term.setCursorPos(Sx - 25, Sy - 1)
    term.write("PhileOS 0.1.0 | Build 0001")
    term.setCursorPos(Sx - 25, Sy)
    term.write("THIS IS A WORK IN PROGRESS")

    local e = table.pack(os.pullEvent())
    if e[1] == "timer" then
        firstRender = false
    elseif e[1] == "mouse_click" and not PhileOS.getIsLocked() then
        if e[2] == 1 then
            drag = false
            mx = e[3]
            my = e[4]
            mb = e[2]
        elseif e[2] == 2 then
            local XT = math.floor((e[3] - 1) / 8) + 1
            local YT = math.floor(e[4] / 5) + 1
            local option = 0
            if pins[YT] then
                if pins[YT][XT] then
                    option = PhileOS.openRClick(PhileOS.ID, e[3], e[4], {"Rename Icon", "Delete Icon", "", "Add Icon"})
                end
            end
            if option == 0 then
                option = PhileOS.openRClick(PhileOS.ID, e[3], e[4], {"Add Icon"})
            end
            if option == "Rename Icon" then
                local name = PhileOS.openDialog(PhileOS.ID, "textInput", {"New Name for "..pins[YT][XT][1], pins[YT][XT][1]})
                pins[YT][XT][1] = name
                local file = fs.open("/PhileOS/Settings/desktop.set", "w")
                file.write(textutils.serialise(pins))
                file.close()
            elseif option == "Delete Icon" then
                local delete = PhileOS.openDialog(PhileOS.ID, "button", {"Are you sure you want to delete "..pins[YT][XT][1].."?", "Yes", "No", "", ""})
                if delete == "Yes" then
                    pins[YT][XT] = nil
                    local file = fs.open("/PhileOS/Settings/desktop.set", "w")
                    file.write(textutils.serialise(pins))
                    file.close()
                end
            elseif option == "Add Icon" then
                PhileOS.openDialog(PhileOS.ID, "button", {"WIP. Please use the\nexplorer to add icons\nfor now", "Ok", "", "", ""})
            end
        end
    elseif e[1] == "mouse_drag" and not PhileOS.getIsLocked() then
        drag = true
    elseif e[1] == "mouse_up" and not PhileOS.getIsLocked() then
        if not drag then
            if e[2] == 1 then
                if e[3] % 8 ~= 1 and e[4] % 5 ~= 0 then
                    if xs == math.floor((e[3] - 1) / 8) + 1 and ys == math.floor(e[4] / 5) + 1 and (os.clock() - time) < 0.5 then
                        if pins[ys] then
                            if pins[ys][xs] then
                                PhileOS.OpenFile(pins[ys][xs][2])
                            end
                        end
                        xs = 0
                        ys = 0
                    else
                        xs = math.floor((e[3] - 1) / 8) + 1
                        ys = math.floor(e[4] / 5) + 1
                        time = os.clock()
                    end
                else
                    xs = 0
                    ys = 0
                    time = os.clock()
                end
            end
        else
            local xst = math.floor((mx - 1) / 8) + 1
            local yst = math.floor(my / 5) + 1

            if pins[yst] then
                if pins[yst][xst] then
                    local xst2 = math.floor((e[3] - 1) / 8) + 1
                    local yst2 = math.floor(e[4] / 5) + 1
                    local save = false
                    if pins[yst2] then
                        if pins[yst2][xst2] then
                            xs = xst
                            ys = yst
                        else
                            local temp = pins[yst][xst]
                            pins[yst][xst] = nil
                            pins[yst2][xst2] = temp
                            save = true
                        end
                    else
                        local temp = pins[yst][xst]
                        pins[yst][xst] = nil
                        pins[yst2] = {}
                        pins[yst2][xst2] = temp
                        save = true
                    end
                    if save then
                        local file = fs.open("/PhileOS/Settings/desktop.set", "w")
	                    file.write(textutils.serialise(pins))
                        file.close()
                        xs = xst2
                        ys = yst2
                    end
                else
                    xs = 0
                    ys = 0
                end
            else
                xs = 0
                ys = 0
            end
        end
    end
end