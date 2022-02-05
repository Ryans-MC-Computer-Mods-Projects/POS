--PXL drawing API

local grid = {}
local size = 0
local depth = 0
local Sx, Sy = term.getSize()
local GSx = 0
local GSy = 0

local pxl = {}

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

local NybToNum = {
	[0] = 1,
	[1] = 2,
	[2] = 4,
	[3] = 8,
	[4] = 16,
	[5] = 32,
	[6] = 64,
	[7] = 128,
	[8] = 256,
	[9] = 512, 
	[10] = 1024,
	[11] = 2048,
	[12] = 4096,
	[13] = 8192,
	[14] = 16384,
	[15] = 32768,
}

local NumToNyb = {
	[1]     = 0,
	[2]     = 1,
	[4]     = 2,
	[8]     = 3,
	[16]    = 4,
	[32]    = 5,
	[64]    = 6,
	[128]   = 7,
	[256]   = 8,
	[512]   = 9,
	[1024]  = 10,
	[2048]  = 11,
	[4096]  = 12,
	[8192]  = 13,
	[16384] = 14,
	[32768] = 15,
}

pxl.setup = function(Nsize, Ndepth, Sx, Sy, err)
    if Ndepth ~= 1 and Ndepth ~= 4 then error("Invalid depth!") end
    if Nsize ~= 1 and Nsize ~= 2 and Nsize ~= 3 then error("Invalid size!") end
	TSx, TSy = term.getSize()
	Sx = Sx or TSx
	Sy = Sy or TSy
	GSx = Sx
	GSy = Sy
    size = Nsize
    depth = Ndepth
	grid = {}
    for x = 1, math.floor((Sx * 2) / size) do
        grid[x] = {}
        for y = 1, math.floor((Sy * 3) / size) do
            if depth == 1 then
                grid[x][y] = 0
            else
                grid[x][y] = colours.black
            end
        end
    end
end

pxl.clear = function(colour)
	if size == 0 or depth == 0 then error("API not setup, please call pxl.setup(size, depth) first!") end
	if depth == 1 then
        if colour ~= 0 and colour ~= 1 then
            error("Invalid colour")
        end
    else
        local valid = false
		if size == 3 and colour == 0 then valid = true end
        for i, v in pairs(colours) do
            if v == colour then
                valid = true
            end
        end
        if not valid then
            error("Invalid colour")
        end
    end
	for x = 1, math.floor((GSx * 2) / size) do
        for y = 1, math.floor((GSy * 3) / size) do
            grid[x][y] = colour
        end
    end
end

local options = {{1, 2}, {1, 3}, {1, 4}, {1, 5}, {1, 6}, {2, 3}, {2, 4}, {2, 5}, {2, 6}, {3, 4}, {3, 5}, {3, 6}, {4, 5}, {4, 6}, {5, 6}}
local fudgeColours = function(colours)
	local bgc = nil
	local fgc = nil
	local segments = {0, 0, 0, 0, 0, 0}
	local works = true
	for i, v in pairs(colours) do
		if v == bgc then segments[i] = 0
		elseif v == fgc then segments[i] = 1
		elseif bgc == nil then bgc = v segments[i] = 0
		elseif fgc == nil then fgc = v segments[i] = 1
		else works = false break end
	end
	if works then
		if fgc == nil then
			return segments, bgc, colors.black
		else
			return segments, bgc, fgc
		end
	end
	--error("fudged!")
	local eror = math.huge
	for i, v in pairs(options) do
		local tmpBC = colours[v[1]]
		local tmpFC = colours[v[2]]
		for j = 0, 15 do
			local NewSegments = {}
			NewSegments[v[1]] = 0
			NewSegments[v[2]] = 1
			local po2 = 2
			for p = 1, 6 do
				if not NewSegments[p] then
					local bit = j % po2
					bit = bit / po2
					if bit >= 0.5 then
						NewSegments[p] = 1
					else
						NewSegments[p] = 0
					end
					po2 = po2 * 2
				end
			end
			local tempError = 0
			for p = 1, 6 do
				if p ~= v[1] and p ~= v[2] then
					local r, g, b = term.getPaletteColour(colours[p])
					local nr, ng, nb = 0, 0, 0
					if NewSegments[p] == 1 then
						nr, ng, nb = term.getPaletteColour(colours[v[2]])
					else
						nr, ng, nb = term.getPaletteColour(colours[v[1]])
					end
					tempError = tempError + math.abs(nr - r)
					tempError = tempError + math.abs(ng - g)
					tempError = tempError + math.abs(nb - b)
				end
			end
			if tempError < eror then
				bgc = tmpBC
				fgc = tmpFC
				segments = NewSegments
				eror = tempError
			end
		end
	end
	return segments, bgc, fgc
