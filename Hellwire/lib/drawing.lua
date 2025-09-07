local Config = require('lib.config')
local State = require('lib.state')

local Drawing = {}

function Drawing.drawTrack()
    love.graphics.setColor(0.5, 0.4, 0.4)
    love.graphics.setLineWidth(6)
    for i = 1, #State.tracks - 1 do
        love.graphics.line(State.tracks[i][1], State.tracks[i][2], State.tracks[i + 1][1], State.tracks[i + 1][2])
    end
    
    love.graphics.setColor(0.3, 0.2, 0.2)
    love.graphics.setLineWidth(2)
    for i = 1, #State.tracks do
        love.graphics.circle("fill", State.tracks[i][1], State.tracks[i][2], 4)
    end
    love.graphics.setColor(1,1,1)
end

function Drawing.drawGondola()
    local hangX = State.gondola.x + math.sin(State.gondola.swingAngle) * State.gondola.cableLength
    local hangY = State.gondola.y + math.cos(State.gondola.swingAngle) * State.gondola.cableLength
    
    if Config.assets.cable_chain_tile then
        local cableAngle = math.atan2(hangY - State.gondola.y, hangX - State.gondola.x) - math.pi/2
        local cableLength = math.sqrt((hangX - State.gondola.x)^2 + (hangY - State.gondola.y)^2)
        love.graphics.draw(Config.assets.cable_chain_tile, State.gondola.x, State.gondola.y, cableAngle, 1, cableLength / 16, 2, 0)
    end
    
    if State.gondola.invulnerable and math.floor(State.gondola.invulnerableTime * 10) % 2 == 0 then
        love.graphics.setColor(1, 1, 1, 0.5)
    else
        love.graphics.setColor(1, 1, 1)
    end

    if Config.assets.gondola then
        love.graphics.draw(Config.assets.gondola, hangX, hangY, State.gondola.swingAngle * 0.5, 1, 1, 15, 12.5)
    end
    
    if Config.assets.soul_icon then
        for i = 1, State.souls do
            local soulX = -10 + (i - 1) * 10
            local soulY = 5
            love.graphics.draw(Config.assets.soul_icon, hangX + soulX, hangY + soulY)
        end
    end
    
    if Config.assets.track_hitch then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(Config.assets.track_hitch, State.gondola.x, State.gondola.y, 0, 1, 1, 5, 5)
    end

    love.graphics.setColor(1,1,1)
end

