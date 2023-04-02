local filesToUpdate = {
    "/PhileOS/APIs/PhiUI.lua",
    "/PhileOS/APIs/Phicon.lua",
    "/PhileOS/APIs/PhileUtils.lua",
    "/PhileOS/APIs/pxl.lua",
    "/PhileOS/APIs/sha256.lua",
    "/PhileOS/Changelog.txt",
    "/PhileOS/Icons/Colours.txt",
    "/PhileOS/Icons/Default.phico",
    "/PhileOS/Icons/Extentions/Folder.phico",
    "/PhileOS/Icons/Extentions/txt.phico",
    "/PhileOS/Icons/Logo.phimg",
    "/PhileOS/Icons/POS.phico",
    "/PhileOS/Icons/Programs/PhileOS/Programs/Calculator.lua.phico",
    "/PhileOS/Icons/Programs/PhileOS/Programs/Notepad.lua.phico",
    "/PhileOS/Icons/Programs/PhileOS/Programs/Paint.lua.phimg",
    "/PhileOS/Icons/Programs/PhileOS/Programs/Settings.lua.phimg",
    "/PhileOS/Icons/Programs/PhileOS/Programs/Trash.lua.phico",
    "/PhileOS/Icons/Programs/PhileOS/explorer.lua.phico",
    "/PhileOS/Icons/Programs/rom/programs/lua.lua.phico",
    "/PhileOS/Icons/Programs/rom/programs/shell.lua.phico",
    "/PhileOS/Programs/Calculator.lua",
    "/PhileOS/Programs/Notepad.lua",
    "/PhileOS/Programs/Paint.lua",
    "/PhileOS/Programs/Settings.lua",
    "/PhileOS/Programs/Trash.lua",
    "/PhileOS/RTKrnl.lua",
    "/PhileOS/Settings/Themes/Default.theme",
    "/PhileOS/Settings/desktop.set",
    "/PhileOS/Settings/main.set",
    "/PhileOS/Settings/openWith.set",
    "/PhileOS/Settings/start.set",
    "/PhileOS/SysPrograms/Desktop.lua",
    "/PhileOS/SysPrograms/Dialogs/Button.lua",
    "/PhileOS/SysPrograms/Dialogs/TextInput.lua",
    "/PhileOS/SysPrograms/Dialogs/openWith.lua",
    "/PhileOS/SysPrograms/Dialogs/rClick.lua",
    "/PhileOS/SysPrograms/System.lua",
    "/PhileOS/SysPrograms/Taskbar.lua",
    "/PhileOS/SysPrograms/Time.lua",
    "/PhileOS/explorer.lua",
    "/startup.lua",
}

print("Updating to Phile OS 0.1.0 Build 0002!")
print("Downloading files...")
for i, v in pairs(filesToUpdate) do
    local mode = "w"
    if v:sub(-6) == ".phimg" then mode = "wb" end
    local file = http.get("https://raw.githubusercontent.com/Ryans-MC-Computer-Mods-Projects/POS/main/Files/"..v, nil, mode == "wb")
    local fh = fs.open(v, mode)
    fh.write(file.readAll())
    fh.close()
    print(v)
end
print("")
print("Configuring Update...")
local pwf = fs.open("/PhileOS/.pass.set", "r")
passwords = pwf.readAll()
pwf.close()
passwords = textutils.unserialise(passwords)

for i, v in pairs(passwords) do
    v.type = "Admin"
end

local pwf = fs.open("/PhileOS/.pass.set", "w")
pwf.write(textutils.serialise(passwords))
pwf.close()

print("Update Finished! Rebooting in 3 seconds...")
os.sleep(3)
os.reboot()