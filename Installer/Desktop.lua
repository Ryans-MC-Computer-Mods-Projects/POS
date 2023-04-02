local Sx, Sy = term.getSize()
while true do
    local bgc = 512
    local txc = 1
    term.setBackgroundColour(bgc)
    term.clear()
    
    term.setBackgroundColour(bgc)
    term.setTextColour(txc)
    term.setCursorPos(Sx - 25, Sy - 1)
    term.write("PhileOS 0.1.0 | Build 0002")
    term.setCursorPos(Sx - 25, Sy)
    term.write("THIS IS A WORK IN PROGRESS")

    local e = table.pack(os.pullEvent())
    Sx, Sy = term.getSize()
end