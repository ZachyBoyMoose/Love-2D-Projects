local State = require('lib.state')
local Config = require('lib.config_terrifying')

local EnemiesTerrifying = {}

function EnemiesTerrifying.updateEnemies(dt)
    for _, enemy in ipairs(State.enemies) do
        enemy.timer = (enemy.timer or 0) + dt
        
        -- Update animation if enemy has one
        if enemy.animation then
            enemy.animation:update(dt)
        end
        
        -- DAMNED SOUL SWARM
        if enemy.type == "damned_souls" then
            enemy.animation = enemy.animation or Config.animations.damned_souls
            
            -- Swarm movement in sine wave pattern
            enemy.swarmAngle = (enemy.swarmAngle or 0) + dt * (enemy.swarmSpeed or 2.0)
            enemy.swarmX = enemy.x + math.sin(enemy.swarmAngle) * (enemy.swarmRadius or 100)
            enemy.swarmY = enemy.y + math.cos(enemy.swarmAngle * 0.7) * (enemy.swarmRadius or 100)
            
            -- Create soul vortex every few seconds
            if math.floor(enemy.timer) % 3 == 0 and not enemy.vortexActive then
                enemy.vortexActive = true
                enemy.vortexX = enemy.swarmX
                enemy.vortexY = enemy.swarmY
            elseif math.floor(enemy.timer) % 3 == 1 then
                enemy.vortexActive = false
            end
            
        -- INFERNAL GRASPER
        elseif enemy.type == "infernal_grasper" then
            enemy.animation = enemy.animation or Config.animations.infernal_grasper
            
            -- Emerge and grab pattern
            enemy.state = enemy.state or "hidden"
            enemy.grabTimer = (enemy.grabTimer or 0) - dt
            
            if enemy.state == "hidden" and enemy.grabTimer <= 0 then
                enemy.state = "emerging"
                enemy.emergeY = enemy.y
                enemy.targetY = enemy.y - (enemy.grabHeight or 150)
            elseif enemy.state == "emerging" then
                enemy.emergeY = enemy.emergeY - dt * 200
                if enemy.emergeY <= enemy.targetY then
                    enemy.state = "grabbing"
                    enemy.grabDuration = 1.5
                end
            elseif enemy.state == "grabbing" then
                enemy.grabDuration = enemy.grabDuration - dt
                -- Sweeping grab motion
                enemy.grabX = enemy.x + math.sin(enemy.timer * 5) * 30
                if enemy.grabDuration <= 0 then
                    enemy.state = "retracting"
                end
            elseif enemy.state == "retracting" then
                enemy.emergeY = enemy.emergeY + dt * 200
                if enemy.emergeY >= enemy.y then
                    enemy.state = "hidden"
                    enemy.grabTimer = enemy.grabInterval or 4.0
                end
            end
            
        -- FLAMING LEVIATHAN SKULL
        elseif enemy.type == "flaming_skull" then
            enemy.animation = enemy.animation or Config.animations.flaming_skull
            
            -- Patrol and breathe fire
            enemy.patrolX = enemy.x + math.sin(enemy.timer * (enemy.patrolSpeed or 1.0)) * (enemy.patrolRange or 200)
            
            -- Fire breath attack
            enemy.fireTimer = (enemy.fireTimer or 0) - dt
            if enemy.fireTimer <= 0 then
                enemy.breathing = true
                enemy.fireTimer = enemy.fireInterval or 4.0
                enemy.fireBlastX = enemy.patrolX
                enemy.fireBlastY = enemy.y
                enemy.fireBlastAnimation = Config.animations.fire_blast
                enemy.fireBlastAnimation:reset()
            end
            
            if enemy.breathing then
                enemy.fireBlastX = enemy.fireBlastX - dt * 300
                if enemy.fireBlastX < -200 then
                    enemy.breathing = false
                end
            end
            
        -- TENTACLED ABOMINATION
        elseif enemy.type == "tentacled_abomination" then
            enemy.animation = enemy.animation or Config.animations.tentacled_abomination
            
            -- Multiple tentacle strikes
            enemy.tentaclePhase = math.floor(enemy.timer * 0.5) % 3
            
            for i = 1, 3 do
                local tentacleKey = "tentacle" .. i
                enemy[tentacleKey .. "Angle"] = (enemy[tentacleKey .. "Angle"] or 0)
                
                if enemy.tentaclePhase == i - 1 then
                    -- Strike pattern
                    enemy[tentacleKey .. "Angle"] = math.sin(enemy.timer * 3) * math.pi / 3
                    enemy[tentacleKey .. "X"] = enemy.x + math.cos(enemy[tentacleKey .. "Angle"]) * 150
                    enemy[tentacleKey .. "Y"] = enemy.y + math.sin(enemy[tentacleKey .. "Angle"]) * 150
                    enemy[tentacleKey .. "Striking"] = true
                else
                    enemy[tentacleKey .. "Striking"] = false
                end
            end
            
        -- TORMENTOR DEMON
        elseif enemy.type == "tormentor_demon" then
            enemy.animation = enemy.animation or Config.animations.tormentor_demon
            
            -- Circular patrol with dive attacks
            enemy.patrolAngle = (enemy.patrolAngle or 0) + dt * (enemy.patrolSpeed or 1.5)
            
            if not enemy.diving then
                enemy.patrolX = enemy.x + math.cos(enemy.patrolAngle) * (enemy.patrolRadius or 150)
                enemy.patrolY = enemy.y + math.sin(enemy.patrolAngle) * (enemy.patrolRadius or 150) * 0.5
                
                -- Initiate dive
                enemy.diveTimer = (enemy.diveTimer or 0) - dt
                if enemy.diveTimer <= 0 then
                    enemy.diving = true
                    enemy.diveStartX = enemy.patrolX
                    enemy.diveStartY = enemy.patrolY
                    enemy.diveTargetX = State.gondola.x
                    enemy.diveTargetY = State.gondola.y
                    enemy.diveProgress = 0
                    enemy.diveTimer = enemy.diveInterval or 3.0
                end
            else
                -- Execute dive
                enemy.diveProgress = enemy.diveProgress + dt * 2
                local t = math.min(enemy.diveProgress, 1)
                enemy.patrolX = enemy.diveStartX + (enemy.diveTargetX - enemy.diveStartX) * t
                enemy.patrolY = enemy.diveStartY + (enemy.diveTargetY - enemy.diveStartY) * t
                
                if enemy.diveProgress >= 1 then
                    enemy.diving = false
                end
            end
            
        -- LAVA SERPENT
        elseif enemy.type == "lava_serpent" then
            enemy.animation = enemy.animation or Config.animations.lava_serpent
            
            -- Emerge from lava pools
            enemy.emergeTimer = (enemy.emergeTimer or 0) - dt
            
            if not enemy.emerged and enemy.emergeTimer <= 0 then
                enemy.emerged = true
                enemy.segments = {}
                -- Create serpent segments
                for i = 1, (enemy.segmentCount or 5) do
                    table.insert(enemy.segments, {
                        x = enemy.x + i * 30,
                        y = enemy.y + math.sin(i * 0.5) * 20,
                        animation = Config.animations.lava_serpent
                    })
                end
            elseif enemy.emerged then
                -- Undulating motion
                for i, segment in ipairs(enemy.segments) do
                    segment.y = enemy.y + math.sin(enemy.timer * 2 + i * 0.5) * 30
                    segment.x = enemy.x + i * 30 + math.cos(enemy.timer * 1.5 + i * 0.3) * 20
                end
                
                -- Retract after time
                if enemy.timer > (enemy.emergeDuration or 5.0) then
                    enemy.emerged = false
                    enemy.emergeTimer = enemy.emergeInterval or 3.0
                    enemy.timer = 0
                end
            end
        end
    end
    
    -- Update obstacles
    for _, obstacle in ipairs(State.obstacles) do
        obstacle.timer = (obstacle.timer or 0) + dt
        
        if obstacle.animation then
            obstacle.animation:update(dt)
        end
        
        -- BLOOD GEYSER
        if obstacle.type == "blood_geyser" then
            obstacle.animation = obstacle.animation or Config.animations.blood_geyser
            
            obstacle.eruptTimer = (obstacle.eruptTimer or 0) - dt
            if obstacle.eruptTimer <= 0 then
                obstacle.erupting = true
                obstacle.eruptTimer = obstacle.eruptInterval or 5.0
                obstacle.eruptDuration = 2.0
            end
            
            if obstacle.erupting then
                obstacle.eruptDuration = obstacle.eruptDuration - dt
                obstacle.sprayHeight = 100 * (1 - obstacle.eruptDuration / 2.0)
                if obstacle.eruptDuration <= 0 then
                    obstacle.erupting = false
                end
            end
            
        -- SOUL CHAIN
        elseif obstacle.type == "soul_chain" then
            obstacle.animation = obstacle.animation or Config.animations.soul_chain
            
            -- Pendulum swing
            obstacle.swingAngle = math.sin(obstacle.timer * (obstacle.swingSpeed or 2.0)) * (obstacle.swingArc or math.pi / 3)
            obstacle.chainX = obstacle.x + math.sin(obstacle.swingAngle) * (obstacle.chainLength or 100)
            obstacle.chainY = obstacle.y + math.cos(obstacle.swingAngle) * (obstacle.chainLength or 100)
            
        -- INFERNAL GATE
        elseif obstacle.type == "infernal_gate" then
            obstacle.animation = obstacle.animation or Config.animations.infernal_gate
            
            -- Timed opening/closing
            local cycleTime = (obstacle.openTime or 3.0) + (obstacle.closeTime or 4.0)
            local cyclePos = obstacle.timer % cycleTime
            
            if cyclePos < obstacle.openTime then
                obstacle.gateOpen = true
                obstacle.openAmount = math.min(cyclePos / 0.5, 1) -- 0.5 seconds to open
            else
                obstacle.gateOpen = false
                obstacle.openAmount = math.max(1 - (cyclePos - obstacle.openTime) / 0.5, 0)
            end
            
        -- SCREAMING PILLAR
        elseif obstacle.type == "screaming_pillar" then
            obstacle.animation = obstacle.animation or Config.animations.screaming_pillar
            
            -- Sonic wave emissions
            obstacle.screamTimer = (obstacle.screamTimer or 0) - dt
            if obstacle.screamTimer <= 0 then
                obstacle.screaming = true
                obstacle.screamTimer = obstacle.screamInterval or 4.0
                obstacle.waveX = obstacle.x
                obstacle.waveRadius = 0
            end
            
            if obstacle.screaming then
                obstacle.waveRadius = obstacle.waveRadius + dt * 200
                if obstacle.waveRadius > 300 then
                    obstacle.screaming = false
                end
            end
        end
    end
end

return EnemiesTerrifying