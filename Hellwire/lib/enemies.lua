local State = require('lib.state')

local Enemies = {}

function Enemies.updateEnemies(dt)
    for _, enemy in ipairs(State.enemies) do
        enemy.timer = (enemy.timer or 0) + dt
        
        if enemy.type == "spike" then
            if enemy.moveRange and enemy.moveRange > 0 then
                local moveDistance = math.sin(enemy.timer * (enemy.moveSpeed or 1)) * enemy.moveRange
                local moveAngle = enemy.moveAngle or enemy.angle
                enemy.currentX = enemy.x + math.cos(moveAngle) * moveDistance
                enemy.currentY = enemy.y + math.sin(moveAngle) * moveDistance
            else
                enemy.currentX = enemy.x
                enemy.currentY = enemy.y
            end

        elseif enemy.type == "fireball" then
            enemy.orbitAngle = (enemy.orbitAngle or 0) + dt * (enemy.speed or 1.5)
            enemy.orbX = enemy.x + math.cos(enemy.orbitAngle) * enemy.radius
            enemy.orbY = enemy.y + math.sin(enemy.orbitAngle) * enemy.radius
            
        elseif enemy.type == "swinger" then
            enemy.swingAngle = math.sin(enemy.timer * (enemy.speed or 2.0)) * math.pi / 3
            enemy.hazardX = enemy.x + math.sin(enemy.swingAngle) * enemy.amplitude
            enemy.hazardY = enemy.y + math.cos(enemy.swingAngle) * enemy.amplitude
            
        elseif enemy.type == "rotator" then
            enemy.rotation = enemy.timer * (enemy.speed or 2.0)
            
        elseif enemy.type == "acid_drop" or enemy.type == "lava_drop" then
            if enemy.isWaiting then
                enemy.waitTimer = enemy.waitTimer - dt
                if enemy.waitTimer <= 0 then
                    enemy.isWaiting = false
                end
            else
                enemy.dropY = (enemy.dropY or enemy.y) + (enemy.fallSpeed or 200) * dt
                if enemy.dropY > 800 then
                    enemy.dropY = enemy.y
                    enemy.isWaiting = true
                    enemy.waitTimer = 0.5
                end
            end
            
        elseif enemy.type == "bubble" then
             enemy.bubbleY = (enemy.bubbleY or enemy.y) - (enemy.riseSpeed or 100) * dt
             if enemy.bubbleY < -200 then
                enemy.bubbleY = enemy.y
             end
        
        elseif enemy.type == "guardian" then
            enemy.shootTimer = (enemy.shootTimer or 0) - dt
            if enemy.shootTimer <= 0 then
                enemy.shooting = true
                enemy.shootTimer = enemy.shootInterval or 2.0
                enemy.projectileX = enemy.x
                enemy.projectileY = enemy.y
            end
            if enemy.shooting then
                enemy.projectileX = (enemy.projectileX or enemy.x) - 300 * dt
                if enemy.projectileX < -50 then
                    enemy.shooting = false
                end
            end
            
        elseif enemy.type == "bone_throw" then
            enemy.throwTimer = (enemy.throwTimer or 0) - dt
            if enemy.throwTimer <= 0 then
                enemy.throwing = true
                enemy.throwTimer = enemy.throwInterval or 1.5
                enemy.boneY = enemy.y
                enemy.boneVel = -400
            end
            if enemy.throwing then
                enemy.boneVel = (enemy.boneVel or -400) + 600 * dt
                enemy.boneY = (enemy.boneY or enemy.y) + enemy.boneVel * dt
                if enemy.boneY > enemy.y then
                    enemy.throwing = false
                end
            end
            
        elseif enemy.type == "flesh_blob" then
            enemy.scale = 1 + math.sin(enemy.timer * (enemy.pulseSpeed or 3.0)) * 0.3
            
        elseif enemy.type == "cannon" then
            enemy.shootTimer = (enemy.shootTimer or 0) - dt
            if enemy.shootTimer <= 0 then
                enemy.shooting = true
                enemy.shootTimer = enemy.shootInterval or 2.5
                enemy.ballX = enemy.x
                enemy.ballY = enemy.y
            end
            if enemy.shooting then
                local speed = 250
                enemy.ballX = (enemy.ballX or enemy.x) + math.cos(enemy.angle) * speed * dt
                enemy.ballY = (enemy.ballY or enemy.y) + math.sin(enemy.angle) * speed * dt
                if enemy.ballX < -50 or enemy.ballX > 2500 or enemy.ballY < -50 or enemy.ballY > 1000 then
                    enemy.shooting = false
                end
            end
            
        elseif enemy.type == "boss_acid" then
            enemy.patternTimer = (enemy.patternTimer or 0) + dt
            if enemy.patternTimer > 8 then
                enemy.pattern = enemy.pattern == 1 and 2 or 1
                enemy.patternTimer = 0
            end
            if enemy.pattern == 1 then
                enemy.streamAngle = math.sin(enemy.timer) * math.pi / 2
            else
                enemy.streamAngle = math.cos(enemy.timer * 1.5) * math.pi / 3
            end
        elseif enemy.type == "boss_flesh" then
            enemy.patternTimer = (enemy.patternTimer or 0) + dt
            if enemy.patternTimer > 10 then
                enemy.pattern = enemy.pattern == 1 and 2 or 1
                enemy.patternTimer = 0
            end
            if enemy.pattern == 1 then
                enemy.tentacle1 = math.sin(enemy.timer * 1.5) * 150
                enemy.tentacle2 = math.sin(enemy.timer * 1.5 + math.pi) * 150
            else
                enemy.tentacle1 = math.sin(enemy.timer * 2.0) * 100
                enemy.tentacle2 = math.cos(enemy.timer * 2.0) * 100
            end
        elseif enemy.type == "boss_train" then
            enemy.patternTimer = (enemy.patternTimer or 0) + dt
            if enemy.patternTimer > 15 then
                enemy.pattern = enemy.pattern == 1 and 2 or 1
                enemy.patternTimer = 0
            end
            if enemy.pattern == 1 then
                enemy.x = enemy.x + (enemy.speed or 120) * dt
            else
                enemy.x = enemy.x + (enemy.speed or 120) * 1.5 * dt
            end
        end
    end
end

return Enemies