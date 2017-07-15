gl.setup(1280, 80)

local json = require "json"
local mpd

node.set_flag "no_clear"

util.data_mapper{
    update = function(update)
        mpd = json.decode(update)
    end
}

-- invoke the autoloader
local res = util.auto_loader()
local white = resource.create_colored_texture(1, 1, 1, 1)

local white_to_transparent = resource.create_shader[[
    uniform sampler2D Texture;
    varying vec2 TexCoord;

    void main() {
        vec4 color = texture2D(Texture, TexCoord.st);
        float sum = color.r + color.g + color.b;
        if (sum > 2.7) {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
        } else {
            gl_FragColor = color;
        };
    }
]]

function text_scroll(opt)
    local last_text, current_offset, mode, mode_change, alpha
    local function reset(text)
        last_text = text
        current_offset = opt.x
        mode = "start"
        mode_change = sys.now()
        alpha = 0
    end

    reset("")

    local function draw(text)
        if text ~= last_text then
            reset(text)
        end
        local text_width = opt.font:write(current_offset, opt.y, text, opt.size, 1,1,1,alpha)
        local delta = sys.now() - mode_change 
        if mode == "end" then
            alpha = math.min((opt.delay - delta) * opt.delay/2, 1)
            if delta > opt.delay then
                reset(text)
            end
        elseif mode == "scroll" then
            local offset = delta * opt.speed
            if offset > text_width - opt.width then
                mode = "end"
                mode_change = sys.now()
            else
                current_offset = opt.x - offset
            end
        elseif mode == "start" then
            alpha = math.min(delta * opt.delay/2, 1)
            if delta > opt.delay and text_width > opt.width then
                mode = "scroll"
                mode_change = sys.now()
            end
        end
    end

    return {
        draw = draw;
    }
end

local info_scroll = text_scroll{
    font = res.roboto;
    width = WIDTH - 150;
    x = 150;
    y = 3;
    size = 70;
    delay = 3;
    speed = 30;
}

function node.render()
    if not mpd then
        return
    end
    if mpd.status.state == "play" then
        icon = res.play
        if res.qrcode ~= nil then
            icon = res.qrcode
        end
        song = {}
        if mpd.song.title ~= nil then
            song[#song+1] = mpd.song.title
        end
        if mpd.song.artist ~= nil then
            song[#song+1] = mpd.song.artist
        end
        if #song == 0 then
            info = mpd.song.file
        else
            song[#song+1] = mpd.song.file
            info = table.concat(song, " // ")
        end
    elseif mpd.status.state == "pause" then
        icon = res.pause
        info = "Music paused"
    else
        icon = res.stop
        info = "Music stopped"
    end

    info_scroll.draw(info)
    res.blend:draw(0, 0, 150, HEIGHT, 0.95)
    white_to_transparent:use()
    util.draw_correct(icon, 10, 0, 10+HEIGHT, HEIGHT)
    white_to_transparent:deactivate()

    if mpd.status.state == "play" then
        local w = (WIDTH-100) * mpd.percent
        white:draw(100, 75, 100 + w, 80, 1.0)
    end
end
