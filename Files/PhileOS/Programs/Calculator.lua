local a = "0"
local b = "0"
local oldb = "0"
local op = "plus"
local UI = {}

local UIAPI = require("PhiUI")
UI = UIAPI.makeUI({
    BGC = PhileOS.getSetting("theme", "defBackgroundColour"),
    Display = {
        t = "textBox",
		pos = {x = 0, Ox = 1, y = 0, Oy = 1},
		size = {x = 0, Ox = 16, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "0",
		Ay = "T",
		Ax = "R",
    },

    ButtonADV = {
        t = "textButton",
		pos = {x = 0, Ox = 1, y = 0, Oy = 3},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "ADV",
		Ay = "M",
		Ax = "M",
        fun = function()
			PhileOS.openDialog(PhileOS.ID, "button", {"Not created yet!", "Ok!", "", "", ""})
		end,
    },
    ButtonC = {
        t = "textButton",
		pos = {x = 0, Ox = 5, y = 0, Oy = 3},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "C",
		Ay = "M",
		Ax = "M",
        fun = function()
			a = "0"
            b = "0"
            op = "plus"
		end,
    },
    ButtonBack = {
        t = "textButton",
		pos = {x = 0, Ox = 9, y = 0, Oy = 3},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "<\215]",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b:sub(1, #b - 1)
		end,
    },
    ButtonDiv = {
        t = "textButton",
		pos = {x = 0, Ox = 14, y = 0, Oy = 3},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "\247",
		Ay = "M",
		Ax = "M",
        fun = function()
			local opa = tonumber(a)
			local opb = tonumber(b)
			local out = 0
			if op == "plus" then out = opa + opb end
			if op == "minus" then out = opa - opb end
			if op == "times" then out = opa * opb end
			if op == "over" then out = opa / opb end
			op = "over"
			a = tostring(out)
			b = "0"
			oldb = "0"
			UI.UI.Display.text = a
		end,
    },

    Button7 = {
        t = "textButton",
		pos = {x = 0, Ox = 1, y = 0, Oy = 5},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "7",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b.."7"
		end,
    },
    Button8 = {
        t = "textButton",
		pos = {x = 0, Ox = 5, y = 0, Oy = 5},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "8",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b.."8"
		end,
    },
    Button9 = {
        t = "textButton",
		pos = {x = 0, Ox = 9, y = 0, Oy = 5},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "9",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b.."9"
		end,
    },
    ButtonMul = {
        t = "textButton",
		pos = {x = 0, Ox = 14, y = 0, Oy = 5},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "\215",
		Ay = "M",
		Ax = "M",
        fun = function()
			local opa = tonumber(a)
			local opb = tonumber(b)
			local out = 0
			if op == "plus" then out = opa + opb end
			if op == "minus" then out = opa - opb end
			if op == "times" then out = opa * opb end
			if op == "over" then out = opa / opb end
			op = "times"
			a = tostring(out)
			b = "0"
			oldb = "0"
			UI.UI.Display.text = a
		end,
    },

    Button4 = {
        t = "textButton",
		pos = {x = 0, Ox = 1, y = 0, Oy = 7},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "4",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b.."4"
		end,
    },
    Button5 = {
        t = "textButton",
		pos = {x = 0, Ox = 5, y = 0, Oy = 7},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "5",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b.."5"
		end,
    },
    Button6 = {
        t = "textButton",
		pos = {x = 0, Ox = 9, y = 0, Oy = 7},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "6",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b.."6"
		end,
    },
    ButtonSub = {
        t = "textButton",
		pos = {x = 0, Ox = 14, y = 0, Oy = 7},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "-",
		Ay = "M",
		Ax = "M",
        fun = function()
			local opa = tonumber(a)
			local opb = tonumber(b)
			local out = 0
			if op == "plus" then out = opa + opb end
			if op == "minus" then out = opa - opb end
			if op == "times" then out = opa * opb end
			if op == "over" then out = opa / opb end
			op = "minus"
			a = tostring(out)
			b = "0"
			oldb = "0"
			UI.UI.Display.text = a
		end,
    },

    Button1 = {
        t = "textButton",
		pos = {x = 0, Ox = 1, y = 0, Oy = 9},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "1",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b.."1"
		end,
    },
    Button2 = {
        t = "textButton",
		pos = {x = 0, Ox = 5, y = 0, Oy = 9},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "2",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b.."2"
		end,
    },
    Button3 = {
        t = "textButton",
		pos = {x = 0, Ox = 9, y = 0, Oy = 9},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "3",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b.."3"
		end,
    },
    ButtonAdd = {
        t = "textButton",
		pos = {x = 0, Ox = 14, y = 0, Oy = 9},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "+",
		Ay = "M",
		Ax = "M",
        fun = function()
			local opa = tonumber(a)
			local opb = tonumber(b)
			local out = 0
			if op == "plus" then out = opa + opb end
			if op == "minus" then out = opa - opb end
			if op == "times" then out = opa * opb end
			if op == "over" then out = opa / opb end
			op = "plus"
			a = tostring(out)
			b = "0"
			oldb = "0"
			UI.UI.Display.text = a
		end,
    },

    ButtonDot = {
        t = "textButton",
		pos = {x = 0, Ox = 1, y = 0, Oy = 11},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = ".",
		Ay = "M",
		Ax = "M",
        fun = function()
            if not string.find(b, "%.") then
			    b = b.."."
            end
		end,
    },
    Button0 = {
        t = "textButton",
		pos = {x = 0, Ox = 5, y = 0, Oy = 11},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "0",
		Ay = "M",
		Ax = "M",
        fun = function()
			b = b.."0"
		end,
    },
    ButtonPM = {
        t = "textButton",
		pos = {x = 0, Ox = 9, y = 0, Oy = 11},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "+/-",
		Ay = "M",
		Ax = "M",
        fun = function()
			if b:sub(1, 1) == "-" then b = b:sub(2) else b = "-"..b end
		end,
    },
    ButtonEquals = {
        t = "textButton",
		pos = {x = 0, Ox = 14, y = 0, Oy = 11},
		size = {x = 0, Ox = 3, y = 0, Oy = 1},
		col = PhileOS.getSetting("theme", "defSelBGColour"),
		textCol = PhileOS.getSetting("theme", "defTextColour"),
		text = "=",
		Ay = "M",
		Ax = "M",
        fun = function()
			local opa = tonumber(a)
			local opb = tonumber(b)
			local out = 0
			if op == "plus" then out = opa + opb end
			if op == "minus" then out = opa - opb end
			if op == "times" then out = opa * opb end
			if op == "over" then out = opa / opb end
			b = tostring(out)
			UI.UI.Display.text = b
            a = "0"
            op = "plus"
		end,
    },
})

PhileOS.setCanResize(PhileOS.ID, false)
PhileOS.setSize(PhileOS.ID, 18, 13)
local Sx, Sy = term.getSize()
while true do
	local Cx, Cy = UI.draw(1, 1, Sx, Sy)
	term.setCursorPos(Cx, Cy)
	term.setCursorBlink(true)
	local e = table.pack(os.pullEvent())
	UI.update(1, 1, Sx, Sy, e)
    if e[1] == "char" then
        if tonumber(e[2]) then
            b = b..e[2]
        elseif e[2] == "." then
            if not string.find(b, "%.") then
			    b = b.."."
            end
		elseif e[2] == "=" then
			UI.UI.ButtonEquals.fun()
		elseif e[2] == "+" then
			UI.UI.ButtonAdd.fun()
		elseif e[2] == "-" then
			UI.UI.ButtonSub.fun()
		elseif e[2] == "*" then
			UI.UI.ButtonMul.fun()
		elseif e[2] == "/" then
			UI.UI.ButtonDiv.fun()
		elseif string.lower(e[2]) == "c" then
			UI.UI.ButtonC.fun()
        end
    elseif e[1] == "key" then
        if e[2] == keys.backspace then
            b = b:sub(1, #b - 1)
		elseif e[2] == keys.enter then
			UI.UI.ButtonEquals.fun()
        end
    end
    if b ~= oldb then
        if b:sub(1, 1) == "0" and not (b:sub(1, 2) == "0.") then b = b:sub(2) end
        if #b == 0 then b = "0" end
		if b == "-" then b = "0" end
        local todisp = b
        if #b >= 16 then todisp = b:sub(#b - 15) end
        UI.UI.Display.text = tostring(todisp)
        oldb = b
    end
	if e[1] == "term_resize" then Sx, Sy = term.getSize() end
end