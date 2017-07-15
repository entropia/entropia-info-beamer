gl.setup(1280, 1024)

hosted_init()

node.set_flag("slow_gc")

local json = require "json"
local white = resource.create_colored_texture(1,1,1,1)

local black_to_transparent = resource.create_shader[[
    uniform sampler2D Texture;
    varying vec2 TexCoord;

    void main() {
        vec4 color = texture2D(Texture, TexCoord.st);
        float sum = color.r + color.g + color.b;
        if (sum < 0.3) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        } else {
            gl_FragColor = color;
        };
    }
]]


local r, g, b = 0, 0, 0

util.data_mapper{
    bgcolor = function(new_color)
        new_color = json.decode(new_color)
        r = new_color.r
        g = new_color.g
        b = new_color.b
    end;

    ["interrupt/start"] = function(child)
        interrupt_child = child
    end;

    ["interrupt/stop"] = function()
        interrupt_child = nil
    end;
}

function square(child, width, height, n)
    local cache, cache_used
    n = n or 0
    cache_used = 9999999999
    local fastchild = sys.get_ext("fastchild")
    return function(x, y)
        if n == 0 then
            fastchild.draw_child(child, x, y, x + width, y + height)
        else 
            if cache_used >= n then
                if cache then
                    cache:dispose()
                end
                cache = resource.render_child(child)
                cache_used = 0
            end
            cache_used = cache_used + 1
            util.draw_correct(cache, x, y, x + width, y + height)
        end
    end
end

local clock = square("clock", 800, 800, 1)
local mpd = square("mpd", 1280, 80)
local weather = square("weather", 300, 700, 5)
local termine = square("termine", 450, 800, 60)
local interface = square("if", 512, 69)
local kvv = square("kvv", 768, 64)
-- fxkr = square("fxkr", 100, 100, 60)

local frame = 0

function node.render()
    frame = frame + 1

    CONFIG.overlay.ensure_loaded():draw(0, 0, WIDTH, HEIGHT)
    clock(10, 110)
    if interrupt_child then
        print("drawing child " .. interrupt_child)
        local child = resource.render_child(interrupt_child)
        util.draw_correct(child, 0, 0, WIDTH, HEIGHT, 0.5)
        child:dispose()
    end

    mpd(0, HEIGHT-80)
    if sys.now() / 15 % 2 < 1 then
        termine(WIDTH - 460, 120)
    else
        weather(WIDTH - 380, 130)
    end
    interface(0, 0)
    kvv(WIDTH-760, 0)
end
