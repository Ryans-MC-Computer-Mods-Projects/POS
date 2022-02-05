term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
term.setTextColor(PhileOS.getSetting("theme", "selTitleBarColour"))
term.clear()
local Sx, Sy = term.getSize()
term.setCursorPos(1, 1)
term.write("\151"..("\131"):rep(Sx - 2))
term.setBackgroundColor(PhileOS.getSetting("theme", "selTitleBarColour"))
term.setTextColor(PhileOS.getSetting("theme", "defBackgroundColour"))
term.write("\148")

local options = {...}
local onwerID = options[1]
table.remove(options, 1)
for i, v in pairs(options) do
    term.setCursorPos(1, i + 1)
    if v == "" then
        term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
        term.setTextColor(PhileOS.getSetting("theme", "selTitleBarColour"))
        term.write("\157"..("\140"):rep(Sx - 2))
        term.setBackgroundColor(PhileOS.getSetting("theme", "selTitleBarColour"))
        term.setTextColor(PhileOS.getSetting("theme", "defBackgroundColour"))
        term.write("\145")
    else
        term.setBackgroundColor(PhileOS.getSetting("theme", "defBackgroundColour"))
        term.setTextColor(PhileOS.getSetting("theme", "selTitleBarColour"))
        term.write("\149")
        term.setTextColor(PhileOS.getSetting("theme", "defTextColour"))
        term.write(v)
        term.setBackgroundColor(PhileOS.getSetting("theme", "selTitleBarColour"))
        term.setTextColor(PhileOS.getSetting("theme", "defBackgroundColour"))
        term.setCursorPos(Sx, i + 1)
        term.write("\149")
    end
end
term.setCursorPos(1, Sy)
term.write("\138"..("\143"):rep(Sx - 2).."\133")
local e = table.pack(os.pullEvent())
while true do
    if e[1] == "mouse_click" then
        if e[4] ~= 1 and e[4] ~= Sy and e[3] ~= 1 and e[3] ~= Sx then
            if options[e[4] - 1] ~= "" then PhileOS.setStatus(PhileOS.ID, options[e[4] - 1]) end
        end
    end
    e = table.pack(os.pullEvent())
    local success, processIDs = PhileOS.getProcesses(PhileOS.ID)
    local onwerStillExists = false
    for i, v in pairs(processIDs) do
        if v == onwerID then onwerStillExists = true end
    end
    if not onwerStillExists then return end
end