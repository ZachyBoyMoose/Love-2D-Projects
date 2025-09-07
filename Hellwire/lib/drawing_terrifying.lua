local Config = require('lib.config_terrifying')
local State = require('lib.state')
local Drawing = require('lib.drawing')

local DrawingTerrifying = {}

function DrawingTerrifying.drawEnemies()
    love.graphics.setColor(1, 1, 1)
    
    for _, enemy in ipairs(State.enemies) do
        -- DAMNED SOUL SWARM
        if enemy.type == "damned_souls" and enemy.animation then
            enemy.animation:draw(enemy.swarmX or enemy.x, enemy.swarmY or enemy.y, 0, 1, 1, 50, 50)
            
            -- Draw vortex effect
            if enemy.vortexActive then
                love.graphics.setColor(0.6, 0.6, 1, 0.5)
                for i = 1, 3 do
                    local radius = 20 + i * 15
                    love.graphics.circle("line", enemy.vortexX, enemy.vortexY, radius)
                end
                love.graphics.setColor(1, 1, 1)
            end
            
        -- INFERNAL GRASPER
        elseif enemy.type == "infernal_grasper" and enemy.animation and enemy.state ~= "hidden" then
            enemy.animation:draw(enemy.grabX or enemy.x, enemy.emergeY or enemy.y, 0, 1.5, 1.5, 40, 60)
            
            -- Draw warning zone when emerging
            if enemy.state == "emerging" then
                love.graphics.setColor(1, 0, 0, 0.3)
                love.graphics.rectangle("fill", enemy.x - 50, enemy.targetY, 100, 150)
                love.graphics.setColor(1, 1, 1)
            end
            
        -- FLAMING LEVIATHAN SKULL
        elseif enemy.type == "flaming_skull" and enemy.animation then
            enemy.animation:draw(enemy.patrolX or enemy.x, enemy.y, 0, 1.2, 1.2, 50, 30)
            
            -- Draw fire breath
            if enemy.breathing and enemy.fireBlastAnimation then
                enemy.fireBlastAnimation:draw(enemy.fireBlastX, enemy.fireBlastY, 0, 1, 1, 0, 15)
            end
            
        -- TENTACLED ABOMINATION
        elseif enemy.type == "tentacled_abomination" and enemy.animation then
            enemy.animation:draw(enemy.x, enemy.y, 0, 1.3, 1.3, 60, 40)
            
            -- Draw tentacle strikes
            love.graphics.setColor(0.5, 0.2, 0.6, 0.8)
            for i = 1, 3 do
                if enemy["tentacle" .. i .. "Striking"] then
                    love.graphics.setLineWidth(20)
                    love.graphics.line(enemy.x, enemy.y, enemy["tentacle" .. i .. "X"], enemy["tentacle" .. i .. "Y"])
                end
            end
            love.graphics.setColor(1, 1, 1)
            
        -- TORMENTOR DEMON
        elseif enemy.type == "tormentor_demon" and enemy.animation then
            local rotation = enemy.diving and math.atan2(enemy.diveTargetY - enemy.diveStartY, enemy.diveTargetX - enemy.diveStartX) or 0
            enemy.animation:draw(enemy.patrolX or enemy.x, enemy.patrolY or enemy.y, rotation, 1, 1, 35, 50)
            
            -- Draw dive trail
            if enemy.diving then
                love.graphics.setColor(0.8, 0, 0, 0.5)
                love.graphics.setLineWidth(10)
                love.graphics.line(enemy.diveStartX, enemy.diveStartY, enemy.patrolX, enemy.patrolY)
                love.graphics.setColor(1, 1, 1)
            end
            
        -- LAVA SERPENT
        elseif enemy.type == "lava_serpent" and enemy.emerged and enemy.segments then
            for i, segment in ipairs(enemy.segments) do
                segment.animation:draw(segment.x, segment.y, 0, 1, 1, 30, 20)
            end
            
        -- Fall back to original drawing for legacy enemies
        else
            Drawing.drawEnemies()
        end
    end
    
    -- Draw obstacles
    for _, obstacle in ipairs(State.obstacles) do
        -- BLOOD GEYSER
        if obstacle.type == "blood_geyser" and obstacle.animation then
            obstacle.animation:draw(obstacle.x, obstacle.y, 0, 1, 1, 20, 20)
            
            -- Draw eruption
            if obstacle.erupting then
                love.graphics.setColor(0.8, 0, 0, 0.7)
                for i = 1, 10 do
                    local sprayX = obstacle.x + math.random(-20, 20)
                    local sprayY = obstacle.y - obstacle.sprayHeight + math.random(-10, 10)
                    love.graphics.circle("fill", sprayX, sprayY, math.random(3, 8))
                end
                love.graphics.setColor(1, 1, 1)
            end
            
        -- SOUL CHAIN
        elseif obstacle.type == "soul_chain" and obstacle.animation then
            -- Draw chain links
            love.graphics.setColor(0.6, 0.6, 0.7)
            love.graphics.setLineWidth(5)
            love.graphics.line(obstacle.x, obstacle.y, obstacle.chainX, obstacle.chainY)
            love.graphics.setColor(1, 1, 1)
            
            -- Draw soul at end
            obstacle.animation:draw(obstacle.chainX, obstacle.chainY, obstacle.swingAngle, 2, 2, 10, 10)
            
        -- INFERNAL GATE
        elseif obstacle.type == "infernal_gate" and obstacle.animation then
            local scaleX = 1 - obstacle.openAmount * 0.8
            obstacle.animation:draw(obstacle.x, obstacle.y, 0, scaleX, 1, 50, 75)
            
            -- Draw danger zone when closed
            if not obstacle.gateOpen then
                love.graphics.setColor(1, 0, 0, 0.2)
                love.graphics.rectangle("fill", obstacle.x - 50, obstacle.y - 75, 100, 150)
                love.graphics.setColor(1, 1, 1)
            end
            
        -- SCREAMING PILLAR
        elseif obstacle.type == "screaming_pillar" and obstacle.animation then
            obstacle.animation:draw(obstacle.x, obstacle.y, 0, 1, 1, 30, 100)
            
            -- Draw sonic waves
            if obstacle.screaming then
                love.graphics.setColor(0.7, 0.7, 0.7, 0.5 - obstacle.waveRadius / 600)
                love.graphics.setLineWidth(3)
                love.graphics.circle("line", obstacle.x, obstacle.y, obstacle.waveRadius)
                love.graphics.setColor(1, 1, 1)
            end
        end
    end
end

function DrawingTerrifying.drawGameWorld()
    -- Draw background and track as normal
    Drawing.drawGameWorld()
    
    -- Replace enemy drawing with new system
    love.graphics.push()
    love.graphics.translate(-State.camera.x, -State.camera.y)
    DrawingTerrifying.drawEnemies()
    Drawing.drawGondola()
    love.graphics.pop()
end

return DrawingTerrifying