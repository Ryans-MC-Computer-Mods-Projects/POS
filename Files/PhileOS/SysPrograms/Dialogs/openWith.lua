term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
term.setTextColor(PhileOS.getSetting("theme", "selTitleBarColour"))
term.clear()
local Sx, Sy = term.getSize()
term.setCursorPos(1, 1)
term.write("\151"..("\131"):rep(Sx - 2))
term.setBackgroundColor(PhileOS.getSetting("theme", "selTitleBarColour"))
term.setTextColor(PhileOS.getSetting("theme", "defBackgroundColour"))
term.write("\148")

term.setCursorPos(1, 2)
term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
term.setTextColor(PhileOS.getSetting("theme", "selTitleBarColour"))
term.write("\149")
term.setTextColor(PhileOS.getSetting("theme", "defTextColour"))
term.write("Open this file with:")
term.setBackgroundColor(PhileOS.getSetting("theme", "selTitleBarColour"))
term.setTextColor(PhileOS.getSetting("theme", "defBackgroundColour"))
term.setCursorPos(Sx, 2)
term.write("\149")

term.setCursorPos(1, 3)
term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
term.setTextColor(PhileOS.getSetting("theme", "selTitleBarColour"))
term.write("\157"..("\140"):rep(Sx - 2))
term.setBackgroundColor(PhileOS.getSetting("theme", "selTitleBarColour"))
term.setTextColor(PhileOS.getSetting("theme", "defBackgroundColour"))
term.write("\145")

local options = {...}
for i, v in pairs(options) do
    term.setCursorPos(1, i + 3)
    term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.setTextColor(PhileOS.getSetting("theme", "selTitleBarColour"))
    term.write("\149")
    term.setTextColor(PhileOS.getSetting("theme", "defTextColour"))
    term.write(fs.getName(v))
    term.setBackgroundColor(PhileOS.getSetting("theme", "selTitleBarColour"))
    term.setTextColor(PhileOS.getSetting("theme", "defBackgroundColour"))
    term.setCursorPos(Sx, i + 3)
    term.write("\149")
end
term.setCursorPos(1, Sy)
term.write("\138"..("\143"):rep(Sx - 2).."\133")
local e = table.pack(os.pullEvent())
while true do
    if e[1] == "mouse_click" then
        if e[4] > 3 and e[4] ~= Sy and e[3] ~= 1 and e[3] ~= Sx then
            if options[e[4] - 3] ~= "" then PhileOS.setStatus(PhileOS.ID, options[e[4] - 3]) end
        end
    end
    e = table.pack(os.pullEvent())
end