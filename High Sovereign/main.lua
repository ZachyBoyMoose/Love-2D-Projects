function love.load()
    GameState = require('gamestate')
    GameState.load()
end

function love.update(dt)
    GameState.update(dt)
end

function love.draw()
    GameState.draw()
end

function love.mousepressed(x, y, button)
    GameState.mousepressed(x, y, button)
end

function love.keypressed(key)
    GameState.keypressed(key)
end

function love.wheelmoved(x, y)
    GameState.wheelmoved(x, y)
end