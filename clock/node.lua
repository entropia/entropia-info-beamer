gl.setup(800, 800)

node.set_flag "slow_gc"

util.auto_loader(_G)

local json = require "json"

local base_time = N.base_time or 0
local day = ""
local wday = 8
local dots = N.dots or {}

local days = {
    "Mo", "Di", "Mi", "Do", "Fr", "Sa", "So", ""
}

util.data_mapper{
    ["time"] = function(time)
        base_time = tonumber(time) - sys.now()
        N.base_time = base_time
    end;
    ["weekday"] = function(new_wday)
        wday = tonumber(new_wday)
    end;
    ["monthday"] = function(new_day)
        day = new_day .. "."
    end;
    ["dots"] = function(raw)
        dots = json.decode(raw)
        if bg then
            bg:dispose()
            bg = nil
        end
        N.dots = dots
    end;
}

local wobbly = resource.create_shader[[
    uniform sampler2D Texture;
    varying vec2 TexCoord;
    uniform vec4 Color;
    uniform float t;
    void main() {
        vec2 target = vec2(TexCoord.x, (TexCoord.y - 0.5) * (sin(t) + 2.0) + 0.5);
        gl_FragColor = texture2D(Texture, target) * Color;
    }
]]

function zeiger(size, strength, winkel, r,g,b,a)
    wobbly:use{t = strength * math.cos(sys.now() + winkel / 360 * math.pi)}
    gl.pushMatrix()
    gl.translate(WIDTH/2, HEIGHT/2)
    gl.rotate(winkel, 0, 0, 1)
    tentacle:draw(0, -strength*6, size*1.2, strength*6)
    gl.popMatrix()
    wobbly:deactivate()
end

function zeiger(size, strength, winkel, r,g,b,a)
    gl.pushMatrix()
    gl.translate(WIDTH/2, HEIGHT/2)
    gl.rotate(winkel, 0, 0, 1)
    white:draw(0, -strength, size, strength)
    gl.popMatrix()
end

local colored = resource.create_shader[[
    uniform sampler2D Texture;
    varying vec2 TexCoord;
    uniform vec4 color;
    void main() {
        gl_FragColor = color;
    }
]]

function colored_marker(winkel, nth, r, g, b, text)
    local dist = WIDTH/2 - 90 - nth * 50
    winkel = winkel - 2

    gl.pushMatrix()
    gl.translate(WIDTH/2, HEIGHT/2)
    gl.rotate(winkel, 0, 0, 1)
    gl.translate(dist, 0)
    white:draw(0, 0, 40, 20, 0.5)
    colored:use{color = {r, g, b, 0.8}}
    white:draw(0, 0, 40, 20)
    colored:deactivate()
    gl.translate(20, 10)
    gl.rotate(-winkel, 0, 0, 1)
    text_w = #text
    local d = 8
    local s = 20
    -- roboto:write(-5 * text_w - 3,-3-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w - 2,-2-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w + 2, 2-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w + 3, 3-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w - 3, 3-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w - 2, 2-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w + 2,-2-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w + 3,-3-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w - 1,-1-d, text, 20, 1,1,1,1)
    -- roboto:write(-5 * text_w + 0, 0-d, text, 20, 1,1,1,1)
    -- roboto:write(-5 * text_w + 1, 1-d, text, 20, 1,1,1,1)
    -- roboto:write(-5 * text_w - 1,-1-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w - 1, 1-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w + 1,-1-d, text, 20, 0,0,0,1)
    -- roboto:write(-5 * text_w + 1, 1-d, text, 20, 0,0,0,1)
    roboto:write(-5 * text_w + 0, 0-d, text, 20, 1,1,1,1)
    gl.popMatrix()
end


function node.render()
    if not bg then
        gl.pushMatrix()
        gl.translate(WIDTH/2, HEIGHT/2)
        for i = 0, 59 do
            gl.pushMatrix()
            gl.rotate(360/60*i, 0, 0, 1)
            if i % 15 == 0 then
                white:draw(WIDTH/2.1-80, -10, WIDTH/2.1, 10, 0.8)
            elseif i % 5 == 0 then
                white:draw(WIDTH/2.1-50, -10, WIDTH/2.1, 10, 0.7)
            else
                white:draw(WIDTH/2.1-5, -5, WIDTH/2.1, 5, 0.6)
            end
            gl.popMatrix()
        end
        gl.popMatrix()

        for since_the_hour, cdots in pairs(dots) do
            since_the_hour = tonumber(since_the_hour)
            local angle = 360 / 60 * (since_the_hour / 60) - 90
            for idx, dot_and_route in ipairs(cdots) do
                local dot = dot_and_route[1]
                local route = dot_and_route[2]
                colored_marker(angle, idx, dot[1], dot[2], dot[3], route)
            end
        end
        bg = resource.create_snapshot()
    else
        bg:draw(0,0,WIDTH,HEIGHT)
    end

    local time = base_time + sys.now()

    local hour24 = (time / 3600) % 24
    local hour = (time / 3600) % 12
    local minute = time % 3600 / 60
    local second = time % 60
    -- print(hour, minute, second)

    local fake_second = second * 1.05
    if fake_second >= 60 then
        fake_second = 60
    end

    -- roboto:write(0, 0, days[wday], 80, 1,1,1,1)
    -- roboto:write(0, HEIGHT-80, day, 80, 1,1,1,1)
    gl.pushMatrix()
    gl.translate(12, 680)
    gl.rotate(-8, 0, 0, 1)
    gl.rotate( 20, 0, 1, 0)
    gl.rotate( 0, 1, 0, 0)
    local w = roboto:width(days[wday], 70)
    roboto:write(50-w/2, 0, days[wday], 70, 0,0,0,1)
    roboto:write(40, 70, day, 35, 0,0,0,1)
    gl.popMatrix()

    if math.floor(hour24) == 21 and minute >= 40 and minute < 55 and wday ~= 7 then
        robotob:write(160, 180, "SCHECKIN", 100, 1,0,0,math.abs(math.sin(sys.now()*3)))
    end

    if base_time ~= 0 then
        zeiger(WIDTH/4,   10, 360/12 * hour - 90)
        zeiger(WIDTH/2.5, 5, 360/60 * minute - 90)
        zeiger(WIDTH/2.1,  2, 360/60 * (((math.sin((fake_second-0.4) * math.pi*2)+1)/8) + fake_second) - 90)
    end
    dot:draw(WIDTH/2-40, HEIGHT/2-40, WIDTH/2+40, HEIGHT/2+40)

    local digital = string.format("%d:%02d", hour24, minute)
    local w = roboto:width(digital, 100) + 5
    robotob:write(WIDTH/2 - w/2, HEIGHT/2 -300, digital, 100, 1,1,1,0.8)
end