function Drawing.drawEnemies()
    love.graphics.setColor(1, 1, 1)

    for _, enemy in ipairs(State.enemies) do
        if enemy.type == "spike" and Config.assets.enemy_spike then
            local currentX = enemy.currentX or enemy.x
            local currentY = enemy.currentY or enemy.y
            love.graphics.draw(Config.assets.enemy_spike, currentX, currentY, enemy.angle + math.pi/2, 1, 1, 15, 22.5)

        elseif enemy.type == "fireball" and Config.assets.enemy_fireball and enemy.orbX then
            love.graphics.draw(Config.assets.enemy_fireball, enemy.orbX, enemy.orbY, 0, 1, 1, 15, 15)
            
        elseif enemy.type == "swinger" and Config.assets.enemy_swinger_hazard and enemy.hazardX then
            love.graphics.setColor(0.4, 0.4, 0.4); love.graphics.setLineWidth(3)
            love.graphics.line(enemy.x, enemy.y, enemy.hazardX, enemy.hazardY)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(Config.assets.enemy_swinger_hazard, enemy.hazardX, enemy.hazardY, 0, 1, 1, 20, 20)
            
        elseif enemy.type == "rotator" and Config.assets.enemy_rotator_endpoint then
            local beam1X = enemy.x + math.cos(enemy.rotation) * enemy.radius
            local beam1Y = enemy.y + math.sin(enemy.rotation) * enemy.radius
            local beam2X = enemy.x - math.cos(enemy.rotation) * enemy.radius
            local beam2Y = enemy.y - math.sin(enemy.rotation) * enemy.radius
            love.graphics.setColor(0.6, 0.6, 0.7); love.graphics.setLineWidth(8)
            love.graphics.line(beam2X, beam2Y, beam1X, beam1Y)
            love.graphics.setColor(1,1,1)
            love.graphics.draw(Config.assets.enemy_rotator_endpoint, beam1X, beam1Y, 0, 1, 1, 12, 12)
            love.graphics.draw(Config.assets.enemy_rotator_endpoint, beam2X, beam2Y, 0, 1, 1, 12, 12)
            
        elseif enemy.type == "acid_drop" and Config.assets.enemy_acid_drop and enemy.dropY then
            love.graphics.draw(Config.assets.enemy_acid_drop, enemy.x, enemy.dropY, 0, 1, 1, 10, 10)
            
        elseif enemy.type == "lava_drop" and Config.assets.enemy_lava_drop and enemy.dropY then
            love.graphics.draw(Config.assets.enemy_lava_drop, enemy.x, enemy.dropY, 0, 1, 1, 10, 10)
            
        elseif enemy.type == "bubble" and Config.assets.enemy_bubble and enemy.bubbleY then
            love.graphics.draw(Config.assets.enemy_bubble, enemy.x, enemy.bubbleY, 0, 1, 1, 20, 20)
            
        elseif enemy.type == "guardian" and Config.assets.enemy_guardian then
            love.graphics.draw(Config.assets.enemy_guardian, enemy.x, enemy.y, 0, 1, 1, 25, 25)
            if enemy.shooting and enemy.projectileX and Config.assets.enemy_guardian_projectile then
                love.graphics.draw(Config.assets.enemy_guardian_projectile, enemy.projectileX, enemy.projectileY, 0, 1, 1, 10, 10)
            end
            
        elseif enemy.type == "bone_throw" and Config.assets.enemy_bone_thrower then
            love.graphics.draw(Config.assets.enemy_bone_thrower, enemy.x, enemy.y, 0, 1, 1, 15, 20)
            if enemy.throwing and enemy.boneY and Config.assets.enemy_bone_projectile then
                love.graphics.draw(Config.assets.enemy_bone_projectile, enemy.x, enemy.boneY, 0, 1, 1, 5, 10)
            end
            
        elseif enemy.type == "flesh_blob" and Config.assets.enemy_flesh_blob then
            local scale = enemy.scale or 1
            love.graphics.draw(Config.assets.enemy_flesh_blob, enemy.x, enemy.y, 0, scale, scale, 20, 20)
            
        elseif enemy.type == "cannon" and Config.assets.enemy_cannon then
            love.graphics.draw(Config.assets.enemy_cannon, enemy.x, enemy.y, enemy.angle, 1, 1, 15, 15)
            if enemy.shooting and enemy.ballX and Config.assets.enemy_cannonball then
                love.graphics.draw(Config.assets.enemy_cannonball, enemy.ballX, enemy.ballY, 0, 1, 1, 8, 8)
            end
            
        elseif enemy.type == "boss_acid" and Config.assets.boss_acid_lord then
            love.graphics.draw(Config.assets.boss_acid_lord, enemy.x, enemy.y, 0, 1, 1, 60, 60)
            if enemy.streamAngle then
                love.graphics.setColor(0.4, 0.8, 0.2); love.graphics.setLineWidth(15)
                local streamX = enemy.x + math.cos(enemy.streamAngle) * 200
                local streamY = enemy.y + math.sin(enemy.streamAngle) * 200
                love.graphics.line(enemy.x, enemy.y + 30, streamX, streamY)
                love.graphics.setColor(1,1,1)
            end
        elseif enemy.type == "boss_flesh" and Config.assets.boss_flesh_colossus then
            love.graphics.draw(Config.assets.boss_flesh_colossus, enemy.x, enemy.y, 0, 1, 1, 70, 70)
            if enemy.tentacle1 and Config.assets.boss_flesh_tentacle then
                love.graphics.draw(Config.assets.boss_flesh_tentacle, enemy.x - 80, enemy.y + enemy.tentacle1, 0, 1, 1, 30, 60)
                love.graphics.draw(Config.assets.boss_flesh_tentacle, enemy.x + 80, enemy.y + enemy.tentacle2, 0, 1, 1, 30, 60)
            end
        elseif enemy.type == "boss_train" and Config.assets.boss_hell_train then
            love.graphics.draw(Config.assets.boss_hell_train, enemy.x, enemy.y, 0, 1, 1, 100, 40)
            for i = 1, 3 do
                love.graphics.setColor(0.4, 0.4, 0.4, 0.5)
                love.graphics.circle("fill", enemy.x - 120 - i * 30, enemy.y - 40, 15 + i * 5)
            end
            love.graphics.setColor(1,1,1)
        end
    end
end

function Drawing.drawGameWorld()
    local world_num = math.floor((State.currentLevel - 1) / 5) + 1
    local bg_key
    if world_num == 1 then bg_key = "bg_world_1_charred"
    elseif world_num == 2 then bg_key = "bg_world_2_toxic"
    elseif world_num == 3 then bg_key = "bg_world_3_skeletal"
    elseif world_num == 4 then bg_key = "bg_world_4_visceral"
    elseif world_num == 5 then bg_key = "bg_world_5_industrial"
    elseif world_num == 6 then bg_key = "bg_world_6_oblivion"
    end

    if Config.assets[bg_key] then
        love.graphics.draw(Config.assets[bg_key], 0, 0)
    end

    love.graphics.push()
    love.graphics.translate(-State.camera.x, -State.camera.y)
    Drawing.drawTrack()
    Drawing.drawEnemies()
    Drawing.drawGondola()
    love.graphics.pop()
end

return Drawing