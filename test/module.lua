local localized, CHILDS, CONTENTS = ...

local M = {}

local json = require "json"
local font = resource.load_font(localized "roboto.ttf")
local coords 
local text

print "sub module init"

function M.draw(res)
    font:write(coords[res].x, coords[res].y, text, coords[res].h, 1,1,1,1)
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
    end
end

function M.content_remove(name)
    print("sub module content delete", name)
end

return M
