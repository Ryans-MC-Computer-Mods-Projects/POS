--PhileOS Notepad

--Variables
local Sx, Sy = term.getSize()
local menu = {"File", "About"}
local text = ""
local currentlyEditing = nil
local args = {...}
local saved = ""

term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
term.clear()

if args[1] then
    local location = args[1]
    if fs.exists(location) then
        if fs.isDir(location) then
            PhileOS.openDialog(PhileOS.ID, "button", {"You can't open a folder!", "Ok", "", "", ""})
        else
            local file = fs.open(location, "r")
            text = file.readAll()
            file.close()
            currentlyEditing = location
            PhileOS.setName(PhileOS.ID, "Notepad - ".. currentlyEditing:sub(math.max(#currentlyEditing - (Sx - 19), 1)))
        end
    else
    end
end

local Scx = 1
local Scy = 1

local Ln = 1
local Col = 1



--Functions

local function TextToTable(Text)
    local ret = {}
    while true do
        local nl = string.find(Text, "\n")
        if not nl then break end
        lin = Text:sub(1, nl - 1)
        Text = Text:sub(nl + 1)
        table.insert(ret, lin)
    end
    table.insert(ret, Text)
    return ret
end

local function TableToText(Table)
    local ret = ""
    for i, v in pairs(Table) do
        ret = ret..v
        if i ~= #Table then ret = ret.."\n" end
    end
    if ret ~= text and saved == "" then
        saved = "*"
        PhileOS.setName(PhileOS.ID, "Notepad - "..((currentlyEditing or "")..saved):sub(math.max(#((currentlyEditing or "")..saved) - (Sx - 19), 1)))
    end
    return ret
end

--Main Program

while true do
    term.setCursorBlink(false)
    term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.clear()
    term.setCursorPos(1, 1)
    term.setBackgroundColour(PhileOS.getSetting("theme", "windowColour"))
    term.setTextColour(PhileOS.getSetting("theme", "windowTextColour"))
    local remaining = Sx - (#("Ln "..Ln..", Col "..Col))
    for _, v in pairs(menu) do
        term.write(v)
        term.write(" ")
        remaining = remaining - (#v + 1)
    end
    term.write((" "):rep(remaining))
    term.write("Ln "..Ln..", Col "..Col)
    

    term.setBackgroundColour(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.setTextColour(PhileOS.getSetting("theme", "defTextColour"))
    local textTable = TextToTable(text)
    for i = Scy, Scy + (Sy - 2) do
        if textTable[i] then
            term.setCursorPos(Scx, i - Scy + 2)
            term.write(textTable[i])
        end
    end
    term.setCursorPos((Col + Scx) - 1, (Ln - Scy) + 2)
    term.setTextColour(colours.black)
    if (Ln - Scy) + 2 > 1 then
        term.setCursorBlink(true)
    end
    local oldLn = Ln
    local oldCol = Col
    local e = table.pack(os.pullEvent())
    if e[1] == "term_resize" then
        Sx, Sy = term.getSize()
        if currentlyEditing then
            PhileOS.setName(PhileOS.ID, "Notepad - "..(currentlyEditing..saved):sub(math.max(#currentlyEditing - (Sx - 19), 1)))
        end
    elseif e[1] == "key" then
        if e[2] == keys.left and Col > 1 then
            Col = Col - 1
        elseif e[2] == keys.right and Col <= #textTable[Ln] then
            Col = Col + 1
        elseif e[2] == keys.up and Ln > 1 then
            Ln = Ln - 1
            if Col > #textTable[Ln] + 1 then Col = #textTable[Ln] + 1 end
        elseif e[2] == keys.down and Ln < #textTable then
            Ln = Ln + 1
            if Col > #textTable[Ln] + 1 then Col = #textTable[Ln] + 1 end
        elseif e[2] == keys.backspace then
            if Col == 1 then
                if Ln ~= 1 then
                    Ln = Ln - 1
                    Col = #textTable[Ln] + 1
                    textTable[Ln] = textTable[Ln].. textTable[Ln + 1]
                    table.remove(textTable, Ln + 1)
                    text = TableToText(textTable)
                end
            else
                textTable[Ln] = textTable[Ln]:sub(1, Col - 2)..textTable[Ln]:sub(Col)
                text = TableToText(textTable)
                Col = Col - 1
            end
        elseif e[2] == keys.enter then
            table.insert(textTable, Ln + 1, textTable[Ln]:sub(Col))
            textTable[Ln] = textTable[Ln]:sub(1, Col - 1)
            text = TableToText(textTable)
            Ln = Ln + 1
            Col = 1
        end
    elseif e[1] == "char" then
        textTable[Ln] = textTable[Ln]:sub(1, Col - 1)..e[2]..textTable[Ln]:sub(Col)
        text = TableToText(textTable)
        Col = Col + 1
    elseif e[1] == "paste" then
        textTable[Ln] = textTable[Ln]:sub(1, Col - 1)..e[2]..textTable[Ln]:sub(Col)
        text = TableToText(textTable)
        Col = Col + #e[2]
    elseif e[1] == "mouse_click" then
        if e[2] == 1 then --Left Click
            if e[4] == 1 then -- Menu bar
                local option = nil
                local check = e[3]
                for i, v in pairs(menu) do
                    if check <= #v then
                        option = v
                        break
                    end
                    if check <= #v + 1 then break end
                    check = check - (#v + 1)
                end

                if option == "File" then
                    local choice = PhileOS.openRClick(PhileOS.ID, 1, 2, {"New", "Open", "Save", "Save As"})
                    if choice == "New" then
                        text = ""
                        Ln = 1
                        Col = 1
                        currentlyEditing = nil
                        PhileOS.setName(PhileOS.ID, "Notepad")
                    elseif choice == "Open" then
                        local location = PhileOS.openDialog(PhileOS.ID, "openFile", {})
                        location = location or "rom/dzfdxkgfdxgfcvhf/gxfgfcvgh/fdcg/f/tgfdx/cg"
                        if fs.exists(location) then
                            if fs.isDir(location) then
                                PhileOS.openDialog(PhileOS.ID, "button", {"You can't open a folder!", "Ok", "", "", ""})
                            else
                                local file = fs.open(location, "r")
                                text = file.readAll()
                                file.close()
                                Ln = 1
                                Col = 1
                                currentlyEditing = location
                                PhileOS.setName(PhileOS.ID, "Notepad - "..currentlyEditing:sub(math.max(#currentlyEditing - (Sx - 19), 1)))
                                saved = ""
                            end
                        end
                    elseif choice == "Save" then
                        if currentlyEditing == nil then choice = "Save As"
                        else
                            local file = fs.open(currentlyEditing, "w")
                            file.write(text)
                            file.close()
                            saved = ""
                            PhileOS.setName(PhileOS.ID, "Notepad - "..(currentlyEditing..saved):sub(math.max(#currentlyEditing - (Sx - 19), 1)))
                        end
                    end
                    if choice == "Save As" then
                        local location = PhileOS.openDialog(PhileOS.ID, "saveFile", {})
                        if location == nil then
                        else
                            currentlyEditing = location
                            local file = fs.open(currentlyEditing, "w")
                            file.write(text)
                            file.close()
                            saved = ""
                            PhileOS.setName(PhileOS.ID, "Notepad - "..(currentlyEditing..saved):sub(math.max(#currentlyEditing - (Sx - 19), 1)))
                        end
                    end
                elseif option == "About" then
                    PhileOS.openDialog(PhileOS.ID, "button", {"Phile OS Notepad\nMade by Ryan in 2023", "Ok", "", "", ""})
                end
            else
                Ln = e[4] + Scy - 2
                if Ln < 1 then Ln = 1 end
                if Ln > #textTable then Ln = #textTable end
                Col = e[3] - Scx + 1
                if Col < 1 then Col = 1 end
                if Col > #textTable[Ln] + 1 then Col = #textTable[Ln] + 1 end
            end
        end
    elseif e[1] == "mouse_scroll" then
        Scy = Scy + e[2]
    end
    if oldLn ~= Ln  then
        local LnSC = (Ln - Scy) + 2
        while LnSC < 2 do
            Scy = Scy - 1
            LnSC = (Ln - Scy) + 2
        end
        while LnSC > Sy do
            Scy = Scy + 1
            LnSC = (Ln - Scy) + 2
        end
    end
    if oldCol ~= Col then
        local ColSC = (Col + Scx) - 1
        while ColSC < 1 do
            Scx = Scx + 1
            ColSC = (Col + Scx) - 1
        end
        while ColSC > Sx do
            Scx = Scx - 1
            ColSC = (Col + Scx) - 1
        end
    end
    if Scy < 1 then Scy = 1 end
end