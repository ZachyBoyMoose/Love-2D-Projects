-- weapon.lua
-- Weapon pickups and management
weapons = {}

local weaponTypes = {
    thorned_knuckle = {
        width = 25,
        height = 20,
        damage = 15,
        uses = 20,
        range = 65,
        color = {0.5, 0.3, 0.2},
        icon = "knuckle"
    },
    holy_staff = {
        width = 50,
        height = 15,
        damage = 20,
        uses = 15,
        range = 90,
        color = {0.8, 0.6, 0.3},
        icon = "staff"
    },
    blessed_chain = {
        width = 40,
        height = 20,
        damage = 18,
        uses = 25,
        range = 100,
        color = {0.7, 0.7, 0.7},
        icon = "chain"
    }
}

function initWeapons()
    weapons = {}
end

function createGroundWeapon(type, x, y, uses)
    local def = weaponTypes[type]
    if not def then return end
    
    local weapon = {
        type = type,
        x = x,
        y = y,
        width = def.width,
        height = def.height,
        uses = uses or def.uses,
        onGround = true,
        timer = 0
    }
    
    for k, v in pairs(def) do
        if not weapon[k] then
            weapon[k] = v
        end
    end
    
    table.insert(weapons, weapon)
    return weapon
end

function updateWeapons(dt)
    for i = #weapons, 1, -1 do
        local weapon = weapons[i]
        
        weapon.timer = weapon.timer + dt
        
        -- Remove after time
        if weapon.timer > 20 then
            table.remove(weapons, i)
        end
    end
end

function drawGroundWeapons()
    for _, weapon in ipairs(weapons) do
        if weapon.onGround then
            love.graphics.push()
            love.graphics.translate(weapon.x, weapon.y)
            
            -- Glow effect
            local glow = 0.5 + math.sin(weapon.timer * 3) * 0.3
            love.graphics.setColor(1, 1, 0, glow * 0.3)
            love.graphics.rectangle("fill", -5, -5, weapon.width + 10, weapon.height + 10)
            
            -- Draw weapon
            love.graphics.setColor(weapon.color)
            
            if weapon.icon == "knuckle" then
                -- Thorned knuckle
                love.graphics.rectangle("fill", 0, 0, weapon.width, weapon.height)
                love.graphics.setColor(0.7, 0.7, 0.7)
                for i = 0, 3 do
                    love.graphics.polygon("fill",
                        5 + i * 5, 0,
                        7 + i * 5, -3,
                        9 + i * 5, 0
                    )
                end
                
            elseif weapon.icon == "staff" then
                -- Holy staff
                love.graphics.rectangle("fill", 0, weapon.height/2 - 2, weapon.width - 10, 4)
                -- Cross at end
                love.graphics.setColor(1, 1, 0)
                love.graphics.rectangle("fill", weapon.width - 10, 0, 3, weapon.height)
                love.graphics.rectangle("fill", weapon.width - 15, weapon.height/2 - 1, 13, 3)
                
            elseif weapon.icon == "chain" then
                -- Blessed chain
                for i = 0, 5 do
                    love.graphics.circle("line", i * 7, weapon.height/2, 4)
                end
                -- Holy symbol
                love.graphics.setColor(1, 1, 0)
                love.graphics.circle("fill", weapon.width - 5, weapon.height/2, 3)
            end
            
            -- Flash when about to disappear
            if weapon.timer > 17 then
                if math.floor(weapon.timer * 8) % 2 == 0 then
                    love.graphics.setColor(1, 1, 1, 0.5)
                    love.graphics.rectangle("fill", 0, 0, weapon.width, weapon.height)
                end
            end
            
            love.graphics.pop()
        end
    end
end