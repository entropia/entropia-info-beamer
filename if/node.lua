gl.setup(512, 69)

util.auto_loader(_G)

node.alias("traffic")
node.set_flag("no_clear")

local stats = {
    qdsl_in  = 0.2;
    qdsl_out = 0.2;
}

util.data_mapper{
    ["(.*)"] = function(iface, val)
        stats[iface] = tonumber(val)
    end;
}

function node.render()
    roboto:write(5, 2, "down", 30, 1,1,1,1)
    roboto:write(5, 35, "up",  30, 1,1,1,1)
    white:draw(100, 0,  100 + 412 * stats.qdsl_in,  31)
    white:draw(100, 32, 100 + 412 * stats.qdsl_out, 64)
end

