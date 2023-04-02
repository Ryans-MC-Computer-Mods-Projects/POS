local utils = {}

utils.trash = {}

utils.trash.send = function(file)
    if not fs.exists(file) then
        error(file.." doesn't exist!")
    end
    if fs.isDir(file) then
        error("Deleting directories isn't supported (yet)!")
    end
    local id = nil
    while id == nil do
        id = math.random(2000000000)
        if fs.exists("/PhileOS/.Trash/"..id..".trash") then
            id = nil
        end
    end
    fs.copy(file, "/PhileOS/.Trash/"..id..".trash")
    local fh = fs.open("/PhileOS/.Trash/path_"..id..".trash", "w")
    fh.write(file)
    fh.close()
    fs.delete(file)
end

utils.trash.list = function()
    local files = fs.list("/PhileOS/.Trash/")
    local numbers = {}
    for i, v in pairs(files) do
        if v:sub(-6) == ".trash" then
            local name = v:sub(1, -7)
            if tonumber(name) then
                table.insert(numbers, tonumber(name))
            end
        end
    end
    local ret = {}
    for i, v in pairs(numbers) do
        if fs.exists("/PhileOS/.Trash/path_"..v..".trash") then
            table.insert(ret, tostring(v))
        end
    end
    return ret
end

utils.trash.recover = function(number)
    if fs.exists("/PhileOS/.Trash/"..number..".trash") and fs.exists("/PhileOS/.Trash/path_"..number..".trash") then
        local fh = fs.open("/PhileOS/.Trash/path_"..number..".trash", "r")
        local path = fh.readAll()
        fh.close()

        fh = fs.open("/PhileOS/.Trash/"..number..".trash", "r")
        local content = fh.readAll()
        fh.close()

        if fs.exists(path) then error("File exists there!") end
        fh = fs.open(path, "w")
        fh.write(content)
        fh.close()

        fs.delete("/PhileOS/.Trash/path_"..number..".trash")
        fs.delete("/PhileOS/.Trash/"..number..".trash")
    else
        error("File isn't in trash!")
    end
end

utils.trash.delete = function(number)
    if fs.exists("/PhileOS/.Trash/"..number..".trash") and fs.exists("/PhileOS/.Trash/path_"..number..".trash") then
        fs.delete("/PhileOS/.Trash/path_"..number..".trash")
        fs.delete("/PhileOS/.Trash/"..number..".trash")
    else
        error("File isn't in trash!")
    end
end

utils.renderPhimg = function(file, size, x, y, bgcol)
    local fileh = fs.open(file, "rb")
    local text = fileh.readAll()
    fileh.close()
    local PSx = string.byte(text:sub(1, 1))
    local PSy = string.byte(text:sub(2, 2))
    local fh = fs.open("/PhileOS/APIs/pxl.lua", "r")
    local pxl = load(fh:readAll())()
    fh.close()
    pxl.setup(size, 4, math.ceil(PSx / 2 * size), math.ceil(PSy / 3 * size))
    pxl.clear(bgcol)
    pxl.loadImage(text, "PHIMG", 1, 1, bgcol)
    pxl.draw(x, y)
end

utils.text = {}

utils.text.writeTextWrapped = function(text, width, indexToCheck)
    local Sx, Sy = term.getCursorPos()
    local x = 1
    local y = 1
    local retX = 0
    local retY = 0
    for i = 1, #text do
      term.setCursorPos(Sx + x - 1, Sy + y - 1)
      term.write(text:sub(i, i))
      if i == indexToCheck then
        retX = x
        retY = y
      end
      if text:sub(i, i) == " " then
        local ns = string.find(text:sub(i + 1), " ") or #text - i
        if x + ns > width then
          x = 1
          y = y + 1
        else
          x = x + 1
        end
      elseif x == width or text:sub(i, i) == "\n" then
        x = 1
        y = y + 1
      else
        x = x + 1
      end
    end
    if indexToCheck == #text + 1 then
      return x, y
    elseif retX > 0 then
      return retX, retY
    end
end

return utils