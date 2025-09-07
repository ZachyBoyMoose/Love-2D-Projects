-- collisions_terrifying.lua
local State = require('lib.state')
local Collisions = require('lib.collisions')

local CollisionsTerrifying = {}

function CollisionsTerrifying.checkGondolaCollisions()
    if State.gondola.invulnerable then return end
    
    local gx = State.gondola.x + math.sin(State.gondola.swingAngle) * State.gondola.cableLength
    local gy = State.gondola.y + math.cos(State.gondola.swingAngle) * State.gondola.cableLength
    
    -- Check enemy collisions
    for _, enemy in ipairs(State.enemies) do
        local hit = false
        
        -- DAMNED SOULS collision
        if enemy.type == "damned_souls" then
            local dist = math.sqrt((gx - (enemy.swarmX or enemy.x))^2 + (gy - (enemy.swarmY or enemy.y))^2)
            if dist < 60 then
                hit = true
            end
            -- Check vortex collision
            if enemy.vortexActive then
                local vortexDist = math.sqrt((gx - enemy.vortexX)^2 + (gy - enemy.vortexY)^2)
                if vortexDist < 45 then
                    hit = true
                end
            end
            
        -- INFERNAL GRASPER collision
        elseif enemy.type == "infernal_grasper" and enemy.state == "grabbing" then
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25, 
                (enemy.grabX or enemy.x) - 40, (enemy.emergeY or enemy.y) - 60, 80, 120) then
                hit = true
            end
            
        -- FLAMING SKULL collision
        elseif enemy.type == "flaming_skull" then
            -- Skull body collision
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25,
                (enemy.patrolX or enemy.x) - 50, enemy.y - 30, 100, 60) then
                hit = true
            end
            -- Fire breath collision
            if enemy.breathing and enemy.fireBlastX then
                if gx > enemy.fireBlastX and gx < enemy.fireBlastX + 200 and
                   gy > enemy.fireBlastY - 15 and gy < enemy.fireBlastY + 15 then
                    hit = true
                end
            end
            
        -- TENTACLED ABOMINATION collision
        elseif enemy.type == "tentacled_abomination" then
            -- Body collision
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25,
                enemy.x - 60, enemy.y - 40, 120, 80) then
                hit = true
            end
            -- Tentacle strike collisions
            for i = 1, 3 do
                if enemy["tentacle" .. i .. "Striking"] then
                    local tx = enemy["tentacle" .. i .. "X"]
                    local ty = enemy["tentacle" .. i .. "Y"]
                    if tx and ty then
                        local tentDist = math.sqrt((gx - tx)^2 + (gy - ty)^2)
                        if tentDist < 30 then
                            hit = true
                        end
                    end
                end
            end
            
        -- TORMENTOR DEMON collision
        elseif enemy.type == "tormentor_demon" then
            local demonX = enemy.patrolX or enemy.x
            local demonY = enemy.patrolY or enemy.y
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25,
                demonX - 35, demonY - 50, 70, 100) then
                hit = true
            end
            
        -- LAVA SERPENT collision
        elseif enemy.type == "lava_serpent" and enemy.emerged and enemy.segments then
            for _, segment in ipairs(enemy.segments) do
                if Collisions.checkCollision(gx - 15, gy - 12, 30, 25,
                    segment.x - 30, segment.y - 20, 60, 40) then
                    hit = true
                    break
                end
            end
            
        -- Fall back to original collision system for legacy enemies
        else
            -- Check legacy enemy types
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
            -- Add other legacy enemy types as needed...
            end
        end
        
        if hit then
            State.takeDamage()
            break
        end
    end
    
    -- Check obstacle collisions
    for _, obstacle in ipairs(State.obstacles or {}) do
        local hit = false
        
        -- BLOOD GEYSER collision
        if obstacle.type == "blood_geyser" and obstacle.erupting then
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25,
                obstacle.x - 20, obstacle.y - (obstacle.sprayHeight or 0), 40, obstacle.sprayHeight or 100) then
                hit = true
            end
            
        -- SOUL CHAIN collision
        elseif obstacle.type == "soul_chain" then
            local chainDist = math.sqrt((gx - (obstacle.chainX or obstacle.x))^2 + 
                                      (gy - (obstacle.chainY or obstacle.y))^2)
            if chainDist < 25 then
                hit = true
            end
            
        -- INFERNAL GATE collision
        elseif obstacle.type == "infernal_gate" and not obstacle.gateOpen then
            if Collisions.checkCollision(gx - 15, gy - 12, 30, 25,
                obstacle.x - 50, obstacle.y - 75, 100, 150) then
                hit = true
            end
            
        -- SCREAMING PILLAR collision
        elseif obstacle.type == "screaming_pillar" and obstacle.screaming then
            local waveDist = math.sqrt((gx - obstacle.x)^2 + (gy - obstacle.y)^2)
            if waveDist < (obstacle.waveRadius or 0) and waveDist > (obstacle.waveRadius or 0) - 20 then
                hit = true
            end
        end
        
        if hit then
            State.takeDamage()
            break
        end
    end
end

return CollisionsTerrifying