end

pxl.setSize = function(Nsize)
	if Nsize ~= 1 and Nsize ~= 2 and Nsize ~= 3 then error("Invalid size!") end
	size = Nsize
end

pxl.getGridCoord = function(xt, yt, lb)
	if size == 3 then
		if xt % 3 == 1 then
			return ((xt - 1) - (xt - 1)%3) / 3 * 2 + 1, yt
		elseif xt % 3 == 2 then
			if lb then
				return ((xt - 1) - (xt - 1)%3) / 3 * 2 + 1, yt
			else
				return ((xt - 1) - (xt - 1)%3) / 3 * 2 + 2, yt
			end
		elseif xt % 3 == 0 then
			return ((xt - 1) - (xt - 1)%3) / 3 * 2 + 2, yt
		end
	else
		error("Not Supported (yet)!")
	end
end

pxl.draw = function(xs, ys)
	xs = xs or 1
	ys = ys or 1
    if size == 0 or depth == 0 then error("API not setup, please call pxl.setup(size, depth) first!") end
    for y = 1, GSy do
		local text = ""
		local bg = ""
		local fg = ""
        for x = 1, GSx do
            if size == 1 then
                local segments = {grid[(x * 2) - 1][(y * 3) - 2], grid[(x * 2)][(y * 3) - 2], grid[(x * 2) - 1][(y * 3) - 1], grid[(x * 2)][(y * 3) - 1], grid[(x * 2) - 1][(y * 3)], grid[(x * 2)][(y * 3)]}
                local bgc = colours.black
                local fgc = colours.white
				if depth ~= 1 then
					segments, bgc, fgc = fudgeColours(segments)
                end
                local char = 0
                for i, v in pairs(segments) do
                    char = char + (math.pow(2, i - 1) * v)
                end
                if char > 31 then
                    char = 63 - char
                    local tmc = fgc
                    fgc = bgc
                    bgc = tmc
                end
                --term.setBackgroundColour(bgc)
                --term.setTextColour(fgc)
				bg = bg..colours.toBlit(bgc)
				fg = fg..colours.toBlit(fgc)
                --term.setCursorPos(x, y)
                --term.write(string.char(char + 128))
				text = text..string.char(char + 128)
			elseif size == 2 then
				if y % 2 == 1 then
					fgc = grid[x][((y - 1) - (y - 1)%2) / 2 * 3 + 1]
					bgc = grid[x][((y - 1) - (y - 1)%2) / 2 * 3 + 2]
					if fgc == 0 then fgc = colours.black end
					if fgc == 1 then fgc = colours.white end
					if bcc == 0 then bgc = colours.black end
					if bgc == 1 then bgc = colours.white end
					if bgc == nil then bgc = colours.black end
					--term.setBackgroundColour(bgc)
					--term.setTextColour(fgc)
					bg = bg..colours.toBlit(bgc)
					fg = fg..colours.toBlit(fgc)
					--term.setCursorPos(x, y)
					if bgc == fgc then
						--term.write(" ")
						text = text.." "
					else
						--term.write("\143")
						text = text.."\143"
					end
				else
					fgc = grid[x][((y - 1) - (y - 1)%2) / 2 * 3 + 2]
					bgc = grid[x][((y - 1) - (y - 1)%2) / 2 * 3 + 3]
					if fgc == 0 then fgc = colours.black end
					if fgc == 1 then fgc = colours.white end
					if bgc == 0 then bgc = colours.black end
					if bgc == 1 then bgc = colours.white end
					--term.setBackgroundColour(bgc)
					--term.setTextColour(fgc)
					bg = bg..colours.toBlit(bgc)
					fg = fg..colours.toBlit(fgc)
					--term.setCursorPos(x, y)
					if bgc == fgc then
						--term.write(" ")
						text = text.." "
					else
						--term.write("\131")
						text = text.."\131"
					end
				end
			elseif size == 3 then
				if x % 3 == 1 then
					bgc = grid[((x - 1) - (x - 1)%3) / 3 * 2 + 1][y]
					if bgc == 0 and depth ~= 1 then
						bg = bg.."0"
						fg = fg.."8"
						text = text.."\127"
					else
						if bgc == 0 then bgc = colours.black end
						if bgc == 1 then bgc = colours.white end
						bg = bg..colours.toBlit(bgc)
						fg = fg.."f"
						text = text.." "
					end
				elseif x % 3 == 2 then
					fgc = grid[((x - 1) - (x - 1)%3) / 3 * 2 + 1][y]
					if grid[((x - 1) - (x - 1)%3) / 3 * 2 + 2] then
						bgc = grid[((x - 1) - (x - 1)%3) / 3 * 2 + 2][y]
					else
						bgc = fgc
					end
					local Trans = 0
					if fgc == 0 and depth == 1 then 
						fgc = colours.black
					elseif fgc == 0 then 
						fgc = colours.white Trans = Trans + 1
					end
					if fgc == 1 then fgc = colours.white end
					if bgc == 0 and depth == 1 then 
						bgc = colours.black
					elseif bgc == 0 then
						bgc = colours.white Trans = Trans + 1
					end
					if bgc == 1 then bgc = colours.white end
					if Trans == 2 then
						bg = bg.."0"
						fg = fg.."8"
						text = text.."\127"
					elseif bgc == fgc then
						bg = bg..colours.toBlit(bgc)
						fg = fg..colours.toBlit(fgc)
						text = text.." "
					else
						bg = bg..colours.toBlit(bgc)
						fg = fg..colours.toBlit(fgc)
						text = text.."\149"
					end
				elseif x % 3 == 0 then
					bgc = grid[((x - 1) - (x - 1)%3) / 3 * 2 + 2][y]
					if bgc == 0 and depth ~= 1 then
						bg = bg.."0"
						fg = fg.."8"
						text = text.."\127"
					else
						if bgc == 0 then bgc = colours.black end
						if bgc == 1 then bgc = colours.white end
						bg = bg..colours.toBlit(bgc)
						fg = fg.."f"
						text = text.." "
					end
				end
            end
        end
		term.setCursorPos(xs, ys + y - 1)
		term.blit(text, fg, bg)
    end
