dofile("/disk/gui.lua")

-- Static Text-Display

local file = io.open("/disk/examples/sample2.txt", "r")
print(file)
local s = gui.screen()
s:add(gui.text(file:read("*a"))):setTextColor(colors.white)
file:close()

s:draw()
--s:wait();