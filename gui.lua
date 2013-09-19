--------------------------------------------------------------------------------
-- Computer Craft GUI API by jpossi   (jascha@ja-s.de)                        --
--  https://github.com/possi/computercraft_gui                                --
--                                                                            --
-- Copyright: GPL 2 http://www.gnu.de/documents/gpl-2.0.en.html               --
--------------------------------------------------------------------------------

local api = {
    debug = false
}

-- -------------------
--  Helper
-- -------------------

local function extend(class, obj)
    obj = obj or {}
    setmetatable(obj, { __index = class})
    return obj
end
local function create(class, ...)
    if class.new ~= nil then
        return class.new(...)
    else
        local obj = extend(class)
        if (obj._init ~= nil) then
            obj:_init(...)
        end
        return obj
    end
end

local function calculateNegativePos(x, y, w, h)
    if x < 0 then
        if w == nil then error("Can not calculate negative position without parent width") end
        x = w + x + 1
    end
    if y < 0 then
        if h == nil then error("Can not calculate negative position without parent height") end
        y = h + y + 1
    end
    return x, y
end

local function pdebug(...)
    if not api.debug then return end
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.yellow)
    print(...)
end
local pxdebug_y = 1
local function pxdebug(...)
    if not api.debug then return end
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.yellow)
    local x, y = term.getCursorPos()
    term.setCursorPos(1, pxdebug_y)
    print(...)
    local tmpx, tmpy = term.getCursorPos()
    pxdebug_y = tmpy;
    term.setCursorPos(x, y)
end

-- -------------------
--  GUI-Interfaces
-- -------------------

local widget = {hide = false, parent = nil}
function widget:setParent(parent)
    self.parent = parent
end
function widget:getParent()
    return self.parent
end

local colorAble = extend(widget)
function colorAble:_init()
    self.c = {bg = nil, fg = nil}
end
function colorAble:setTextColor(color)
    self.c.fg = color
end
function colorAble:setBackgroundColor(color)
    self.c.bg = color
end
function colorAble:applyColors()
    if self.c.bg ~= nil then
        term.setBackgroundColor(self.c.bg)
    end
    if self.c.fg ~= nil then
        term.setTextColor(self.c.fg)
    end
end


-- -------------------
--  GUI-Classes
-- -------------------

-- 
-- Frame
-- 

local frame = extend(colorAble)
function frame._init(self)
    colorAble._init(self)
    self.widgets = {}
    self.pos = {x = nil, y = nil}
    self.padding = {t = 0, r = 0, b = 0, l = 0}
    self.size = {w = nil, h = nil}
end
function frame:setPadding(t, r, b, l)
    self.padding = {
        t = t,
        r = r ~= nil and r or t,
        b = b ~= nil and b or t,
        l = l ~= nil and l or (r ~= nil and r or t),
    }
end
function frame:getPadding()
    return self.padding
end
function frame:getInnerSize()
    local w, h = self:getSize()
    return w - self.padding.l - self.padding.r, h - self.padding.t - self.padding.b
end
function frame:getParentSize()
    local pw, ph = nil, nil
    if self.parent ~= nil then
        pw, ph = self.parent:getSize()
    end
    return pw, ph
end
function frame:getPosition()
    return self.pos.x, self.pos.y
