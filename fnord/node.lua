gl.setup(400, 300)

util.data_mapper{
    ["play"] = function(what)
        fnord = util.videoplayer(what, {loop=true})
    end;
}

function node.render()
    if fnord then
        util.draw_correct(fnord, -200, -100, WIDTH+200, HEIGHT+100)
    end
end
