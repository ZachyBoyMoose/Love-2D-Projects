-- animation.lua (FIXED)
local Animation = {}

function Animation.new(framePaths, frameTime, loop)
    local anim = {
        frames = {},
        currentFrame = 1,
        timer = 0,
        frameTime = frameTime or 0.2,
        loop = loop ~= false,
        playing = true,
        onComplete = nil
    }
    
    -- Load all frames
    for i, path in ipairs(framePaths) do
        anim.frames[i] = love.graphics.newImage(path)
    end
    
    function anim:update(dt)
        if not self.playing then return end
        
        self.timer = self.timer + dt
        if self.timer >= self.frameTime then
            self.timer = self.timer - self.frameTime
            self.currentFrame = self.currentFrame + 1
            
            if self.currentFrame > #self.frames then
                if self.loop then
                    self.currentFrame = 1
                else
                    self.currentFrame = #self.frames
                    self.playing = false
                    if self.onComplete then
                        self.onComplete()
                    end
                end
            end
        end
    end
    
    function anim:draw(x, y, r, sx, sy, ox, oy)
        love.graphics.draw(self.frames[self.currentFrame], x, y, r or 0, sx or 1, sy or 1, ox or 0, oy or 0)
    end
    
    function anim:reset()
        self.currentFrame = 1
        self.timer = 0
        self.playing = true
    end
    
    function anim:setSpeed(speed)
        self.frameTime = speed
    end
    
    return anim
end

-- CRITICAL: Return the Animation module
return Animation