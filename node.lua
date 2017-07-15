gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

node.alias "*"
util.noglobals()

local settings = ({
    ["1280x1024"] = {
        uhr = {
            x = 0,
            y = 0,
            size = 200,
        },
        freifunk = {
            x = 0,
            y = 200,
            size = 100,
        },
        termine = {
            x = 0,
            y = 300,
            size = 100,
        },
    },
    ["1920x1080"] = {
        uhr = {
            x = 0,
            y = 0,
            size = 200,
        },
        freifunk = {
            x = 0,
            y = 200,
            size = 100,
        },
        termine = {
            x = 0,
            y = 300,
            size = 100,
        },
    },
})[NATIVE_WIDTH.."x"..NATIVE_HEIGHT]

local font = resource.load_font "font.ttf"

node.event("data", function(...)
    print(...)
end)

local function Freifunk(opt)
    local total_clients = 0
    util.data_mapper{
        ["freifunk/clients"] = function(raw)
            total_clients = tonumber(raw)
        end
    }

    local function draw()
        font:write(opt.x, opt.y, "Freifunk", opt.size, 1,1,1,1)
        font:write(opt.x, opt.y+opt.size, string.format("Clients: %d", total_clients), opt.size, 1,1,1,1)
    end

    return {
        draw = draw;
    }
end

local function Uhr(opt)
    local since_midnight = 0
    util.data_mapper{
        ["clock/time"] = function(raw)
            since_midnight = tonumber(raw) - sys.now()
        end
    }

    local function draw()
        local now = since_midnight + sys.now()
        local hour = math.floor(now / 3600)
        local minute = now % 3600 / 60
        local time = string.format("%d:%02d", hour, minute)
        font:write(opt.x, opt.y, time, opt.size, 1,1,1,1)
    end

    return {
        draw = draw;
    }
end

local function termine(opt)

util.file_watch("termine/termine.json", function(content)
    termine = json.decode(content)
end)

util.auto_loader(_G)

	local function wrap(str, limit, indent, indent1)
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

local function draw()
	local y_threshold = 730

    local y = 0
    font:write(10, y, "Termine", 110, 1,1,1,1)
    y = y + 130
    for i, termin in ipairs(termine) do
        for i, line in ipairs(wrap(termin.date, 20)) do
            font:write(10, y, line, 60, 1,1,1,1)
            y = y + 60
            if y > y_threshold then break end
        end
        y = y + 10
        for i, line in ipairs(wrap(termin.desc, 20)) do
            font:write(10, y, line, 50, 1,1,1,1)
            y = y + 50
            if y > y_threshold then break end
        end
        y = y + 30
        if y > y_threshold then break end
    end
    return {
        draw = draw;
    }
end
end


local uhr = Uhr(settings.uhr)
local freifunk = Freifunk(settings.freifunk)
local termine = Termine(settings.termine)

function node.render()
    uhr.draw()
    freifunk.draw()
    termine.draw()
end
