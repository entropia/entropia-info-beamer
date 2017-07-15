gl.setup(300, 700)

local json = require "json"

util.file_watch("conditions.json", function(content)
    conditions = json.decode(content)
end)

util.file_watch("forecast.json", function(content)
    forecast = json.decode(content)
end)

-- invoke the autoloader
util.auto_loader(_G)

function centered_text(y, font, r,g,b,a)
    local x 
    local size = 5
    local function write(text)
        local width = font:write(x or 0, y, text, size, r, g, b, a)
        x = WIDTH/2 - width/2
        if width > WIDTH - 10 then
            size = size - 2
        elseif width < WIDTH - 20 then
            size = size * 1.2
        end
    end
    return write
end

local icon_shader = resource.create_shader[[
    uniform sampler2D Texture;
    varying vec2 TexCoord;

    void main() {
        vec4 color = texture2D(Texture, TexCoord.st);
        float sum = color.r + color.g + color.b;
        gl_FragColor = vec4(
            sum / 0.5,
            sum / 0.5,
            sum / 0.5,
            color.a - sum / 2.0
        );
    }
]]

local wind = centered_text(300, roboto, 1,1,1,1)
local desc = centered_text(350, roboto, 1,1,1,1)
local celcius = centered_text(500, roboto, 1,1,1,1)
local updated = centered_text(0, roboto, 1,1,1,1) 

function set_last_updated(obs)
   local datestr = obs.observation_time_rfc822
   local day, month, hour, minute = string.match(datestr, "%a%a%a, (%d%d) (%a%a%a) %d%d%d%d (%d%d):(%d%d):%d%d .*")
   updated(string.format("    %s %s, %s:%s    ", day, month, hour, minute))
end

function node.render()
    gl.clear(0,0,0,0)
    local obs = conditions.current_observation
    wind(string.format("%d km/h %s", obs.wind_kph, obs.wind_dir))
    celcius(string.format("%d °C", obs.temp_c))
    desc(obs.weather)
    set_last_updated(obs)

    icon_shader:use()
    util.draw_correct(_G[obs.icon], 0, 0, 300, 250)
end
