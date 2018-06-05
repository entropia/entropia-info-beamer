node.alias "*"
util.noglobals()

local settings = ({
    ["w1280h1024"] = {
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
    ["w1920h1080"] = {
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
})["w"..NATIVE_WIDTH.."h"..NATIVE_HEIGHT]

local loader = require "loader"

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
function node.render()
    for name, module in pairs(loader.modules) do
        module.draw("w"..NATIVE_WIDTH.."h"..NATIVE_HEIGHT)
    end
end
