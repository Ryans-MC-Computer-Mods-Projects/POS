local function cut(str,len,pad)
    pad = pad or " "
    return str:sub(1,len) .. pad:rep(len - #str)
end

local pUtils = require("PhileUtils")

explorfs = {}

explorfs.list = function(dir)
    if dir == "Trash" then
        return pUtils.trash.list()
    else
        return fs.list(dir)
    end
end

explorfs.isDir = function(path)
    if path:sub(1, 5) == "Trash" then
        return false
    else
        return fs.isDir(path)
    end
end

explorfs.getSize = function(path)
    if path:sub(1, 5) == "Trash" then
        return fs.getSize("/PhileOS/.Trash/"..path:sub(6)..".trash")
    else
        return fs.getSize(path)
    end
end

explorfs.isReadOnly = function(path)
    if path:sub(1, 5) == "Trash" then
        return false
    else
        return fs.isReadOnly(path)
    end
end

local Tx, Ty = term.getSize()
local sel = -10
local args = {...}
if args[1] == "Trash" then
    PhileOS.setName(PhileOS.ID, "Trash")
end
if args[2] == "open" then
    PhileOS.setName(PhileOS.ID, "Open")
end
if args[2] == "save" then
    PhileOS.setName(PhileOS.ID, "Save")
end
local dir = args[1] or "/"
local scroll = 0
local showHidden = false

local function drawFile(file, y, sel)
    local actName = nil
    if file:sub(1, 5) == "Trash" then
        local fh = fs.open("/PhileOS/.Trash/path_"..file:sub(6)..".trash", "r")
        actName = fh.readAll()
        fh.close()
    end
    term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.setTextColor(PhileOS.getSetting("theme", "defTextColour"))
    local name =  fs.getName(actName or file)
    local ext = PhileOS.GetExt(actName or file)
    local isFolder = explorfs.isDir(file)
    local size = explorfs.getSize(file)
    local ro = explorfs.isReadOnly(file)
    if ro then
        term.setTextColour(PhileOS.getSetting("theme", "defDeselTextColour"))
    end
    if sel then
        term.setBackgroundColor(PhileOS.getSetting("theme", "defSelBGColour"))
        term.setTextColor(PhileOS.getSetting("theme", "defSelTextColour"))
    end
    if isFolder then
        size = ""
    else
        local dot = string.find(string.reverse(name), "%.")
        if dot then
            dot = #name - dot + 1
        end
        if size < 10000 then
            size = string.rep(" ", 4 - #tostring(size))..size.."B"
        elseif size < 100000 then
            size = " "..string.sub(size, 1, 2).."KB"
        elseif size < 1000000 then
            size = string.sub(size, 1, 3).."KB"
        elseif size < 10000000 then
            size = string.sub(size, 1, 1).."."..string.sub(size, 2, 1).."MB"
        elseif size < 100000000 then
            size = " "..string.sub(size, 1, 2).."MB"
        elseif size < 1000000000 then
            size = string.sub(size, 1, 3).."MB"
        end
    end
    term.setCursorPos(1, y)
    term.write(cut(name, Tx - 12))
    term.setCursorPos(Tx - 11, y)
    term.write(cut(ext, 6).." ")
    term.setCursorPos(Tx - 4, y)
    term.write(cut(size, 5))
end

local function drawFolder(folder)
    term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.setTextColor(PhileOS.getSetting("theme", "defTextColour"))
    term.clear()
    local files = explorfs.list(folder)
    local f2 = {}
    local f3 = {}
    for i, v in pairs(files) do
        if v:sub(1, 1) == "." and not showHidden then
        else
            if not explorfs.isDir(folder..v) then
                table.insert(f3, v)
            else
                table.insert(f2, v)
            end
        end
    end
    for i, v in pairs(f3) do
        table.insert(f2, v)
    end
    for i, v in pairs(f2) do
        if i == sel then
            drawFile(folder..v, i + 3 - scroll, true)
        else
            drawFile(folder..v, i + 3 - scroll)
        end
    end
    term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.setTextColor(PhileOS.getSetting("theme", "defTextColour"))
    term.setCursorPos(1, 1)
    term.write(cut(folder, Tx - 1).."\171")
    term.setCursorPos(Tx - 2, 1)
    if showHidden then
        term.write("S")
    else
        term.write("H")
    end
    term.setCursorPos(1, 2) 
    term.write("File"..(" "):rep(Tx - 16).."Type   Size ")
    term.setCursorPos(1, 3)
    term.write(("\140"):rep(Tx))
    return f2
end

local fileToOpen = ""
local curPosSave = 1

while true do
    if args[1] == "Trash" and dir ~= "Trash" then
        PhileOS.setName(PhileOS.ID, "explorer")
        args[1] = nil
    end
    local files = drawFolder(dir, scroll)
    local Sx, Sy = term.getSize()
    if args[2] == "open" or args[2] == "save" then
        term.setBackgroundColor(PhileOS.getSetting("theme", "windowColour"))
        term.setCursorPos(1, Sy - 2)
        term.write((" "):rep(Sx))
        term.setCursorPos(1, Sy - 1)
        term.write((" "):rep(Sx))
        term.setCursorPos(1, Sy)
        term.write((" "):rep(Sx))
        term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
        term.setTextColor(PhileOS.getSetting("theme", "defTextColour"))
        term.setCursorPos(2, Sy - 1)
        term.write((fileToOpen or "")..(" "):rep(Sx - 18 - #(fileToOpen or "")))
        term.setCursorPos(Sx - 15, Sy - 1)
        if args[2] == "open" then
            term.write(" Open ")
        else
            term.write(" Save ")
        end
        term.setCursorPos(Sx - 8, Sy - 1)
        term.write(" Cancel ")
    end
    if args[2] == "save" then
        term.setCursorPos(1 + curPosSave, Sy - 1)
        term.setTextColor(PhileOS.getSetting("theme", "defTextColour"))
        term.setCursorBlink(true)
    end
    local e = table.pack(os.pullEvent())
    if e[1] == "term_resize" then
        Tx, Ty = term.getSize()
    elseif e[1] == "mouse_click" and (args[2] == "open" or args[2] == "save") and e[4] >= Sy - 2 then
        if e[4] == Sy - 1 then
            if e[3] >= Sx - 15 and e[3] <= Sx - 10 and fileToOpen ~= "" and not fs.isDir(dir..fileToOpen) then
                local doit = true
                if args[2] == "save" and fs.exists(dir..fileToOpen) then
                    local overwrite = PhileOS.openDialog(PhileOS.ID, "button", {fileToOpen.."\nalready exists.\ndo you want to replace\nit?", "Yes", "No", "", ""})
                    if overwrite ~= "Yes" then
                        doit = false
                    end
                end
                if doit then
                    PhileOS.setStatus(PhileOS.ID, dir..fileToOpen)
                end
            elseif e[3] >= Sx - 8 and e[3] <= Sx - 1 then
                return
            end
        end
    elseif e[1] == "mouse_click" and e[2] == 1 then
        if e[4] - 3 + scroll == sel then
            if dir == "Trash" then
            elseif fs.isDir(dir..files[sel]) then
                dir = dir..files[sel].."/"
                sel = -10
                scroll = 0
            elseif args[2] == "open" then
                PhileOS.setStatus(PhileOS.ID, dir..files[sel])
            elseif args[2] == "save" then
                local overwrite = PhileOS.openDialog(PhileOS.ID, "button", {files[sel].."\nalready exists.\ndo you want to replace\nit?", "Yes", "No", "", ""})
                if overwrite == "Yes" then
                    PhileOS.setStatus(PhileOS.ID, dir..files[sel])
                end
            else
                local prog = PhileOS.OpenFile(dir..files[sel])
                if prog == nil then
                    PhileOS.OpenWith(dir..files[sel])
                end
            end
            sel = -10
        elseif e[3] == Tx and e[4] == 1 and dir ~= "/" then
            dir = "/"..fs.getDir(dir:sub(1, -2)).."/"
            if dir == "//" then dir = "/" end
            sel = -10
            scroll = 0
        elseif e[3] == Tx - 2 and e[4] == 1 then
            showHidden = not showHidden
        elseif e[4] > 3 and e[4] < 4 + #files - scroll then 
            sel =  e[4] - 3 + scroll
            if not fs.isDir(dir..files[sel]) then
                fileToOpen = files[sel]
                curPosSave = #fileToOpen + 1
            end
        else 
            sel = -10
        end
    elseif e[1] == "mouse_click" and e[2] == 2 then
        if e[4] > 3 then
            local option = nil
            if e[4] - 3 + scroll > #files and fs.isReadOnly(dir) then
            elseif dir == "Trash" and e[4] - 3 + scroll > #files then
                option = PhileOS.openRClick(PhileOS.ID, e[3], e[4], {"Empty Trash"})
            elseif dir == "Trash" then
                option = PhileOS.openRClick(PhileOS.ID, e[3], e[4], {"Recover", "Delete", "", "Empty Trash"})
            elseif e[4] - 3 + scroll > #files then
                option = PhileOS.openRClick(PhileOS.ID, e[3], e[4], {"New Folder", "New File", "Paste"})
            elseif fs.isReadOnly(dir..files[e[4] - 3 + scroll]) and fs.isDir(dir..files[e[4] - 3 + scroll]) then
                option = PhileOS.openRClick(PhileOS.ID, e[3], e[4], {"Open", "Open in new Window", "", "Pin to Desktop", "", "Copy" })
            elseif fs.isReadOnly(dir..files[e[4] - 3 + scroll]) then
                option = PhileOS.openRClick(PhileOS.ID, e[3], e[4], {"Open", "Open With", "Run", "", "Pin to Desktop", "Pin to Start", "", "Copy"})
            elseif fs.isDir(dir..files[e[4] - 3 + scroll]) then
                option = PhileOS.openRClick(PhileOS.ID, e[3], e[4], {"Open", "Open in new Window", "", "Pin to Desktop", "", "Copy", "Cut", "", "Rename", "Delete", "", "New Folder", "New File", "Paste"})
            else
                option = PhileOS.openRClick(PhileOS.ID, e[3], e[4], {"Open", "Open With", "Run", "", "Pin to Desktop", "Pin to Start", "", "Copy", "Cut", "", "Rename", "Delete", "", "New Folder", "New File", "Paste"})
            end
            if option == "New Folder" then
                local name = nil
                local ne = false
                while name == nil do
                    if ne then
                        name = PhileOS.openDialog(PhileOS.ID, "textInput", {"That already exists! \n Name for New Folder", "New Folder"})
                    else
                        name = PhileOS.openDialog(PhileOS.ID, "textInput", {"Name for New Folder", "New Folder"})
                    end
                    ne = false
                    if name ~= nil then
                        if fs.exists(dir..name) then name = nil ne = true end
                    end
                end
                local illegalChars = string.find(name, "[\"*/:<>?\\|]")
                if illegalChars then
                    PhileOS.openDialog(PhileOS.ID, "button", {"You cant use the following in folder names: \" * / : < > ? \\ |", "Ok!", "", "", ""})
                else
                    fs.makeDir(dir..name)
                end
            elseif option == "New File" then
                local name = nil
                local ne = false
                while name == nil do
                    if ne then
                        name = PhileOS.openDialog(PhileOS.ID, "textInput", {"That already exists! \n Name for New File", "New File"})
                    else
                        name = PhileOS.openDialog(PhileOS.ID, "textInput", {"Name for New File", "New File"})
                    end
                    ne = false
                    if name ~= nil then
                        if fs.exists(dir..name) then name = nil ne = true end
                    end
                end
                local illegalChars = string.find(name, "[\"*/:<>?\\|]")
                if illegalChars then
                    PhileOS.openDialog(PhileOS.ID, "button", {"You cant use the following in file names: \" * / : < > ? \\ |", "Ok!", "", "", ""})
                else
                    local file = fs.open(dir..name, "w")
                    file.close()
                end
            elseif option == "Copy" then
                PhileOS.setClipboard("filecopy://"..dir..files[e[4] - 3 + scroll])
            elseif option == "Cut" then
                PhileOS.setClipboard("filecut://"..dir..files[e[4] - 3 + scroll])
            elseif option == "Paste" then
                local file = PhileOS.getClipboard()
                if file:sub(1, 11) == "filecopy://" then
                    local fil = file:sub(12)
                    if fs.exists(fil) then 
                        local fromdir = fs.getDir(fil)
                        local filename = fs.getName(fil)
                        if fs.exists(dir..filename) then
                            local num = 2
                            local fn2 = filename
                            while fs.exists(dir..fn2) do
                                fn2 = filename..num
                                num = num + 1  
                            end
                            filename = fn2
                        end
                        fs.copy(fil, dir..filename)
                    else   
                        PhileOS.openDialog(PhileOS.ID, "button", {"Clipboard doesnt contain a file!", "Ok!", "", "", ""})
                    end
                elseif file:sub(1, 10) == "filecut://" then
                    local fil = file:sub(11)
                    if fs.exists(fil) then 
                        local fromdir = fs.getDir(fil)
                        local filename = fs.getName(fil)
                        if fs.exists(dir..filename) then
                            local num = 2
                            local fn2 = filename
                            while fs.exists(dir..fn2) do
                                fn2 = filename..num
                                num = num + 1  
                            end
                            filename = fn2
                        end
                        fs.copy(fil, dir..filename)
                        fs.delete(fil)
                    else   
                        PhileOS.openDialog(PhileOS.ID, "button", {"Clipboard doesnt contain a file!", "Ok!", "", "", ""})
                    end
                else
                    PhileOS.openDialog(PhileOS.ID, "button", {"Clipboard doesnt contain a file!", "Ok!", "", "", ""})
                end
            elseif option == "Rename" then
                local name = nil
                local ne = false
                while name == nil do
                    if ne then
                        name = PhileOS.openDialog(PhileOS.ID, "textInput", {"That already exists! \n New Name for "..files[e[4] - 3 + scroll], files[e[4] - 3 + scroll]})
                    else
                        name = PhileOS.openDialog(PhileOS.ID, "textInput", {"New Name for "..files[e[4] - 3 + scroll], files[e[4] - 3 + scroll]})
                    end
                    ne = false
                    if name ~= nil then
                        if fs.exists(dir..name) then name = nil ne = true end
                    end
                end
                fs.move(dir..files[e[4] - 3 + scroll], dir..name)
            elseif option == "Delete" then
                if dir == "Trash" then
                    local fh = fs.open("/PhileOS/.Trash/path_"..files[e[4] - 3 + scroll]..".trash", "r")
                    local actName = fs.getName(fh.readAll())
                    fh.close()
                    local delete = nil
                    while delete == nil do
                        delete = PhileOS.openDialog(PhileOS.ID, "button", {"Are you sure you want to delete "..actName.."?", "Yes", "No", "", ""})
                    end
                    if delete == "Yes" then
                       pUtils.trash.delete(files[e[4] - 3 + scroll])
                    end
                elseif fs.isDir(dir..files[e[4] - 3 + scroll]) then
                    local delete = nil
                    while delete == nil do
                        delete = PhileOS.openDialog(PhileOS.ID, "button", {"Are you sure you want to delete "..files[e[4] - 3 + scroll].."\n and send it's contents to the trash?", "Yes", "No", "", ""})
                    end
                    if delete == "Yes" then
                        local todel = fs.list(dir..files[e[4] - 3 + scroll])
                        local hasDir = false
                        for i, v in pairs(todel) do
                            if fs.isDir(dir..files[e[4] - 3 + scroll].."/"..v) then
                                hasDir = true
                            else
                                pUtils.trash.send(dir..files[e[4] - 3 + scroll].."/"..v)
                            end                            
                        end
                        if hasDir then
                            PhileOS.openDialog(PhileOS.ID, "button", {"Folder wasn't deleted because it contained other\nfolders, delete them first to delete this folder.", "Ok", "", "", ""})
                        else
                            fs.delete(dir..files[e[4] - 3 + scroll])
                        end
                    end
                else
                    local delete = nil
                    while delete == nil do
                        delete = PhileOS.openDialog(PhileOS.ID, "button", {"Are you sure you want to send "..files[e[4] - 3 + scroll].."\nto the trash?", "Yes", "No", "", ""})
                    end
                    if delete == "Yes" then
                        pUtils.trash.send(dir..files[e[4] - 3 + scroll])
                    end
                end
            elseif option == "Recover" then
                pUtils.trash.recover(files[e[4] - 3 + scroll])
            elseif option == "Empty Trash" then
                local delete = nil
                    while delete == nil do
                        delete = PhileOS.openDialog(PhileOS.ID, "button", {"Are you sure you want to delete all "..#files.." files in\nthe trash?", "Yes", "No", "", ""})
                    end
                    if delete == "Yes" then
                        for i, v in pairs(files) do
                            pUtils.trash.delete(v)
                        end
                    end
            elseif option == "Run" then
                PhileOS.openProgram(dir..files[e[4] - 3 + scroll])
            elseif option == "Open" then
                if fs.isDir(dir..files[e[4] - 3 + scroll]) then
                    dir = dir..files[e[4] - 3 + scroll].."/"
                else
                    PhileOS.OpenFile(files[e[4] - 3 + scroll])
                    if prog == nil then
                        PhileOS.OpenWith(dir..files[sel])
                    end
                end
            elseif option == "Open With" then
                --local ow = nil
                --while ow == nil do
                --    ow = PhileOS.openDialog(PhileOS.ID, "textInput", {"Open With", ""})
                --end
                --if fs.exists(ow) then
                --    PhileOS.openProgram(ow, nil, nil, nil, nil, dir..files[e[4] - 3 + scroll])
                --else
                --    PhileOS.openDialog(PhileOS.ID, "button", {"Program doesn't exist!", "Ok!", "", "", ""})
                --end
                PhileOS.OpenWith(dir..files[e[4] - 3 + scroll])
            elseif option == "Open in new Window" then
                PhileOS.openProgram("PhileOS/explorer.lua", nil, nil, nil, nil, dir..files[e[4] - 3 + scroll].."/")
            elseif option == "Pin to Start" then
                local file = fs.open("/PhileOS/Settings/start.set", "r")
				local pins = textutils.unserialise(file.readAll())
				file.close()
                table.insert(pins, dir..files[e[4] - 3 + scroll])
                local file = fs.open("/PhileOS/Settings/start.set", "w")
				file.write(textutils.serialise(pins))
				file.close()
            elseif option == "Pin to Desktop" then
                local file = fs.open("/PhileOS/Settings/desktop.set", "r")
				local pins = textutils.unserialise(file.readAll())
				file.close()
                local name = fs.getName(dir..files[e[4] - 3 + scroll])
                local extn = PhileOS.GetExt(name)
                if not fs.isDir(dir..files[e[4] - 3 + scroll]) then
                    name = name:sub(1, -(#extn + 2))
                end
                if fs.isDir(dir..files[e[4] - 3 + scroll]) then
                    table.insert(pins[1], {name, dir..files[e[4] - 3 + scroll].."/"})
                else
                    table.insert(pins[1], {name, dir..files[e[4] - 3 + scroll]})
                end
                local file = fs.open("/PhileOS/Settings/desktop.set", "w")
				file.write(textutils.serialise(pins))
				file.close()
            end
        end
    elseif e[1] == "mouse_scroll" then
        scroll = scroll + e[2]
        if scroll > #files - (Ty - 3) then scroll = #files - (Ty - 3) end
        if scroll < 0 then scroll = 0 end
    elseif e[1] == "char" and args[2] == "save" then
        fileToOpen = fileToOpen:sub(1, curPosSave - 1)..e[2]..fileToOpen:sub(curPosSave)
        curPosSave = curPosSave + 1
    elseif e[1] == "key" and args[2] == "save" then
        if e[2] == keys.left and curPosSave > 1 then
            curPosSave = curPosSave - 1
        elseif e[2] == keys.right and curPosSave <= #fileToOpen then
            curPosSave = curPosSave + 1
        elseif e[2] == keys.backspace then
            fileToOpen = fileToOpen:sub(1, curPosSave - 2)..fileToOpen:sub(curPosSave)
            curPosSave = curPosSave - 1
        end
    end
end