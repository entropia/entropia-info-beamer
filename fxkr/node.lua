gl.setup(100, 100)
util.auto_loader(_G)
function node.render()
    --gl.clear(1, 1, 0, 0.0)
    rightangle:draw(0, 0, WIDTH, HEIGHT, 0.8)
end

