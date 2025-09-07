-- buildings/guilds.lua - Enhanced guild system with tech tree progression
local Building = require('buildings/building')
local Guilds = {}

-- Tech tree progression order
Guilds.techTree = {
    {id = "indica_knight_guild", name = "Indica Knight Guild", tier = 1, requires = nil},
    {id = "gnome_chomper_guild", name = "Gnome Chompers' Mine", tier = 2, requires = "indica_knight_guild"},
    {id = "dabbler_guild", name = "Dabblers' Den", tier = 3, requires = "gnome_chomper_guild"},
    {id = "sativa_scout_guild", name = "Sativa Scout Post", tier = 4, requires = "dabbler_guild"},
    {id = "joint_roller_guild", name = "Joint Rollers' Circle", tier = 5, requires = "sativa_scout_guild"},
    {id = "psilocyber_guild", name = "Enlightened Ents Lodge", tier = 6, requires = "joint_roller_guild"},
    {id = "high_priest_guild", name = "Temple of the High Priest", tier = 7, requires = "psilocyber_guild"}
}

function Guilds.checkPrerequisites(guildType)
    local game = require('game')
    
    -- Find this guild in tech tree
    local guildInfo = nil
    for _, info in ipairs(Guilds.techTree) do
        if info.id == guildType then
            guildInfo = info
            break
        end
    end
    
    if not guildInfo then
        return false, "Unknown guild type"
    end
    
    -- Check if prerequisite exists and is fully upgraded
    if guildInfo.requires then
        local hasPrereq = false
        local prereqFullyUpgraded = false
        
        for _, building in ipairs(game.getBuildings()) do
            if building.type == guildInfo.requires and building.isBuilt and not building.isDestroyed then
                hasPrereq = true
                if building.level and building.level >= 3 then  -- Assume level 3 is max
                    prereqFullyUpgraded = true
                    break
                end
            end
        end
        
        if not hasPrereq then
            -- Find the prerequisite name
            local prereqName = guildInfo.requires
            for _, info in ipairs(Guilds.techTree) do
                if info.id == guildInfo.requires then
                    prereqName = info.name
                    break
                end
            end
            return false, "Requires " .. prereqName .. " to be built first"
        elseif not prereqFullyUpgraded then
            local prereqName = guildInfo.requires
            for _, info in ipairs(Guilds.techTree) do
                if info.id == guildInfo.requires then
                    prereqName = info.name
                    break
                end
            end
            return false, "Requires " .. prereqName .. " to be fully upgraded (Level 3)"
        end
    end
    
    return true, ""
end

