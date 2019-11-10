gl.setup(450, 800)

local json = require "json"
local termine

util.file_watch("termine.json", function(content)
    termine = json.decode(content)
end)

util.auto_loader(_G)

function wrap(str, limit, indent, indent1)
    limit = limit or 72
    local here = 1
    local wrapped = str:gsub("(%s+)()(%S+)()", function(sp, st, word, fi)
        if fi-here > limit then
            here = st
            return "\n"..word
        end
    end)
    local splitted = {}
    for token in string.gmatch(wrapped, "[^\n]+") do
        splitted[#splitted + 1] = token
    end
    return splitted
end

function node.render()
    gl.clear(0,0,0,0)
    if not termine then
        return
    end

    local y_threshold = 730

    local y = 0
    roboto:write(10, y, "Termine", 110, 1,1,1,1)
    y = y + 130
    for i, termin in ipairs(termine) do
        for i, line in ipairs(wrap(termin.date, 20)) do
            roboto:write(10, y, line, 60, 1,1,1,1)
            y = y + 60
            if y > y_threshold then break end
        end
        y = y + 10
        for i, line in ipairs(wrap(termin.desc, 20)) do
            roboto:write(10, y, line, 50, 1,1,1,1)
            y = y + 50
            if y > y_threshold then break end
        end
        y = y + 30
        if y > y_threshold then break end
    end
end
