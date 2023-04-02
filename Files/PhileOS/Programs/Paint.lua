term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
term.clear()
PhileOS.setName(PhileOS.ID, "Paint")

local Sx, Sy = term.getSize()

while Sx < 27 or Sy < 15 do
    term.setCursorBlink(false)
    term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.setTextColour(PhileOS.getSetting("theme", "defTextColour"))
    term.clear()
    term.setCursorPos(math.floor(Sx / 2) - 8, math.floor(Sy / 2))
    term.write("  Make the window  ")
    term.setCursorPos(math.floor(Sx / 2) - 8, math.floor(Sy / 2) + 1)
    term.write("bigger to continue.")
    local e = table.pack(os.pullEvent())
    if e[1] == "term_resize" then Sx, Sy = term.getSize() end
end

local fh = fs.open("/PhileOS/APIs/pxl.lua", "r")
local pxl = load(fh:readAll())()
fh.close()
local menu = {"Menu", "|", "Brush Size:1"}
local currentlyEditing = ""
local editing = {}
local args = {...}

local coltable = {
    {colours.red, colours.orange, colours.yellow, colours.lime},
    {colours.green, colours.cyan, colours.lightBlue, colours.blue},
    {colours.purple, colours.magenta, colours.pink, colours.brown},
    {colours.black, colours.grey, colours.lightGrey, colours.white},
}
local xgrid = {1, 2, 2, 3, 4, 4}