end

pxl.dot = function(x, y, colour)
    if size == 0 or depth == 0 then error("API not setup, please call pxl.setup(size, depth) first!") end
	if depth == 1 then
        if colour ~= 0 and colour ~= 1 then
            error("Invalid colour")
        end
		if grid[x] then
			if grid[x][y] then
				grid[x][y] = colour
			end
		end
    else
        local valid = false
		if size == 3 and colour == 0 then valid = true end
        for i, v in pairs(colours) do
            if v == colour then
                valid = true
            end
        end
        if not valid then
            error("Invalid colour: "..(colour or "nil"))
        end
		if grid[x] then
			if grid[x][y] then
				grid[x][y] = colour
			end
		end
    end
end

pxl.line = function(x0, y0, x1, y1, colour, width)
	width = width or 1
	local line = function(x0, y0, x1, y1, colour)
		local dx = math.abs(x1 - x0)
		local sx = x0 < x1 and 1 or -1
		local dy = -math.abs(y1 - y0)
		local sy = y0 < y1 and 1 or -1
		local err = dx + dy
		while true do
			pxl.dot(x0, y0, colour)
			if x0 == x1 and y0 == y1 then break end
			local e2 = 2 * err
			if e2 >= dy then
				err = err + dy
				x0 = x0 + sx
			end
			if e2 <= dx then
				err = err + dx
				y0 = y0 + sy
			end
		end
	end
	if math.abs(y1 - y0) > math.abs(x1 - x0) then
		local Nx0 = x0 - math.floor(width / 2)
		local Nx1 = x1 - math.floor(width / 2)
		for xa = 1, width do
			line(Nx0 + xa - 1, y0, Nx1 + xa - 1, y1, colour)
		end
	else
		local Ny0 = y0 - math.floor(width / 2)
		local Ny1 = y1 - math.floor(width / 2)
		for ya = 1, width do
			line(x0, Ny0 + ya - 1, x1, Ny1 + ya - 1, colour)
		end
	end
