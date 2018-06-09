local localized, CHILDS, CONTENTS = ...

local M = {}

local json = require "json"
local res = "w"..NATIVE_WIDTH.."h"..NATIVE_HEIGHT
local coords 

local roboto = resource.load_font(localized "roboto.ttf")
local robotob = resource.load_font(localized "robotob.ttf")
local white = resource.create_colored_texture(1,1,1,1)
local dot = resource.load_image(localized "dot.png")
local x, y, w, h
local hours, hours12, minutes, seconds = 0
local iso_date

util.data_mapper{
    ["hours"] = function(hour)
        hours = tonumber(hour)
        hours12 = hours % 12
    end;
    ["minutes"] = function(minute)
        minutes = tonumber(minute)
    end;
    ["seconds"] = function(second)
        seconds = tonumber(second)
    end;
    ["iso_date"] = function(iso)
        iso_date = iso
    end;
}

function M.zeiger(size, strength, winkel, r,g,b,a)
    gl.pushMatrix()
    gl.translate(w/2, h/2) 
    gl.rotate(winkel, 0, 0, 1)
    white:draw(0, -strength, size, strength)
    gl.popMatrix()
end

function M.draw()
    local fake_second = seconds * 1.05
    if fake_second >= 60 then
        fake_second = 60
    end
    
    if hours and minutes and seconds then
        M.zeiger(w/4,  10, 360/12 * hours12 - 90)
        M.zeiger(w/2.5, 5, 360/60 * minutes - 90)
        M.zeiger(w/2.1, 2, 360/60 * (((math.sin((fake_second-0.4) * math.pi*2)+1)/8) + fake_second) - 90)
    end
end

function M.unload()
    print "sub module is unloaded"
end

function M.content_update(name)
    print("sub module content update", name)
    if name == 'test.txt' then
        text = resource.load_file(localized(name))
    end
    if name == 'coords.json' then
        coords = json.decode(resource.load_file(localized(name)))
        x = coords[res].x
        y = coords[res].y
        w = coords[res].w
        h = coords[res].h
    end
end

function M.content_remove(name)
    print("sub module content delete", name)
end

return M