function Guilds.createGuild(x, y, color, guildType, heroClass, cost)
    local guild = Building.new(x, y, 45, 45, color, guildType)
    guild.cost = cost or 200
    guild.spawnTimer = 0
    guild.spawnInterval = 45
    guild.maxHeroes = 2
    guild.currentHeroes = 0
    guild.housedHeroes = {}
    guild.recruitCost = 100
    guild.upgradeCost = 300
    guild.level = 1
    guild.maxLevel = 3
    guild.heroClass = heroClass
    
    -- Find tier for this guild
    guild.tier = 1
    for _, info in ipairs(Guilds.techTree) do
        if info.id == guildType then
            guild.tier = info.tier
            break
        end
    end
    
    guild.update = function(self, dt)
        -- Can't function if destroyed
        if not self:canFunction() then
            return
        end
        
        -- Track heroes that belong to this guild
        self.housedHeroes = {}
        self.currentHeroes = 0
        
        for _, hero in ipairs(require('game').getHeroes()) do
            if hero.homeGuild == self then
                table.insert(self.housedHeroes, hero)
                self.currentHeroes = self.currentHeroes + 1
                
                -- Heal heroes resting at guild
                if hero.state == "resting" and hero:distanceTo(self) < 50 then
                    hero.hp = math.min(hero.hp + 15 * dt, hero.maxHp)
                    hero.focus = math.min(hero.focus + 25 * dt, hero.maxFocus)
                end
            end
        end
        
        -- Auto-spawn timer (free heroes occasionally)
        self.spawnTimer = self.spawnTimer + dt
        if self.spawnTimer >= self.spawnInterval then
            self.spawnTimer = 0
            
            -- Only spawn if under capacity and have enough funds
            if self.currentHeroes < self.maxHeroes then
                local game = require('game')
                if game.kushCoins >= 50 then
                    game.kushCoins = game.kushCoins - 50
                    self:spawnHero()
                end
            end
        end
        
        -- Update recruitment progress
        Building.update(self, dt)
    end
    
    guild.spawnHero = function(self)
        if not self:canFunction() then
            require('game'):addMessage("Cannot recruit - guild is destroyed!")
            return
        end
        
        local hero = self.heroClass.new(
            self.x + love.math.random(-30, 30),
            self.y + love.math.random(-30, 30)
        )
        hero.homeGuild = self
        
        -- Adjust hero stats based on guild level
        hero.attackPower = hero.attackPower * (1 + (self.level - 1) * 0.2)
        hero.defense = hero.defense * (1 + (self.level - 1) * 0.2)
        hero.maxHp = hero.maxHp * (1 + (self.level - 1) * 0.3)
        hero.hp = hero.maxHp
        
        require('game').addHero(hero)
        self.currentHeroes = self.currentHeroes + 1
    end
    
    guild.recruit = function(self)
        if not self:canFunction() then
            require('game'):addMessage("Cannot recruit - guild is destroyed!")
            return false
        end
        
        if self.currentHeroes < self.maxHeroes and require('game').spendCoins(self.recruitCost) then
            -- Start recruitment timer
            self:startRecruitment()
            require('game'):addMessage("Recruiting new hero from " .. self.type)
            return true
        else
            if self.currentHeroes >= self.maxHeroes then
                require('game'):addMessage("Guild is at max capacity! Upgrade to recruit more.")
            else
                require('game'):addMessage("Not enough Kush Coins!")
            end
            return false
        end
    end
    
    guild.completeRecruitment = function(self)
        self:spawnHero()
    end
    
    guild.upgrade = function(self)
        if not self:canFunction() then
            require('game'):addMessage("Cannot upgrade - guild is destroyed!")
            return false
        end
        
        if self.level >= self.maxLevel then
            require('game'):addMessage("Guild is already at maximum level!")
            return false
        end
        
        if require('game').spendCoins(self.upgradeCost) then
            -- Start upgrade timer
            self:startUpgrade()
            require('game'):addMessage("Upgrading " .. self.type)
            return true
        else
            require('game'):addMessage("Not enough Kush Coins for upgrade!")
            return false
        end
    end
    
    guild.completeUpgrade = function(self)
        self.level = self.level + 1
        self.maxHeroes = self.maxHeroes + 2
        self.upgradeCost = math.floor(self.upgradeCost * 1.8)
        self.recruitCost = math.floor(self.recruitCost * 1.3)
        
        -- Improve stats of existing heroes from this guild
        for _, hero in ipairs(self.housedHeroes) do
            hero.attackPower = hero.attackPower * 1.15
            hero.defense = hero.defense * 1.15
            hero.maxHp = hero.maxHp * 1.2
            hero.maxFocus = hero.maxFocus * 1.1
            hero.hp = hero.maxHp
            hero.focus = hero.maxFocus
        end
        
        require('game'):addMessage(self.type .. " upgraded to level " .. self.level .. "!")
        
        -- Check if this unlocks new buildings
        if self.level >= self.maxLevel then
            local unlockedBuilding = nil
            for _, info in ipairs(Guilds.techTree) do
                if info.requires == self.type then
                    unlockedBuilding = info.name
                    break
                end
            end
            
            if unlockedBuilding then
                require('game'):addMessage(unlockedBuilding .. " is now available to build!")
            end
        end
    end
    
    guild.draw = function(self)
        -- Draw building
        Building.draw(self)
        
        if not self.isDestroyed then
            -- Draw guild banner
            love.graphics.setColor(self.color[1] * 0.8, self.color[2] * 0.8, self.color[3] * 0.8)
            love.graphics.rectangle("fill", self.x - 5, self.y - self.height/2 - 15, 10, 10)
            
            -- Draw tier indicator
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(love.graphics.newFont(10))
            love.graphics.print("T" .. self.tier, self.x - 25, self.y - self.height/2 - 15)
            
            -- Draw hero count indicator
            love.graphics.print(self.currentHeroes .. "/" .. self.maxHeroes, self.x - 10, self.y + self.height/2 + 5)
            
            -- Draw level stars
            love.graphics.setColor(1, 1, 0)
            for i = 1, math.min(self.level, 3) do
                love.graphics.print("★", self.x - 15 + i * 8, self.y - self.height/2 - 25)
            end
            
            -- Draw max level indicator
            if self.level >= self.maxLevel then
                love.graphics.setColor(0, 1, 0)
                love.graphics.setFont(love.graphics.newFont(8))
                love.graphics.print("MAX", self.x + 15, self.y - self.height/2 - 25)
            end
            
            -- Draw heroes inside indicator
            local heroesInside = 0
            for _, hero in ipairs(self.housedHeroes) do
                if hero:distanceTo(self) < 40 then
                    heroesInside = heroesInside + 1
                end
            end
            
            if heroesInside > 0 then
                love.graphics.setColor(0, 1, 0, 0.5)
                love.graphics.circle("line", self.x, self.y, self.width/2 + 5 + heroesInside * 2)
            end
        end
    end
    
    return guild
end

-- All 7 Guild Types with proper tier costs
function Guilds.IndicaKnightGuild(x, y)
    local IndicaKnight = require('heroes/indica_knight')
    return Guilds.createGuild(x, y, {0.2, 0.5, 0.2}, "indica_knight_guild", IndicaKnight, 200)
end

function Guilds.GnomeChomperGuild(x, y)
    local GnomeChomper = require('heroes/gnome_chomper')
    return Guilds.createGuild(x, y, {0.4, 0.3, 0.2}, "gnome_chomper_guild", GnomeChomper, 300)
end

function Guilds.DabblerGuild(x, y)
    local Dabbler = require('heroes/dabbler')
    return Guilds.createGuild(x, y, {0.5, 0.5, 0.5}, "dabbler_guild", Dabbler, 400)
end

function Guilds.SativaScoutGuild(x, y)
    local SativaScout = require('heroes/sativa_scout')
    return Guilds.createGuild(x, y, {0.6, 0.9, 0.4}, "sativa_scout_guild", SativaScout, 500)
end

function Guilds.JointRollerGuild(x, y)
    local JointRoller = require('heroes/joint_roller')
    return Guilds.createGuild(x, y, {0.8, 0.7, 0.6}, "joint_roller_guild", JointRoller, 600)
end

function Guilds.PsilocyberStonerGuild(x, y)
    local PsilocyberStoner = require('heroes/psilocyber_stoner')
    return Guilds.createGuild(x, y, {0.7, 0.3, 0.9}, "psilocyber_guild", PsilocyberStoner, 700)
end

function Guilds.HighPriestGuild(x, y)
    local HighPriest = require('heroes/high_priest')
    return Guilds.createGuild(x, y, {1, 1, 1}, "high_priest_guild", HighPriest, 800)
end

return Guilds