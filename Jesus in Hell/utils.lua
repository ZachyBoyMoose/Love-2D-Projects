-- utils.lua
-- Helper functions for the game

-- Debug mode flag
DEBUG_MODE = false

function checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

function getSign(val)
    if val > 0 then return 1
    elseif val < 0 then return -1
    else return 0 end
end

function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function lerp(a, b, t)
    return a + (b - a) * t
end

function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function randomFloat(min, max)
    return min + math.random() * (max - min)
end

function angleToVector(angle)
    return math.cos(angle), math.sin(angle)
end

function vectorToAngle(x, y)
    return math.atan2(y, x)
end

function normalizeVector(x, y)
    local len = math.sqrt(x*x + y*y)
    if len > 0 then
        return x/len, y/len
    end
    return 0, 0
end

function screenToWorld(screenX, screenY)
    local worldX = screenX / camera.scale + camera.x
    local worldY = screenY / camera.scale + camera.y
    return worldX, worldY
end

function worldToScreen(worldX, worldY)
    local screenX = (worldX - camera.x) * camera.scale
    local screenY = (worldY - camera.y) * camera.scale
    return screenX, screenY
end

-- Color utilities
colors = {
    white = {1, 1, 1},
    black = {0, 0, 0},
    red = {1, 0, 0},
    green = {0, 1, 0},
    blue = {0, 0, 1},
    yellow = {1, 1, 0},
    orange = {1, 0.5, 0},
    purple = {0.5, 0, 0.5},
    gray = {0.5, 0.5, 0.5},
    darkGray = {0.3, 0.3, 0.3},
    lightGray = {0.7, 0.7, 0.7}
}

function setColor(color, alpha)
    alpha = alpha or 1
    love.graphics.setColor(color[1], color[2], color[3], alpha)
end

function drawDebugInfo()
    if DEBUG_MODE then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setNewFont(12)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)
        love.graphics.print("Enemies: " .. #enemies, 10, 25)
        love.graphics.print("Player Health: " .. player.health, 10, 40)
        love.graphics.print("Combo: " .. comboCounter, 10, 55)
        love.graphics.print("Camera X: " .. math.floor(camera.x), 10, 70)
        love.graphics.print("Wave: " .. currentWave .. "/" .. maxWave, 10, 85)
        love.graphics.print("Boss Active: " .. tostring(boss.active), 10, 100)
        
        -- Draw collision boxes
        love.graphics.setColor(0, 1, 0, 0.3)
        love.graphics.rectangle("line", player.x, player.y, player.width, player.height)
        
        love.graphics.setColor(1, 0, 0, 0.3)
        for _, enemy in ipairs(enemies) do
            if enemy.active then
                love.graphics.rectangle("line", enemy.x, enemy.y, enemy.width, enemy.height)
            end
        end
    end
end