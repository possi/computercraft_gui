dofile("/disk/gui.lua")

gui.debug = false

local s = gui.screen()
s:setBackgroundColor(colors.white)

local b = s:add(gui.button("X"))
b:setTextColor(colors.black)
b:setBackgroundColor(colors.red)
b:setPosition(-1, 1)
b:onClick(function(button, frame, event, x, y)
    frame:getScreen():stop()
end)

    local f = s:frame() -- includes add
    f:setPositions(3, 3, -3, -3)
    f:setTextColor(colors.black)
    f:setBackgroundColor(colors.green)

    local t = gui.text("Error commodi. Aspernatur quasi. Numquam ea numquam qui vel\n"..
                        "voluptatem ipsa ullam omnis voluptatem doloremque quia ea. "..
                        "Qui qui illum qui commodi esse. Tempora voluptate dolorem. "..
                        "Autem quisquam porro ipsa sit nihil enim veritatis architecto. "..
                        "Et vel sed omnis odit qui et laudantium qui natus perspiciatis consequuntur et "..
                        "magni aspernatur sunt fugiat accusantium eaque ullam rem incididunt ipsa velit "..
                        "enim iste tempora nihil pariatur. Aut. Aliquid error. Eos. Quia dicta. Quis qui. "..
                        "Exercitationem neque ipsa Ut ipsam minima ut autem omnis dolores eum eius dolorem. "..
                        "Commodi ex quia qui inventore quasi nostrum qui. Eos qui do "..
                        "esse nulla qui dolorem veniam perspiciatis voluptatem veritatis "..
                        "quae numquam esse veniam eaque veniam ea velit. "..
                        "abcdefghijklmnopqrstuvwxyABCDEFGHIJKLMNOPQRSTUVWXYZ");
    f:add(t)
    
    local menu = f:frame()
    menu:setPosition(-8, 11)
    menu:setSize(8, 10)
    menu.hide = true
    menu:setTextColor(colors.black)
    menu:setBackgroundColor(colors.lime)
    menu:add(gui.text("Test"))

    local m = f:add(gui.button("Menue"))
    m:setTextColor(colors.black)
    m:setBackgroundColor(colors.gray)
    m:setPosition(-1, -1, "right")
    m:onClick(function(button, frame, event, x, y)
        menu.hide = not menu.hide
        frame:getScreen():draw()
    end)

s:draw()
s:wait()
s:reset()