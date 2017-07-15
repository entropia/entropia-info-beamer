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

local uhr = Uhr(settings.uhr)
local freifunk = Freifunk(settings.freifunk)

function node.render()
    uhr.draw()
    freifunk.draw()
    termine(WIDTH - 460, 120)
end
