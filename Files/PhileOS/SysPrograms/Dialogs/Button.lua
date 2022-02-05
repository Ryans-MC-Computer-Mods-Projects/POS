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
	Button1 = {
		t = "textButton",
		pos = {x = 0.1, Ox = 0, y = 0.6, Oy = 0},
		size = {x = 0.35, Ox = 0, y = 0.1, Oy = 0},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defSelTextColour"),
		text = options[2],
		Ay = "M",
		Ax = "M",
		fun = function()
			PhileOS.setStatus(PhileOS.ID, options[2])
		end,
	},
	Button2 = {
		t = "textButton",
		pos = {x = 0.55, Ox = 0, y = 0.6, Oy = 0},
		size = {x = 0.35, Ox = 0, y = 0.1, Oy = 0},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defSelTextColour"),
		text = options[3],
		Ay = "M",
		Ax = "M",
		fun = function()
			PhileOS.setStatus(PhileOS.ID, options[3])
		end,
	},
	Button3 = {
		t = "textButton",
		pos = {x = 0.1, Ox = 0, y = 0.8, Oy = 0},
		size = {x = 0.35, Ox = 0, y = 0.1, Oy = 0},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defSelTextColour"),
		text = options[4],
		Ay = "M",
		Ax = "M",
		fun = function()
			PhileOS.setStatus(PhileOS.ID, options[4])
		end,
	},
	Button4 = {
		t = "textButton",
		pos = {x = 0.55, Ox = 0, y = 0.8, Oy = 0},
		size = {x = 0.35, Ox = 0, y = 0.1, Oy = 0},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defSelTextColour"),
		text = options[5],
		Ay = "M",
		Ax = "M",
		fun = function()
			PhileOS.setStatus(PhileOS.ID, options[5])
		end,
	},
})
if options[2] == "" then UI.UI.Button1 = nil end
if options[3] == "" then UI.UI.Button2 = nil end
if options[4] == "" then UI.UI.Button3 = nil end
if options[5] == "" then UI.UI.Button4 = nil end

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
