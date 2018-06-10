local localized, CHILDS, CONTENTS = ...

local M = {}

local json = require "json"
local res = "w"..NATIVE_WIDTH.."h"..NATIVE_HEIGHT
local x, y, w, h
local coords 

local roboto = resource.load_font(localized "roboto.ttf")
local robotob = resource.load_font(localized "robotob.ttf")
local white = resource.create_colored_texture(1,1,1,1)
local dot = resource.load_image(localized "dot.png")
local base_time = 0
local iso_date

util.data_mapper{
    ["time"] = function(time)
        -- get the time when info-beamer was started
        -- needed for smoothly moving handles,
        -- otherwise the handles only get updated when the clock service sends new data
        base_time = tonumber(time) - sys.now()
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
    local time = base_time + sys.now()

    local hour24 = (time / 3600) % 24
    local hour = (time / 3600) % 12
    local minute = time % 3600 / 60
    local second = time % 60
    
    local fake_second = second * 1.05
    if fake_second >= 60 then
        fake_second = 60
    end
    
    if base_time ~= 0 then
        M.zeiger(w/4,  10, 360/12 * hour - 90)
        M.zeiger(w/2.5, 5, 360/60 * minute - 90)
        M.zeiger(w/2.1, 2, 360/60 * (((math.sin((fake_second-0.4) * math.pi*2)+1)/8) + fake_second) - 90)
    end
end

function M.unload()
    print "sub module is unloaded"
end

function M.content_update(name)
    print("sub module content update", name)
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
