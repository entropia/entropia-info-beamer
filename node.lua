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
        test = {
            x = 0,
            y = 0,
            w = 200,
            h = 200,
        },
        freifunk = {
            x = 0,
            y = 200,
            w = 200,
            h = 200,
        },
        termine = {
            x = 0,
            y = 300,
            w = 200,
            h = 200,
        },
    },
})[NATIVE_WIDTH.."x"..NATIVE_HEIGHT]

local loader = require "loader"

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
function node.render()
    for name, module in pairs(loader.modules) do
        module.draw(settings[module].x, settings[module].y, settings[module].w, settings[module].h)
    end
end
