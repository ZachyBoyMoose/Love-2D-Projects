local State = require('lib.state')

local Player = {}

function Player.updateGondola(dt)
    local accel = 0
    if love.keyboard.isDown("up") then
        accel = State.gondola.acceleration
    elseif love.keyboard.isDown("down") then
        accel = -State.gondola.brakeForce
    end
    
    if State.gondola.trackIndex <= #State.trackSegments then
        local segment = State.trackSegments[State.gondola.trackIndex]
        local slopeForce = math.sin(segment.angle) * State.gondola.gravity
        accel = accel - slopeForce
    end
    
    State.gondola.speed = State.gondola.speed + accel * dt
    State.gondola.speed = math.max(-State.gondola.maxSpeed/2, math.min(State.gondola.maxSpeed, State.gondola.speed))
    State.gondola.speed = State.gondola.speed * 0.985
    
    if State.gondola.trackIndex <= #State.trackSegments then
        local segment = State.trackSegments[State.gondola.trackIndex]
        if segment.length > 0 then
            local distance = State.gondola.speed * dt
            State.gondola.trackPosition = State.gondola.trackPosition + distance / segment.length
        end
        
        while State.gondola.trackPosition >= 1 and State.gondola.trackIndex < #State.trackSegments do
            State.gondola.trackPosition = State.gondola.trackPosition - 1
            State.gondola.trackIndex = State.gondola.trackIndex + 1
            if State.gondola.trackIndex <= #State.trackSegments then
                local prev_segment = State.trackSegments[State.gondola.trackIndex - 1]
                segment = State.trackSegments[State.gondola.trackIndex]
                if segment.length > 0 then
                    State.gondola.trackPosition = State.gondola.trackPosition * (prev_segment.length / segment.length)
                else
                    State.gondola.trackPosition = 0
                end
            end
        end
        
        while State.gondola.trackPosition < 0 and State.gondola.trackIndex > 1 do
            State.gondola.trackIndex = State.gondola.trackIndex - 1
            local next_segment = State.trackSegments[State.gondola.trackIndex + 1]
            segment = State.trackSegments[State.gondola.trackIndex]
            if segment.length > 0 then
                State.gondola.trackPosition = 1 + State.gondola.trackPosition * (next_segment.length / segment.length)
            else
                State.gondola.trackPosition = 0
            end
        end
        
        State.gondola.trackPosition = math.max(0, math.min(1, State.gondola.trackPosition))
        
        if State.gondola.trackIndex >= #State.trackSegments and State.gondola.trackPosition >= 1 then
            State.gameState = "levelComplete"
        end
    end
    
    State.gondola.x, State.gondola.y, State.gondola.angle = State.getTrackPosition(State.gondola.trackIndex, State.gondola.trackPosition)
    
    if love.keyboard.isDown("left") then
        State.gondola.swingVelocity = State.gondola.swingVelocity - dt * 4
    elseif love.keyboard.isDown("right") then
        State.gondola.swingVelocity = State.gondola.swingVelocity + dt * 4
    end

    local targetSwing = -State.gondola.speed * 0.001
    if State.gondola.angle then
        targetSwing = targetSwing - math.sin(State.gondola.angle) * 0.2
    end
    
    State.gondola.swingVelocity = State.gondola.swingVelocity * 0.95 + (targetSwing - State.gondola.swingAngle) * 0.2
    State.gondola.swingAngle = State.gondola.swingAngle + State.gondola.swingVelocity * dt * 10
    State.gondola.swingAngle = math.max(-math.pi/4, math.min(math.pi/4, State.gondola.swingAngle))
    
    if State.gondola.invulnerable then
        State.gondola.invulnerableTime = State.gondola.invulnerableTime - dt
        if State.gondola.invulnerableTime <= 0 then
            State.gondola.invulnerable = false
        end
    end
end

return Player