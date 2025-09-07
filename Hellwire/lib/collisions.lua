local State = require('lib.state')

local Collisions = {}

function Collisions.checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function Collisions.checkGondolaCollisions()
    if State.gondola.invulnerable then return end
    
    local gx = State.gondola.x + math.sin(State.gondola.swingAngle) * State.gondola.cableLength
    local gy = State.gondola.y + math.cos(State.gondola.swingAngle) * State.gondola.cableLength
    
    for _, enemy in ipairs(State.enemies) do
        local hit = false
        
        if enemy.type == "spike" then
            local currentX = enemy.currentX or enemy.x
            local currentY = enemy.currentY or enemy.y
            local tipX = currentX + math.cos(enemy.angle) * 15
            local tipY = currentY + math.sin(enemy.angle) * 15
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25, tipX - 7, tipY - 7, 14, 14) then
                hit = true
            end

        elseif enemy.type == "fireball" and enemy.orbX then
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25, enemy.orbX - 15, enemy.orbY - 15, 30, 30) then
                hit = true
            end
            
        elseif enemy.type == "swinger" and enemy.hazardX then
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25, enemy.hazardX - 16, enemy.hazardY - 16, 32, 32) then
                hit = true
            end
            
        elseif enemy.type == "rotator" then
            local beam1X = enemy.x + math.cos(enemy.rotation) * enemy.radius
            local beam1Y = enemy.y + math.sin(enemy.rotation) * enemy.radius
            local beam2X = enemy.x - math.cos(enemy.rotation) * enemy.radius
            local beam2Y = enemy.y - math.sin(enemy.rotation) * enemy.radius
            local dist1 = math.sqrt((gx - beam1X)^2 + (gy - beam1Y)^2)
            local dist2 = math.sqrt((gx - beam2X)^2 + (gy - beam2Y)^2)
            if dist1 < 20 or dist2 < 20 then
                hit = true
            end
            
        elseif (enemy.type == "acid_drop" or enemy.type == "lava_drop") and enemy.dropY and not enemy.isWaiting then
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25, enemy.x - 10, enemy.dropY - 10, 20, 20) then
                hit = true
            end
            
        elseif enemy.type == "bubble" and enemy.bubbleY then
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25, enemy.x - 20, enemy.bubbleY - 20, 40, 40) then
                hit = true
            end
            
        elseif enemy.type == "guardian" and enemy.shooting and enemy.projectileX then
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25, enemy.projectileX - 10, enemy.projectileY - 10, 20, 20) then
                hit = true
            end
            
        elseif enemy.type == "bone_throw" and enemy.throwing and enemy.boneY then
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25, enemy.x - 10, enemy.boneY - 10, 20, 20) then
                hit = true
            end
            
        elseif enemy.type == "flesh_blob" then
            local size = 30 * (enemy.scale or 1)
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25, enemy.x - size/2, enemy.y - size/2, size, size) then
                hit = true
            end
            
        elseif enemy.type == "cannon" and enemy.shooting and enemy.ballX then
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25, enemy.ballX - 8, enemy.ballY - 8, 16, 16) then
                hit = true
            end
            
        elseif enemy.type == "boss_train" then
            if gx < enemy.x + 100 and gx > enemy.x - 50 and gy < enemy.y + 40 and gy > enemy.y - 40 then
                hit = true
            end
        end
        
        if hit then
            State.takeDamage()
            break
        end
    end
end

return Collisions