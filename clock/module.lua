local localized, CHILDS, CONTENTS = ...

local M = {}

local json = require "json"
local res = "w"..NATIVE_WIDTH.."h"..NATIVE_HEIGHT
local x, y, w, h
local coords 

local roboto = resource.load_font(localized "roboto.ttf")
local robotob = resource.load_font(localized "robotob.ttf")
local mononoki = resource.load_font(localized "mononoki.ttf")
local mononokib = resource.load_font(localized "mononokib.ttf")
local white = resource.create_colored_texture(1,1,1,1)
local dot = resource.load_image(localized "dot.png")
local base_time = 0
local iso_date, weekday

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
    ["weekday"] = function(day)
        weekday = day
    end;
}

function M.zeiger(size, strength, winkel, r,g,b,a)
    gl.pushMatrix()
    gl.translate(x + w/2, y + w/2)
    gl.rotate(winkel, 0, 0, 1)
    white:draw(0, -strength, size, strength)
    gl.popMatrix()
end

function M.digital_clock(hour24, minute, second)
    local digital = string.format("%02d:%02d:%02d", hour24, minute, second)
    local digital_w = mononoki:width(digital, (h-w)*0.6*0.75)
    mononoki:write(w/2 - digital_w/2, w, digital, (h-w)*0.6*0.8, 1,1,1,1)
end

function M.weekday_date()
    local date_string = weekday .. " " .. iso_date
    local date_string_w = mononoki:width(date_string, (h-w)*0.4*0.75)
    mononoki:write(w/2 - date_string_w/2, w+(h-w)/2, date_string, (h-w)*0.4*0.8, 1,1,1,1)
end

function M.scheckin_warning(hour24, minute)
    if math.floor(hour24) == 21 and minute >= 30 and minute < 55 and weekday ~= "Sunday" then
        local scheckin = "SCHECK-IN"
        local scheckin_w = mononokib:width(scheckin, w*0.08)
        mononokib:write(w/2 - scheckin_w/2, w*5/8, scheckin, w*0.1, 1,0,0,math.abs(math.sin(sys.now()*3)))
    end
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

    M.zeiger(w/4,   w/80,  360/12 * hour - 90)
    M.zeiger(w/2.5, w/160, 360/60 * minute - 90)
    M.zeiger(w/2.1, w/400, 360/60 * (((math.sin((fake_second-0.4) * math.pi*2)+1)/8) + fake_second) - 90)
    
    -- only use width because height includes date and time printed below
    dot:draw(x+w/2-w/30, y+w/2-w/30, x+w/2+w/30, y+w/2+w/30)

    M.digital_clock(hour24, minute, second)
    M.weekday_date()
    M.scheckin_warning(hour24, minute)
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
