node.alias "*"
util.noglobals()

local loader = require "loader"

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)
function node.render()
    for name, module in pairs(loader.modules) do
        module.draw()
    end
end
