local ShoToNum = {
  whi = 1,
  ora = 2,
  mag = 4,
  lbl = 8,
  yel = 16,
  lim = 32,
  pin = 64,
  gry = 128,
  lgr = 256,
  cya = 512, 
  pur = 1024,
  blu = 2048,
  bro = 4096,
  gre = 8192,
  red = 16384,
  bla = 32768,
}

local function split (inputstr, sep)
	if sep == nil then
			sep = "\n"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			table.insert(t, str)
	end
	return t
end

local function render(X, Y, bgc, Icon)
	local ok = pcall(function()
		Icon = split(Icon, "\n")
		local line = 2
		for y = 1, tonumber(Icon[2]) do
			term.setCursorPos(X, Y + y - 1)
			for x = 1, tonumber(Icon[1]) do
				line = line + 1
				local col0 = ShoToNum[Icon[line]:sub(1, 3)]
				if col0 == nil then col0 = bgc end
				local col1 = ShoToNum[Icon[line]:sub(5, 7)]
				if col1 == nil then col1 = bgc end
				local charr = 1
				if #Icon[line] == 14 then
					local text = {Icon[line]:sub(9, 9), Icon[line]:sub(10, 10), Icon[line]:sub(11, 11), Icon[line]:sub(12, 12), Icon[line]:sub(13, 13)}
					if Icon[line]:sub(14, 14) == "1" then
						local col = col0
						col0 = col1
						col1 = col
						for i,v in pairs(text) do
							if v == "1" then text[i] = "0" end
							if v == "0" then text[i] = "1" end
						end
					end
					charr = 128
					local toadd = 1
					for i,v in pairs(text) do
						if v == "1" then charr = charr + toadd end
						toadd = toadd * 2
					end
				elseif #Icon[line] == 9 then
					charr = string.byte(Icon[line]:sub(9, 9))
				elseif #Icon[line] == 3 then
					charr = 32
				end
				if col0 == nil then col0 = bgc end
				term.setBackgroundColour(col0)
				term.setTextColour(col1)
				term.write(string.char(charr))
			end
		end
	end)
	if not ok then
		if bgc == colours.white then
			term.setBackgroundColour(colours.black)
		else
			term.setBackgroundColour(colours.white)
		end
		term.setTextColour(colours.red)
		term.setCursorPos(X, Y)
		term.write("   ")
		term.setCursorPos(X, Y + 1)
		term.write(" ! ")
		term.setCursorPos(X, Y + 2)
		term.write("   ")
	end
end

local function renderFile(X, Y, bgc, File)
	local file = fs.open(File, "r")
	render(X, Y, bgc, file.readAll())
	file.close()
end

return {render = render, renderFile = renderFile}