end

pxl.box = function(x0, y0, x1, y1, colour, fill, width)
	width = width or 1
	if x1 < x0 then local xt = x1 x1 = x0 x0 = xt end
	if y1 < y0 then local yt = y1 y1 = y0 y0 = yt end
	if not fill then
		local sub = 0
		if width % 2 == 0 then 
			sub = 1 
			if x0 ~= x1 and y0 ~= y1 then
				pxl.dot(x0 - (width / 2), y0 - (width / 2), colour)
			end
		end
		if x0 ~= x1 then
			pxl.line(x0 - (math.floor(width / 2) - sub), y0, x1 + (math.floor(width / 2) - sub), y0, colour, width)
			pxl.line(x1 + (math.floor(width / 2) - sub), y1, x0 - (math.floor(width / 2) - sub), y1, colour, width)
		end
		if y0 ~= y1 then
			pxl.line(x1, y1 + (math.floor(width / 2) - sub), x1, y0 - (math.floor(width / 2) - sub), colour, width)
			pxl.line(x0, y0 - (math.floor(width / 2) - sub), x0, y1 + (math.floor(width / 2) - sub), colour, width)
		end
	end
	if fill then
		for x = x0, x1 do
			for y = y0, y1 do
				pxl.dot(x, y, colour)
			end
		end
	end
end

local function expandFill(x, y, oldColour, newColour)
	if grid[x] then
		if grid[x][y - 1] then
			if grid[x][y - 1] == oldColour then
				grid[x][y - 1] = newColour
				expandFill(x, y - 1, oldColour, newColour)
			end
		end
	end
	if grid[x + 1] then
		if grid[x + 1][y] then
			if grid[x + 1][y] == oldColour then
				grid[x + 1][y] = newColour
				expandFill(x + 1, y, oldColour, newColour)
			end
		end
	end
	if grid[x] then
		if grid[x][y + 1] then
			if grid[x][y + 1] == oldColour then
				grid[x][y + 1] = newColour
				expandFill(x, y + 1, oldColour, newColour)
			end
		end
	end
	if grid[x - 1] then
		if grid[x - 1][y] then
			if grid[x - 1][y] == oldColour then
				grid[x - 1][y] = newColour
				expandFill(x - 1, y, oldColour, newColour)
			end
		end
	end
end

pxl.fill = function(x, y, colour)
	if depth == 1 then
        if colour ~= 0 and colour ~= 1 then
            error("Invalid colour")
        end
	else
		local valid = false
		if size == 3 and colour == 0 then valid = true end
        for i, v in pairs(colours) do
            if v == colour then
                valid = true
            end
        end
        if not valid then
            error("Invalid colour")
        end
	end
	if grid[x] then
		if grid[x][y] then
			local oldc = grid[x][y]
			grid[x][y] = colour
			if oldc ~= colour then
				expandFill(x, y, oldc, colour)
			end
		end
	end
end

