local UIAPI = require("PhiUI")
local options = {...}
local UI = UIAPI.makeUI({
    BGC = PhileOS.getSetting("theme", "defBackgroundColour"),
    Prompt = {
		t = "textBox",
		pos = {x = 0.1, Ox = 0, y = 0.1, Oy = 0},
		size = {x = 0.8, Ox = 0, y = 0.4, Oy = 0},
		col = PhileOS.getSetting("theme", "defBackgroundColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = options[1],
		Ay = "M",
		Ax = "M",
	},
	Answer = {
		t = "textField",
		pos = {x = 0.1, Ox = 0, y = 0.6, Oy = 0},
		size = {x = 0.8, Ox = 0, y = 0.3, Oy = 0},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defSelTextColour"),
		text = options[2],
		Ay = "T",
		Ax = "L",
		replaceChar = options[3],
		fun = function(text)
			PhileOS.setStatus(PhileOS.ID, text)
		end,
	},
})

PhileOS.setCanResize(PhileOS.ID, false)
PhileOS.setSize(PhileOS.ID, 30, 10)
local Sx, Sy = term.getSize()
while true do
	local Cx, Cy = UI.draw(1, 1, Sx, Sy)
	term.setCursorPos(Cx, Cy)
	term.setCursorBlink(true)
	local e = table.pack(os.pullEvent())
	UI.update(1, 1, Sx, Sy, e)
	if e[1] == "term_resize" then Sx, Sy = term.getSize() end
end

