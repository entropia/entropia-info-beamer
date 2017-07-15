gl.setup(768, 64) -- foo

node.alias("kvv")
node.set_flag("no_clear")

local json = require "json"

-- sensible default?
live = {}
live.departures = {}

util.file_watch("live.json", function(content)
    live = json.decode(content)
end)

util.auto_loader(_G)


abfahrt = util.generator(function()
    return live.departures
end)

util.set_interval(2, function()
    scroll = sys.now()

    prev = current
    ok, maybe_current = pcall(abfahrt.next)
    if ok then
        current = maybe_current
    end
end)

local colored = resource.create_shader[[
    uniform sampler2D Texture;
    varying vec2 TexCoord;
    uniform vec4 color;
    void main() {
        // gl_FragColor = color * (1.0 - distance(TexCoord, vec2(0.5, 0.5)))*2.0;
        gl_FragColor = color;
    }
]]

function from_html(rgb)
    local r = 1.0 / 255 * tonumber("0x" .. rgb:sub(1,2))
    local g = 1.0 / 255 * tonumber("0x" .. rgb:sub(3,4))
    local b = 1.0 / 255 * tonumber("0x" .. rgb:sub(5,6))
    return {r, g, b, 0.8}
end

local mapping = {
    ["1"]   = from_html "ed1c24";
    ["2"]   = from_html "0071bc";
    ["4"]   = from_html "ffd008";
    ["5"]   = from_html "00c0f3";
    ["6E"]  = from_html "80c342";
    ["S1"]  = from_html "00a76d";
    ["S11"] = from_html "00a76d";
    ["S2"]  = from_html "a068aa";
    ["S4"]  = from_html "9f184c";
    ["S41"] = from_html "9f184c";
    ["S5"]  = from_html "f8aca5";
}

function print_abfahrt(fahrt, y)
    if fahrt.time == "0" then
        fahrt.time = "jetzt"
    end

    local color = mapping[fahrt.route]
    if color ~= nil then
        colored:use{color = color}
        white:draw(0,-y,120,-y + 64)
        colored:deactivate()
    end

    roboto:write(55 - 15 * #fahrt.route, 3 - y, fahrt.route, 60, 1,1,1,1)
    roboto:write(150, 3 - y, string.format(
        "%s -%s", 
        fahrt.time,
        fahrt.destination
    ),
    60, 1,1,1,1)
end

function node.render()
    -- pp(prev)
    -- gl.clear(0,0,0,0)
    local delta = sys.now() - scroll
    if current then
        print_abfahrt(current, 64 - math.min(delta * 128, 64))
    end
    if prev then
        print_abfahrt(prev, 0 - math.min(delta * 128, 64))
    end
end

-----------------------------------------

function dump_abfahrt()
    for i, fahrt in pairs(live.departures) do
        print(string.format("%10s - %10s - %s", fahrt.route, fahrt.time, fahrt.destination))
    end
end

if not N.clients then
    N.clients = {}
end

node.event("connect", function(client)
    local handler = coroutine.wrap(function()
        print("KVV Fahrtplanauskunft")
        while true do
            print()
            dump_abfahrt()
            print()
            print("<enter> aktualisiert")
            local input = coroutine.yield()
        end
    end)
    N.clients[client] = handler
    handler()
end)

node.event("input", function(line, client)
    N.clients[client](line)
end)

node.event("disconnect", function(client)
    N.clients[client] = nil
end)