local polyline = function(x0, y0, x1, y1, width)
	width = width or 1
	local ret = {}
	local line = function(x0, y0, x1, y1, colour)
		local dx = math.abs(x1 - x0)
		local sx = x0 < x1 and 1 or -1
		local dy = -math.abs(y1 - y0)
		local sy = y0 < y1 and 1 or -1
		local err = dx + dy
		while true do
			if not ret[y0] then ret[y0] = {} end
			ret[y0][x0] = true
			if x0 == x1 and y0 == y1 then break end
			local e2 = 2 * err
			if e2 >= dy then
				err = err + dy
				x0 = x0 + sx
			end
			if e2 <= dx then
				err = err + dx
				y0 = y0 + sy
			end
		end
	end
	if math.abs(x1 - x0) >  math.abs(x1 - x0) then
		local Nx0 = x0 - math.floor(width / 2)
		for xa = 1, width do
			line(Nx0 + xa - 1, y0, x1 + xa - 1, y1, colour)
		end
	else
		local Ny0 = y0 - math.floor(width / 2)
		for ya = 1, width do
			line(x0, Ny0 + ya - 1, x1, y1 + ya - 1, colour)
		end
	end
	table.remove(ret, 1)
	table.remove(ret)
	return ret
end

pxl.poly = function(verts, colour, fill, width)
	if fill then
		local lins = {}
		local minX = verts[1][1]
		local maxX = verts[1][1]
		local minY = verts[1][2]
		local maxY = verts[1][2]
		for i, v in pairs(verts) do
			table.insert(lins, polyline(v[1], v[2], verts[i % #verts + 1][1], verts[i % #verts + 1][2]))
			if v[1] < minX then minX = v[1] end
			if v[1] > maxX then maxX = v[1] end
			if v[2] < minY then minY = v[2] end
			if v[2] > maxY then maxY = v[2] end
		end
		for y = minY, maxY do
			local flip = {}
			for i, v in pairs(lins) do
				if v[y] then
					if (v[y - 1] or lins[(i - 2) % #verts + 1][y - 1] or lins[(i) % #verts + 1][y - 1]) and (v[y + 1] or lins[(i - 2) % #verts + 1][y + 1] or lins[(i) % #verts + 1][y + 1]) then
						local maxP = 0
						for p, _ in pairs(v[y]) do
							if p > maxP then maxP = p end
						end
						flip[maxP] = not flip[maxP]
					end
				end
			end
			local parity =  false
			for x = minX, maxX do
				if flip[x] then
					parity = not parity
				end
				if parity then
					pxl.dot(x, y, colour)
				end
			end
		end
	end
	for i, v in pairs(verts) do
		if i == #verts then
			pxl.line(v[1], v[2], verts[1][1], verts[1][2], colour, width)
		else
			pxl.line(v[1], v[2], verts[i+1][1], verts[i+1][2], colour, width)
		end
	end
end

pxl.circle = function(xC, yC, r, colour, fill)
	for y = math.floor(yC - r), math.ceil(yC + r) do
		for x = math.floor(xC - r), math.ceil(xC + r) do
			local dist = math.sqrt(math.pow(math.abs(xC - x), 2) + math.pow(math.abs(yC - y), 2))
			if dist <= r + 0.5 then
				if dist >= r - 0.5 or fill then
					pxl.dot(x, y, colour)
				end
			end
		end
	end
end

pxl.ellipse = function(xC, yC, r, xm, colour, fill)
	for y = math.floor(yC - r), math.ceil(yC + r) do
		for x = math.floor(xC - (r * xm)), math.ceil(xC + (r * xm)) do
			local dist = math.sqrt(math.pow(math.abs((xC - x) / xm), 2) + math.pow(math.abs(yC - y), 2))
			if dist <= r + 0.5 then
				if dist >= r - 0.5 or fill then
					pxl.dot(x, y, colour)
				end
			end
		end
	end
end

pxl.loadImageFromFile = function(file, type, x, y)
	local fh = fs.open(file, "r")
	local text = fh.readAll()
	fh.close()
	pxl.loadImage(text, type, x, y)
end

local function getBits(char, start, len, bin)
    local num = string.byte(char) or 0
    num = num % math.pow(2, 9 - start)
    num = math.floor(num / math.pow(2, 9 - (start + len)))
	if bin then
		local bits = {}
		local po2 = 128
		for i = 1, 8 do
			if num >= po2 then table.insert(bits, true) num = num - po2 else table.insert(bits, false) end
			po2 = po2 / 2
		end
		return bits
	else
    	return num
	end
end

pxl.loadImage = function(text, type, x, y, bgcol)
	if depth == 1 then error("Loading of images is not supported in monochrome mode!") end
	if type == "NFP" then
		local dx = x
		local dy = y
		for i = 1, #text do
			local v = text:sub(i, i)
			if BlitToNum[v] then
				pxl.dot(dx, dy, BlitToNum[v])
				dx = dx + 1
			elseif v == "\n" then
				dx = x
				dy = dy + 1
			elseif v == " " then
				dx = dx + 1
			else
				error("Invalid NFP image!")
			end
		end
	elseif type == "NFPtall" then
		local dx = x
		local dy = y
		for i = 1, #text do
			local v = text:sub(i, i)
			if BlitToNum[v] then
				pxl.dot(dx, dy, BlitToNum[v])
				pxl.dot(dx + 1, dy, BlitToNum[v])
				pxl.dot(dx, dy + 1, BlitToNum[v])
				pxl.dot(dx + 1, dy + 1, BlitToNum[v])
				pxl.dot(dx, dy + 2, BlitToNum[v])
				pxl.dot(dx + 1, dy + 2, BlitToNum[v])
				dx = dx + 2
			elseif v == "\n" then
				dx = x
				dy = dy + 3
			elseif v == " " then
				dx = dx + 2
			else
				error("Invalid NFP image!")
			end
		end
	elseif type == "PHIMG" then
		local Sx, Sy = string.byte(text:sub(1, 1)), string.byte(text:sub(2, 2))
		local pos = 3
		local cols = {}
		while pos <= #text do
			local trans = getBits(text:sub(pos, pos), 1, 8, true)
			pos = pos + 1
			local byte = 0
			for i, v in pairs(trans) do
				if v then
					table.insert(cols, bgcol or 0)
				elseif pos % 1 == 0 then
					byte = text:sub(pos, pos) or "\0"
					table.insert(cols, NybToNum[getBits(byte, 1, 4)])
					pos = pos + 0.5
				else
					table.insert(cols, NybToNum[getBits(byte, 5, 4)])
					pos = pos + 0.5
				end
			end
			pos = math.ceil(pos)
		end
		for py = 1, Sy do
			for px = 1, Sx do
				if grid[x + px - 1] then
					if grid[x + px - 1][y + py - 1] then
						if cols[((py - 1) * Sx) + px] == nil then error(px.." "..py.." "..#cols) end
						pxl.dot(x + px - 1, y + py - 1, cols[((py - 1) * Sx) + px])
					end
				end
			end
		end
	else
		error("Unsupported format!")
	end
end

pxl.exportToPhimg = function(err)
	local cols = {}
	for y = 1, #grid[1] do
		for x = 1, #grid do
			table.insert(cols, grid[x][y])
		end
	end
	local out = string.char(#grid)..string.char(#grid[1])
	for i = 1, #cols, 8 do
		local add = ""
		local mr = false
		local trans = 0
		local po2 = 128
		for p = 1, 8 do
			if not NumToNyb[cols[i + p - 1]] then
				trans = trans + po2
			elseif not mr then
				add = add..string.char(NumToNyb[cols[i + p - 1]] * 16)
				mr = true
			else
				add = add:sub(1, -2)..string.char(NumToNyb[cols[i + p - 1]] + string.byte(add:sub(-1, -1)))
				mr = false
			end
			po2 = po2 / 2
		end
		add = string.char(trans)..add
		out = out..add
	end
	return out
end

return pxl