if args[1] then
    location = args[1]
    if fs.exists(location) then
        if fs.isDir(location) then
            PhileOS.openDialog(PhileOS.ID, "button", {"You can't open a folder!", "Ok", "", "", ""})
        else
            local file = fs.open(location, "rb")
            local text = file.readAll()
            file.close()
            PSx = string.byte(text:sub(1, 1))
            PSy = string.byte(text:sub(2, 2))
            pxl.setup(3, 4, math.ceil(PSx / 2 * 3), PSy)
            pxl.clear(colours.white)
            pxl.loadImage(text, "PHIMG", 1, 1)
            currentlyEditing = location
            PhileOS.setName(PhileOS.ID, "Paint - ".. currentlyEditing:sub(math.max(#currentlyEditing - (Sx - 17), 1)))
        end
    else
    end
end

local lcol = colors.black
local rcol = colors.white
local seltool = 1

local brushSize = 1
local shape = "Box"
local fill = "Fill"

local PSx = 10
local PSy = 10

local Xc = 0
local Yc = 0
local PPSx = 0
local PPSy = 0
local prev = ""
local resize = false
local undo = {}
local redo = {}
local saved = ""
local undoSize = 0

if currentlyEditing == "" then
    pxl.setup(3, 4, math.ceil(PSx / 2 * 3), PSy)
    pxl.clear(colours.white)
end

while true do
    if undoSize ~= #undo and #undo ~= 0 then
        saved = "*"
        PhileOS.setName(PhileOS.ID, "Paint - "..(currentlyEditing..saved):sub(math.max(#currentlyEditing - (Sx - 17), 1)))
        undoSize = #undo
    end
    term.setCursorBlink(false)
    term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.clear()
    term.setCursorPos(1, 1)
    term.setBackgroundColour(PhileOS.getSetting("theme", "windowColour"))
    term.setTextColour(PhileOS.getSetting("theme", "windowTextColour"))
    local remaining = Sx
    remaining = remaining - #(PSx.." x "..PSy)
    for _, v in pairs(menu) do
        term.write(v)
        term.write(" ")
        remaining = remaining - (#v + 1)
    end
    term.write((" "):rep(remaining))
    term.write(PSx.." x "..PSy)

    local winc = colours.toBlit(PhileOS.getSetting("theme", "windowColour"))
    local bgc = colours.toBlit(PhileOS.getSetting("theme", "defBackgroundColour"))
    local lcolb = ""
    if lcol ~= 0 then
        lcolb = colours.toBlit(lcol)
    end
    local rcolb = ""
    if rcol ~= 0 then
        rcolb = colours.toBlit(rcol)
    end
    local toolsc = {winc, winc, winc, winc}
    toolsc[seltool] = colours.toBlit(PhileOS.getSetting("theme", "selTitleBarColour"))

    term.setCursorPos(1, 2)
    term.blit("\156\140\140\140\140\140\140\147", winc:rep(7)..bgc, bgc:rep(7)..winc)
    term.setCursorPos(1, 3)
    term.blit("\149 \149  \149 \149", winc.."ee1445"..bgc, bgc.."e11455"..winc)
    term.setCursorPos(1, 4)
    term.blit("\149 \149  \149 \149", winc.."dd933b"..bgc, bgc.."d993bb"..winc)
    term.setCursorPos(1, 5)
    term.blit("\149 \149  \149 \149", winc.."aa266c"..bgc, bgc.."a226cc"..winc)
    term.setCursorPos(1, 6)
    term.blit("\149 \149  \149 \149", winc.."ff7880"..bgc, bgc.."f77800"..winc)
    term.setCursorPos(1, 7)
    term.blit("\149\153\145\131\131\131\131\129", winc.."88"..bgc:rep(5), bgc:rep(3)..winc:rep(5))
    term.setCursorPos(1, 8)
    if lcolb ~= "" and rcolb ~= "" then
        term.blit("\157\140\140  \149 \149", winc:rep(4)..lcolb:rep(2)..rcolb:rep(2), bgc:rep(3)..winc..lcolb..winc..rcolb..winc)
    elseif lcolb == "" and rcolb ~= "" then
        term.blit("\157\140\140 \127\149 \149", winc:rep(4).."80"..rcolb:rep(2), bgc:rep(3)..winc.."0"..winc..rcolb..winc)
    elseif lcolb ~= "" and rcolb == "" then
        term.blit("\157\140\140  \149\127\149", winc:rep(4)..lcolb:rep(2).."80", bgc:rep(3)..winc..lcolb..winc.."0"..winc)
    elseif lcolb == "" and rcolb == "" then
        term.blit("\157\140\140 \127\149\127\149", winc:rep(4).."80".."80", bgc:rep(3)..winc.."0"..winc.."0"..winc)
    end
    term.setCursorPos(1, 9)
    term.blit("\151"..("\131"):rep(7).."\148", winc:rep(8)..bgc, bgc:rep(8)..winc)
    term.setCursorPos(1, 10)
    term.blit("\149 \131  \149 \149\149", winc..toolsc[1].."2"..toolsc[1]..bgc..toolsc[2].."3f"..bgc, bgc..toolsc[1].."4"..toolsc[1]..bgc.."f3"..toolsc[2]..winc)
    term.setCursorPos(1, 11)
    term.blit("\149 \135  \130\131\129\149", winc..toolsc[1].."f"..toolsc[1]..bgc.."fff"..bgc, bgc..toolsc[1]:rep(3)..bgc..toolsc[2]:rep(3)..winc)
    term.setCursorPos(1, 12)
    term.blit("\149\143\143\143 \143\143\143\149", winc..bgc:rep(8), bgc..toolsc[3]:rep(3)..bgc..toolsc[4]:rep(3)..winc)
    term.setCursorPos(1, 13)
    term.blit("\149 \150  \149 \149\149", winc.."fff"..bgc..toolsc[4].."ff"..bgc, bgc..toolsc[3]:rep(3)..bgc.."ff"..toolsc[4]..winc)
    term.setCursorPos(1, 14)
    term.blit("\149\138   \138\143\133\149", winc.."fff"..bgc.."fff"..bgc, bgc..toolsc[3]:rep(3)..bgc..toolsc[4]:rep(3)..winc)
    term.setCursorPos(1, 15)
    term.blit("\141"..("\140"):rep(7).."\142", winc:rep(9), bgc:rep(9))
    if not resize or (PSx * PSy <= 1600) then
        pxl.draw(11, 3)
    end
    term.setCursorPos(10, 2)
    if PSx % 2 == 0 then
        term.blit("\159"..("\143"):rep(PSx / 2 * 3).."\144", bgc:rep(PSx / 2 * 3 + 1)..winc, winc:rep(PSx / 2 * 3 + 1)..bgc)
    else
        term.blit("\159"..("\143"):rep(PSx / 2 * 3 + 1), bgc:rep(PSx / 2 * 3 + 2), winc:rep(PSx / 2 * 3 + 2))
    end
    for y = 1, PSy do
        term.setCursorPos(10, 2 + y)
        term.blit("\149", bgc, winc)
        if PSx % 2 == 0 then
            term.setCursorPos(11 + (PSx / 2 * 3), 2 + y)
            term.blit("\149", winc, bgc)
        else
            term.setCursorPos(11 + (PSx / 2 * 3), 2 + y)
            term.blit("\149", select(3, term.current().getLine(2 + y)):sub(10 + (PSx / 2 * 3), 10 + (PSx / 2 * 3)), winc)
        end
    end
    term.setCursorPos(10, 3 + PSy)
    local add = 1
    if PSx % 2 == 0 then
        term.blit("\130"..("\131"):rep(PSx / 2 * 3).."\129", winc:rep(PSx / 2 * 3 + 2), bgc:rep(PSx / 2 * 3 + 2))
    else
        term.blit("\130"..("\131"):rep(PSx / 2 * 3 + 1), winc:rep(PSx / 2 * 3 + 2), bgc:rep(PSx / 2 * 3 + 2))
        add = 0
    end

    term.setBackgroundColour(colours.lime)
    term.setTextColour(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.setCursorPos(11 + math.ceil(PSx / 2 * 3) + add, 2 + PSy)
    term.write("\143\143\143")
    term.setTextColour(colours.black)
    term.setCursorPos(11 + math.ceil(PSx / 2 * 3) + add, 3 + PSy)
    term.write(" + ")
    term.setCursorPos(11 + math.ceil(PSx / 2 * 3) + add, 4 + PSy)
    term.setTextColour(colours.lime)
    term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.write("\143\143\143")

    local e = table.pack(os.pullEvent())
    if e[1] == "term_resize" then
        Sx, Sy = term.getSize()
        if currentlyEditing then
            PhileOS.setName(PhileOS.ID, "Paint - "..(currentlyEditing..saved):sub(math.max(#currentlyEditing - (Sx - 19), 1)))
        end
        while Sx < 27 or Sy < 15 do
            term.setCursorBlink(false)
            term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
            term.setTextColour(PhileOS.getSetting("theme", "defTextColour"))
            term.clear()
            term.setCursorPos(math.floor(Sx / 2) - 8, math.floor(Sy / 2))
            term.write("  Make the window  ")
            term.setCursorPos(math.floor(Sx / 2) - 8, math.floor(Sy / 2) + 1)
            term.write("bigger to continue.")
            local e = table.pack(os.pullEvent())
            if e[1] == "term_resize" then Sx, Sy = term.getSize() end
        end
        if Sx < 47 and seltool == 4 then 
            seltool = 3 
            menu = {"Menu", "|", "Line Width:"..brushSize}
            PhileOS.openDialog(PhileOS.ID, "button", {"Please make the window\nwider to select this\ntool", "Ok", "", "", ""})
        end
        local dothis = false
        if 15 + math.floor(PSx / 2 * 3) >= Sx then PSx = math.floor((Sx - 15) / 3 * 2) dothis = true end
        if 4 + PSy >= Sy then PSy = Sy - 4 dothis = true end
        if dothis then
            table.insert(undo, {pxl.exportToPhimg(), PSx, PSy})
            prev = pxl.exportToPhimg()
            pxl.setup(3, 4, math.ceil(PSx / 2 * 3), PSy, true)
            pxl.clear(colours.white)
            pxl.loadImage(prev, "PHIMG", 1, 1)
        end
    elseif resize then
        if e[1] == "mouse_drag" or e[1] == "mouse_up" then
            local Pix, Piy = pxl.getGridCoord(e[3] - 10, e[4] - 2)
            local Cx = Pix - Xc
            local Cy = Piy - Yc
            PSx = PPSx + Cx
            if 15 + math.floor(PSx / 2 * 3) >= Sx then PSx = math.floor((Sx - 15) / 3 * 2) end
            if PSx < 1 then PSx = 1 end
            PSy = PPSy + Cy
            if 4 + PSy >= Sy then PSy = Sy - 4 end
            if PSy < 1 then PSy = 1 end
            if e[1] == "mouse_up" or (PSx * PSy <= 1600) then
                pxl.setup(3, 4, math.ceil(PSx / 2 * 3), PSy, true)
                pxl.clear(colours.white)
                pxl.loadImage(prev, "PHIMG", 1, 1)
            end
            if e[1] == "mouse_up" then
                resize = false
            end
        end
    elseif e[1] == "mouse_click" then
        if e[3] >= 2 and e[3] <= 7 and e[4] >= 3 and e[4] <= 6 then
            if e[2] == 1 then
                lcol = coltable[e[4] - 2][xgrid[e[3] - 1]]
            elseif e[2] == 2 then
                rcol = coltable[e[4] - 2][xgrid[e[3] - 1]]
            end
        elseif e[3] == 2 and e[4] == 7 then
            if e[2] == 1 then
                lcol = 0
            elseif e[2] == 2 then
                rcol = 0
            end
        elseif e[3] >= 2 and e[3] <= 4 and (e[4] == 10 or e[4] == 11) and e[2] == 1 then
            seltool = 1
            menu = {"Menu", "|", "Brush Size:"..brushSize}
        elseif e[3] >= 6 and e[3] <= 8 and (e[4] == 10 or e[4] == 11) and e[2] == 1 then
            seltool = 2
            menu = {"Menu", "|"}
        elseif e[3] >= 2 and e[3] <= 4 and (e[4] == 13 or e[4] == 14) and e[2] == 1 then
            seltool = 3
            menu = {"Menu", "|", "Line Width:"..brushSize}
        elseif e[3] >= 6 and e[3] <= 8 and (e[4] == 13 or e[4] == 14) and e[2] == 1 then
            if Sx >= 47 then
                seltool = 4
                menu = {"Menu", "|", "Border:"..brushSize, shape.."\31", fill.."\31"}
            else
                PhileOS.openDialog(PhileOS.ID, "button", {"Please make the window\nwider to select this\ntool", "Ok", "", "", ""})
            end
        elseif e[4] == 1 and e[2] == 1 then
            local option = nil
            local check = e[3]
            for i, v in pairs(menu) do
                if check <= #v then
                    option = i
                    break
                end
                if check <= #v + 1 then break end
                check = check - (#v + 1)
            end
            if option == 1 then
                local choice = PhileOS.openRClick(PhileOS.ID, 1, 2, {"New", "Open", "Save", "Save As", "", "Undo", "Redo", "", "About"})
                if choice == "Undo" then
                    if #undo > 0 then
                        table.insert(redo, {pxl.exportToPhimg(), PSx, PSy})
                        PSx = undo[#undo][2]
                        PSy = undo[#undo][3]
                        pxl.setup(3, 4, math.ceil(PSx / 2 * 3), PSy, true)
                        pxl.clear(colours.white)
                        pxl.loadImage(undo[#undo][1], "PHIMG", 1, 1)
                        undo[#undo] = nil
                    end
                elseif choice == "Redo" then
                    if #redo > 0 then
                        table.insert(undo, {pxl.exportToPhimg(), PSx, PSy})
                        PSx = redo[#redo][2]
                        PSy = redo[#redo][3]
                        pxl.setup(3, 4, math.ceil(PSx / 2 * 3), PSy, true)
                        pxl.clear(colours.white)
                        pxl.loadImage(redo[#redo][1], "PHIMG", 1, 1)
                        redo[#redo] = nil
                    end
                elseif choice == "About" then
                    PhileOS.openDialog(PhileOS.ID, "button", {"Phile OS Paint\nMade by Ryan in 2022", "Ok", "", "", ""})
                elseif choice == "New" then
                    PSx = 10
                    PSy = 10
                    pxl.setup(3, 4, math.ceil(PSx / 2 * 3), PSy)
                    pxl.clear(colours.white)
                    currentlyEditing = ""
                    undo = {}
                    redo = {}
                    PhileOS.setName(PhileOS.ID, "Paint")
                elseif choice == "Open" then
                    local location = PhileOS.openDialog(PhileOS.ID, "openFile", {})
                    location = location or "rom/dzfdxkgfdxgfcvhf/gxfgfcvgh/fdcg/f/tgfdx/cg"
                    if fs.exists(location) then
                        if fs.isDir(location) then
                            PhileOS.openDialog(PhileOS.ID, "button", {"You can't open a folder!", "Ok", "", "", ""})
                        else
                            local file = fs.open(location, "rb")
                            local text = file.readAll()
                            file.close()
                            PSx = string.byte(text:sub(1, 1))
                            PSy = string.byte(text:sub(2, 2))
                            pxl.setup(3, 4, math.ceil(PSx / 2 * 3), PSy)
                            pxl.clear(colours.white)
                            pxl.loadImage(text, "PHIMG", 1, 1)
                            currentlyEditing = location
                            undo = {}
                            redo = {}
                            PhileOS.setName(PhileOS.ID, "Paint - "..currentlyEditing:sub(math.max(#currentlyEditing - (Sx - 17), 1)))
                            saved = ""
                        end
                    end
                elseif choice == "Save" then
                    if currentlyEditing == "" then choice = "Save As"
                    else
                        local file = fs.open(currentlyEditing, "wb")
                        file.write(pxl.exportToPhimg())
                        file.close()
                        saved = ""
                        undo = {}
                        redo = {}
                        PhileOS.setName(PhileOS.ID, "Paint - "..(currentlyEditing..saved):sub(math.max(#currentlyEditing - (Sx - 17), 1)))
                    end
                end
                if choice == "Save As" then
                    local location = PhileOS.openDialog(PhileOS.ID, "saveFile", {})
                    if location == nil then
                    else
                        currentlyEditing = location
                        local file = fs.open(currentlyEditing, "wb")
                        file.write(pxl.exportToPhimg(true))
                        file.close()
                        saved = ""
                        undo = {}
                        redo = {}
                        PhileOS.setName(PhileOS.ID, "Paint - "..(currentlyEditing..saved):sub(math.max(#currentlyEditing - (Sx - 17), 1)))
                    end
                end
            elseif option == 3 then
                local choice = PhileOS.openRClick(PhileOS.ID, 6 + #menu[3], 2, {"1", "2", "3", "4", "5", "6", "7", "8", "9"}, true)
                if choice ~= nil then
                    menu[3] = menu[3]:sub(1, -2)..choice
                    brushSize = tonumber(choice)
                end
            elseif option == 4 then
                PhileOS.openDialog(PhileOS.ID, "button", {"More options coming soon", "Ok", "", "", ""})
                --local choice = PhileOS.openRClick(PhileOS.ID, 17, 2, {"Box", "Triangle", "RightTri", "Diamond", "Ellipse", "Octagon"}, true)
                --if choice ~= nil then
                --    menu[4] = choice.."\31"
                --    shape = choice
                --end
            elseif option == 5 then
                local choice = PhileOS.openRClick(PhileOS.ID, 18 + #menu[5], 2, {"Fill", "Outline", "Fill&Outline"}, true)
                if choice ~= nil then
                    menu[5] = choice.."\31"
                    fill = choice
                end
            end
        elseif e[3] >= 11 + math.ceil(PSx / 2 * 3) + add and e[3] <= 13 + math.ceil(PSx / 2 * 3) + add and e[4] >= 2 + PSy and e[4] <= 4 + PSy then
            resize = true
            Xc, Yc = pxl.getGridCoord(e[3] - 10, e[4] - 2)
            PPSx = PSx
            PPSy = PSy
            prev = pxl.exportToPhimg()
            table.insert(undo, {prev, PSx, PSy})
        end
    end
    if (e[1] == "mouse_click" or e[1] == "mouse_drag" or e[1] == "mouse_up") and e[3] >= 11 and e[3] <= 10 + math.floor(PSx / 2 * 3) and e[4] >= 3 and e[4] <= 2 + PSy and e[2] <= 2 then
        local col = 0
        if e[2] == 1 then
            col = lcol
        else
            col = rcol
        end
        local Pix, Piy = pxl.getGridCoord(e[3] - 10, e[4] - 2)
        if seltool == 1 then
            if e[1] == "mouse_click" then
                table.insert(undo, {pxl.exportToPhimg(), PSx, PSy})
            end
            pxl.circle(Pix, Piy, (brushSize - 1) / 2, col, true)
        elseif seltool == 2 then
            if e[1] == "mouse_click" then
                table.insert(undo, {pxl.exportToPhimg(), PSx, PSy})
            end
            pxl.fill(Pix, Piy, col)
        elseif seltool == 3 then
            if e[1] == "mouse_click" then
                Xc = Pix
                Yc = Piy
                prev = pxl.exportToPhimg()
                table.insert(undo, {prev, PSx, PSy})
            elseif e[1] == "mouse_up" or (e[1] == "mouse_drag" and (PSx * PSy <= 1600)) then
                pxl.loadImage(prev, "PHIMG", 1, 1)
                pxl.line(Xc, Yc, Pix, Piy, col, brushSize)
            end
        elseif seltool == 4 then
            if shape == "Box" then
                if e[1] == "mouse_click" then
                    Xc = Pix
                    Yc = Piy
                    prev = pxl.exportToPhimg()
                    table.insert(undo, {prev, PSx, PSy})
                elseif e[1] == "mouse_up" or (e[1] == "mouse_drag" and (PSx * PSy <= 1600)) then
                    pxl.loadImage(prev, "PHIMG", 1, 1)
                    if fill == "Outline" then
                        pxl.box(Xc, Yc, Pix, Piy, col, false, brushSize)
                    elseif fill == "Fill" then
                        pxl.box(Xc, Yc, Pix, Piy, col, true)
                    elseif fill == "Fill&Outline" then
                        pxl.box(Xc, Yc, Pix, Piy, rcol, true)
                        pxl.box(Xc, Yc, Pix, Piy, lcol, false, brushSize)
                    end
                end
            end
        end
    end
end