end
function frame:setPosition(x, y, align) -- absolute only
    --[[if (align ~= nil and align ~= "left" and self.parent == nil) then
        error("Can not position frame right/center without a parent")
    elseif (align ~= nil and align ~= "left" and (self.size.w == nil) then
        error("Can not position frame right/center without a parent")
    end]]--
    if align ~= nil then error("NYI") end
    local pw, ph = self:getParentSize()
    x, y = calculateNegativePos(x, y, pw, ph)
    self.pos = {x = x, y = y}
end
function frame:setPositions(x, y, x2, y2)
    local pw, ph = nil, nil
    if self.parent ~= nil then
        pw, ph = self.parent:getSize()
    end
    local pw, ph = self:getParentSize()
    x, y = calculateNegativePos(x, y, pw, ph)
    x2, y2 = calculateNegativePos(x2, y2, pw, ph)
    self.size = {w = x2 - x + 1, h = y2 - y + 1}
    self.pos = {x = x, y = y}
end
function frame:setSize(w, h)
    self.size.w = w
    self.size.h = h
end
function frame:getSize()
    return self.size.w, self.size.h
end
function frame:add(widget)
    table.insert(self.widgets, widget)
    if (type(widget) == "table" and widget.setParent ~= nil) then
        widget:setParent(self)
    end
    return widget
end
function frame:remove(widget)
    for i, v in ipairs(self.widgets) do
        if v == widget then
            table.remove(self.widgets, i)
            return widget
        end
    end
    return nil
end
function frame:draw(screen)
    pxdebug(term.getCursorPos())
    pxdebug(self:getCursorPosition())
    pdebug(self.c.bg)
    if self.c.bg ~= nil then
        for x = 1, self.size.w do
            for y = 1, self.size.h do
                local ax, ay = self:getAbsolutePosition(x, y)
                paintutils.drawPixel(ax, ay, self.c.bg)
            end
        end
    end
    self:applyColors()
    self:setCursorPosition(1 + self.padding.l, 1 + self.padding.t)
    pxdebug("frame painted: ", self)
    for i, widget in pairs(self.widgets) do
        if type(widget) == "function" then
            widget(self)
        elseif not widget.hide then
            if (widget.getPosition ~= nil and widget:getPosition() ~= nil) then
                term.setCursorPos(self:getAbsolutePosition(widget:getPosition()))
            end
            widget:draw(self)
        else
            pxdebug("hidden: ", widget)
        end
        self:applyColors()
    end
end
function frame:click(frame, event, x, y)
    pdebug("@", x, ", ", y)
    for i, widget in pairs(self.widgets) do
        if (type(widget) == "table" and widget.getPosition ~= nil) then
            local px, py = widget:getPosition()
            local w, h = widget:getSize()
            pdebug(px, ",", py, " + ", w, ",", h)
            if (x >= px and x < px + w and y >= py and y < py + h) then
                pdebug("click")
                widget:click(self, event, x - px + 1, y - py + 1)
            end
        end
    end
end
function frame:getScreen()
    return self.parent:getScreen()
end
function frame:getAbsolutePosition(x, y)
    local px, py = self.parent:getAbsolutePosition(self.pos.x, self.pos.y)
    return px + x - 1, py + y - 1
end
function frame:getRelativePosition(x, y)
    local px, py = self.parent:getAbsolutePosition(self.pos.x, self.pos.y)
    return x - px + 1, y - py + 1
end
function frame:getCursorPosition()
    return self:getRelativePosition(term.getCursorPos())
end
function frame:setCursorPosition(x, y)
    return term.setCursorPos(self:getAbsolutePosition(x, y))
end
function frame:frame()
    return self:add(create(frame))
end

-- 
-- Screen
-- Provides all methods, a Frame also provides (same interface) but has its own implementation, because a screen is alwas absolute
-- 

local screen = extend(colorAble, {
    setParent = nil,
    getParent = nil,
})
do
    -- Link Interface-Methods from Frame
    local fs = {
        "add",
        "click",
        "remove",
        "setPadding",
        "getPadding",
        "getInnerSize",
        "setCursorPosition",
        "getCursorPosition",
        "frame",
    }
    for i, f in pairs(fs) do
        screen[f] = frame[f]
    end
end
function screen._init(self)
    colorAble._init(self)
    self.widgets = {}
    self.cb = {draw = nil, adraw = nil}
    self.padding = {t = 0, r = 0, b = 0, l = 0}
end
function screen:getSize()
    return term.getSize()
end
function screen:draw()
    self:applyColors()
    pxdebug_y = 1
    term.clear()
    term.setCursorPos(1 + self.padding.l, 1 + self.padding.t)
    if self.cb.draw ~= nil then
        self.cb.draw(self)
    end
    for i, widget in ipairs(self.widgets) do
        if type(widget) == "function" then
            widget(self)
        elseif not widget.hide then
            if (widget.getPosition ~= nil and widget:getPosition() ~= nil) then
                term.setCursorPos(widget:getPosition())
            end
            widget:draw(self)
        end
        self:applyColors()
    end
    if self.cb.adraw ~= nil then
        self.cb.adraw(self)
    end
end
function screen:onDraw(callback)
    self.cb.draw = callback
end
function screen:afterDraw(callback)
    self.cb.adraw = callback
end
function screen:wait()
    self.wait = true
    repeat
        local event, a1, a2, a3 = os.pullEvent()
        if (event == "monitor_touch" or event == "mouse_click") then
            local x, y = a2, a3
            self:click(nil, event, x, y)
        end
    until not self.wait
end
function screen:stop()
    self.wait = false
end
function screen:getScreen()
    return self
end
function screen:getAbsolutePosition(x, y)
    return x, y
end
function screen:getRelativePosition(x, y)
    return x, y
end
function screen:reset()
    pxdebug_y = 1
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
end

-- 
-- Text-Label
-- 

local text = extend(colorAble)
function text._init(self, str)
    colorAble._init(self)
    self.text = str
end
function text:setText(str)
    self.text = str
end
function text:nl(x, y)
    x = 1
    y = y + 1
    self.size.h = self.size.h + 1
    if (self.parent) then
        --[[local pw, ph = self.parent:getSize();
        if (y > ph) then
            error("String execeeds parent size")
        end]]
        self.parent:setCursorPosition(x, y)
    end
    return x, y
end
function text:draw(screen)
    if self.parent == nil then
        error("Missing parent-Widget", 2)
    end
    local p = self.parent
    local x, y = p:getCursorPosition()
    
    --print(self.c.fg, " ")
    pxdebug(self.text:sub(1, 4), "#", self.c.bg)
    --d(self.c)
    self:applyColors()
    
    self.size = {w = 0, h = 1}
    self.pos = {x = x, y = y}
    
    local linelength, blockheight = p:getInnerSize()
    
    local offset = 1
    local i = string.find(self.text, "%s")
    while (offset <= string.len(self.text)) do
        if (i == nil) then
            i = string.len(self.text) + 1
        end
        local wordlength = i - offset
        if (wordlength == 0) then
            local char = string.sub(self.text, offset, offset)
            if (char == "\r") then
                -- ignore
            elseif (char == "\n") then
                x, y = self:nl(x, y)
            else
                if (x + 1 > linelength) then
                    x, y = self:nl(x, y)
                else
                    x = x + 1
                    self.size.w = math.max(self.size.w, x - 1)
                    term.write(char)
                end
            end
            offset = offset + 1
        else
            if (wordlength > linelength) then
                i = offset + (linelength - x) + 1
            elseif (x + wordlength - 1 > linelength) then
                x, y = self:nl(x, y)
            end
            term.write(string.sub(self.text, offset, i - 1))
            x = x + wordlength
            self.size.w = math.max(self.size.w, x - 1)
            offset = i
        end
        i = string.find(self.text, "%s", offset)
    end
    --pxdebug(string.sub(self.text, 1, 6), " ", self.size.w, " ", self.size.h)
end

-- 
-- Button
-- 

local button = extend(text)
function button._init(self, str)
    text._init(self, str)
    self.pos = {x = nil, y = nil}
    self.size = {w = nil, h = nil}
    self.cb = nil
    self.parent = nil
end
function button:setPosition(x, y, align) -- absolute only
    if (self.parent == nil) then
        error("A parent have to be set first", 2)
    end
    local pw, ph = self.parent:getSize()
    x, y = calculateNegativePos(x, y, pw, ph)
    if align == "right" then
        local w, h = self:getSize()
        x = x - w + 1
    end
    self.pos = {x = x, y = y}
end
function button:getPosition()
    return self.pos.x, self.pos.y -- computed by text.draw
end
function button:getSize()
    if self.size.w ~= nil and self.size.h ~= nil then
        return self.size.w, self.size.h -- computed by text.draw
    else
        return string.len(self.text), 1
    end
end
function button:onClick(callback)
    self.cb = callback
end
function button:click(frame, event, x, y)
    --[[if (self.parent ~= nil and self.c.fg ~= nil and self.c.bg ~= nil and self.pos.x ~= nil and self.pos.y ~= nil) then
        self.parent:setCursorPosition(self.pos.x, self.pos.y)
        local tmp = {self.c.fg, self.c.bg};
        self.c.fg = tmp.bg;
        self.c.bg = tmp.fg;
        self:draw()
        self.c = tmp;
        sleep(0.2)
    end]]
    if (self ~= nil) then
        self.cb(self, frame, event, x, y)
    end
end


-- 
-- Radio-Group
-- 

local radioGroup = extend(widget)
function radioGroup._init(self)
    self.entries = {}
    self.cb = {change = nil}
    self.value = nil
    --self.padding = 0
end
--[[function radioGroup:setPadding(c)
    self.padding = c
end]]
function radioGroup:onChange(callback)
    self.cb.change = callback
end
function radioGroup:addEntry(value, label)
    if (self.parent == nil) then
        error("A parent have to be set first", 2)
    end
    local this = self
    if label == nil then
        label = value
    end
    local b = create(button)
    b.value = value
    b.label = label
    b:onClick(function(button, frame, event, x, y)
        if (this.cb.change ~= nil) then
            this.cb.change(this, button, this.value, button.value, frame)
        end
        this.value = button.value
        frame:getScreen():draw()
    end)
    self.entries[value] = self.parent:add(b)
    self.parent:add(create(text, "\n"))
    return b
end
function radioGroup:draw(frame)
    for value, button in pairs(self.entries) do
        local pf = self.value == button.value and "(X) " or "( ) "
        button:setText(pf .. button.label)
    end
end


-- -------------------
--  Public-API
-- -------------------


function api.screen()
    return create(screen)
end
function api.text(...)
    return create(text, ...)
end
function api.textln(str)
    return create(text, (str or "") .. "\n")
end
function api.button(...)
    return create(button, ...)
end
function api.radios(...)
    return create(radioGroup, ...)
end
function api.frame(...)
    return create(frame, ...)
end

gui = api;