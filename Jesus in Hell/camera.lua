-- camera.lua
-- Final Fight style camera system
camera = {
    x = 0,
    y = 0,
    scale = 1.5,
    targetX = 0,
    targetY = 0,
    locked = false,
    shake = 0,
    shakeIntensity = 0,
    waveActive = false,
    waveStartX = 0,
    waveEndX = 0,
    smoothSpeed = 5,
}

function initCamera()
    camera.x = 0
    camera.y = getFloorHeight() - love.graphics.getHeight() / camera.scale + 50
    camera.scale = 1.5
    camera.targetX = 0
    camera.targetY = camera.y
    camera.locked = false
    camera.shake = 0
    camera.shakeIntensity = 0
    camera.waveActive = false
    camera.waveStartX = 0
    camera.waveEndX = 0
    camera.smoothSpeed = 5
end

function updateCamera(dt)
    -- Apply camera shake if active
    if camera.shake > 0 then
        camera.shake = camera.shake - dt
        local intensity = camera.shakeIntensity * (camera.shake / 0.5)
        
        -- Random shake offset
        local shakeX = love.math.random(-intensity, intensity)
        local shakeY = love.math.random(-intensity, intensity)
        
        camera.x = camera.x + shakeX
        camera.y = camera.y + shakeY
    else
        camera.shake = 0
        camera.shakeIntensity = 0
    end
    
    -- Smooth camera following when unlocked
    if not camera.locked then
        -- Follow player with some forward bias based on direction
        local forwardLook = 150
        local targetX = player.x - (love.graphics.getWidth() / camera.scale) / 2 + (player.direction * forwardLook)
        
        -- Keep camera focused on the floor level
        local targetY = getFloorHeight() - love.graphics.getHeight() / camera.scale + 50
        
        -- Clamp to stage bounds
        local maxX = getCurrentStageWidth() - love.graphics.getWidth() / camera.scale
        targetX = math.max(0, math.min(maxX, targetX))
        targetY = math.max(0, math.min(getFloorHeight() - 100, targetY))
        
        -- Smooth interpolation
        camera.targetX = targetX
        camera.targetY = targetY
        
        camera.x = camera.x + (camera.targetX - camera.x) * dt * camera.smoothSpeed
        camera.y = camera.y + (camera.targetY - camera.y) * dt * camera.smoothSpeed
    else
        -- When locked for wave, keep camera steady
        if camera.waveActive then
            -- Center on wave area
            local centerX = camera.waveStartX + (camera.waveEndX - camera.waveStartX) / 2
            camera.targetX = centerX - love.graphics.getWidth() / (2 * camera.scale)
            camera.x = camera.x + (camera.targetX - camera.x) * dt * 10
            
            -- Keep camera focused on the floor level during waves too
            camera.targetY = getFloorHeight() - love.graphics.getHeight() / camera.scale + 50
            camera.y = camera.y + (camera.targetY - camera.y) * dt * 10
        end
    end
end

function lockCameraForWave(startX, endX)
    camera.locked = true
    camera.waveActive = true
    camera.waveStartX = startX
    camera.waveEndX = endX
    
    -- Center camera on wave area
    local centerX = startX + (endX - startX) / 2
    camera.targetX = centerX - love.graphics.getWidth() / (2 * camera.scale)
end

function unlockCamera()
    camera.locked = false
    camera.waveActive = false
    camera.smoothSpeed = 5
end

function applyCameraTransform()
    love.graphics.push()
    love.graphics.scale(camera.scale, camera.scale)
    love.graphics.translate(-camera.x, -camera.y)
end

function resetCameraTransform()
    love.graphics.pop()
end

function getCameraX()
    return camera.x or 0
end

function getCameraY()
    return camera.y or 0
end

function getCameraScale()
    return camera.scale or 1.5
end

function isCameraLocked()
    return camera.locked or false
end

function isWaveActive()
    return camera.waveActive or false
end

function triggerCameraShake(intensity, duration)
    camera.shake = duration or 0.5
    camera.shakeIntensity = intensity or 5
end

-- Check if position is visible on screen
function isOnScreen(x, y, width, height)
    width = width or 0
    height = height or 0
    
    local screenX = x - camera.x
    local screenY = y - camera.y
    local screenWidth = love.graphics.getWidth() / camera.scale
    local screenHeight = love.graphics.getHeight() / camera.scale
    
    return screenX + width > 0 and 
           screenX < screenWidth and
           screenY + height > 0 and 
           screenY < screenHeight
end

-- Get screen bounds for spawning enemies
function getCameraScreenBounds()
    return {
        left = camera.x,
        right = camera.x + love.graphics.getWidth() / camera.scale,
        top = camera.y,
        bottom = camera.y + love.graphics.getHeight() / camera.scale
    }
end

-- Focus camera on specific point
function focusCamera(x, y, instant)
    camera.targetX = x - love.graphics.getWidth() / (2 * camera.scale)
    camera.targetY = y - love.graphics.getHeight() / (2 * camera.scale)
    
    if instant then
        camera.x = camera.targetX
        camera.y = camera.targetY
    end
end

-- Set camera bounds for scrolling
function setCameraBounds(minX, maxX, minY, maxY)
    camera.minX = minX or 0
    camera.maxX = maxX or getCurrentStageWidth()
    camera.minY = minY or -100
    camera.maxY = maxY or 100
end

-- Cinematic camera movements
function startCinematic()
    camera.locked = true
    camera.cinematicMode = true
    camera.smoothSpeed = 2
end

function endCinematic()
    camera.locked = false
    camera.cinematicMode = false
    camera.smoothSpeed = 5
end