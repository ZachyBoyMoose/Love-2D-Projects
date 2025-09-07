-- state.lua (FIXED)
local State = {}
State.gameState = "title"
State.currentLevel = 1
State.levelTimer = 0
State.souls = 3
State.maxSouls = 3
State.levels = {}
State.tracks = {}
State.trackSegments = {}
State.enemies = {}
State.obstacles = {}  -- Add obstacles array

State.gondola = {
    trackIndex = 1,
    trackPosition = 0,
    speed = 0,
    maxSpeed = 250,
    acceleration = 180,
    brakeForce = 240,
    gravity = 100,
    x = 0,
    y = 0,
    cableLength = 40,
    swingAngle = 0,
    swingVelocity = 0,
    width = 30,
    height = 25,
    invulnerable = false,
    invulnerableTime = 0
}

function State.buildTrackSegments()
    State.trackSegments = {}
    local track = State.tracks
    
    for i = 1, #track - 1 do
        local x1, y1 = track[i][1], track[i][2]
        local x2, y2 = track[i + 1][1], track[i + 1][2]
        local dx = x2 - x1
        local dy = y2 - y1
        local length = math.sqrt(dx * dx + dy * dy)
        local angle = math.atan2(dy, dx)
        
        table.insert(State.trackSegments, {
            x1 = x1, y1 = y1,
            x2 = x2, y2 = y2,
            length = length,
            angle = angle,
            dx = dx, dy = dy
        })
    end
end

function State.getTrackPosition(index, t)
    if index > #State.trackSegments then
        if #State.tracks > 0 then
            local lastPoint = State.tracks[#State.tracks]
            return lastPoint[1], lastPoint[2], 0
        end
        return 0,0,0
    end
    
    local segment = State.trackSegments[index]
    local x = segment.x1 + segment.dx * t
    local y = segment.y1 + segment.dy * t
    return x, y, segment.angle
end

function State.takeDamage()
    if State.gondola.invulnerable then return end
    State.souls = State.souls - 1
    State.gondola.invulnerable = true
    State.gondola.invulnerableTime = 1.5
    
    if State.souls <= 0 then
        State.gameState = "gameOver"
    end
end

function State.loadLevel(n)
    State.currentLevel = n
    local level = State.levels[n]
    
    if not level then return end
    
    State.tracks = level.track
    State.buildTrackSegments()
    
    State.gondola.trackIndex = 1
    State.gondola.trackPosition = 0
    State.gondola.speed = 0
    State.gondola.x = State.tracks[1][1]
    State.gondola.y = State.tracks[1][2]
    State.gondola.swingAngle = 0
    State.gondola.swingVelocity = 0
    State.gondola.invulnerable = false
    State.gondola.invulnerableTime = 0
    
    -- Initialize enemies
    State.enemies = {}
    if level.enemies then
        for _, enemyData in ipairs(level.enemies) do
            local enemy = {}
            for k, v in pairs(enemyData) do 
                enemy[k] = v 
            end
            -- Initialize timers for new enemy types
            enemy.timer = 0
            enemy.animation = nil  -- Will be set by the update function
            table.insert(State.enemies, enemy)
        end
    end
    
    -- Initialize obstacles (NEW)
    State.obstacles = {}
    if level.obstacles then
        for _, obstacleData in ipairs(level.obstacles) do
            local obstacle = {}
            for k, v in pairs(obstacleData) do 
                obstacle[k] = v 
            end
            -- Initialize timers for obstacles
            obstacle.timer = 0
            obstacle.animation = nil  -- Will be set by the update function
            table.insert(State.obstacles, obstacle)
        end
    end

    State.souls = State.maxSouls
    State.levelTimer = 0
    State.gameState = "playing"
end

return State