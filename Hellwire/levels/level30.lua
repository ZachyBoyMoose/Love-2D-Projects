-- level30.lua (FIXED)
return {
    name = "BOSS: Satan's Train to Oblivion",
    track = {
        {100,400}, {200,380}, {300,360}, {400,340}, {500,320}, {600,300},
        {700,280}, {800,260}, {900,240}, {1000,220}, {1100,200}, {1200,180},
        {1300,160}, {1400,140}, {1500,120}, {1600,100}, {1700,100}, {1800,120},
        {1900,140}, {2000,160}, {2100,180}, {2200,200}, {2300,220}, {2400,240},
        {2500,260}, {2600,280}, {2700,300}, {2800,320}, {2900,340}, {3000,360},
        {3100,380}, {3200,400}, {3300,420}, {3400,440}, {3500,460}, {3600,480},
        {3700,500}, {3800,520}, {3900,540}, {4000,560}, {4100,580}, {4200,600}
    },
    enemies = {
        -- FINAL BOSS: All enemy types in ultimate formation
        -- The Satan Train (represented as massive lava serpent)
        {type = "lava_serpent", x = -300, y = 450, segmentCount = 15, speed = 180},
        
        -- Wave 1: Initial assault
        {type = "flaming_skull", x = 600, y = 300, patrolRange = 600, patrolSpeed = 3.0, fireInterval = 1.2},
        {type = "tormentor_demon", x = 1000, y = 220, patrolRadius = 260, diveInterval = 1.0},
        
        -- Wave 2: Graspers emerge
        {type = "infernal_grasper", x = 1400, y = 240, grabHeight = 280, grabInterval = 1.2},
        {type = "tentacled_abomination", x = 1800, y = 120},
        
        -- Wave 3: Soul swarm
        {type = "damned_souls", x = 2200, y = 200, swarmRadius = 280, swarmSpeed = 4.5},
        {type = "infernal_grasper", x = 2600, y = 380, grabHeight = 280, grabInterval = 1.2},
        
        -- Wave 4: Final gauntlet
        {type = "tormentor_demon", x = 3000, y = 360, patrolRadius = 260, diveInterval = 1.0},
        {type = "flaming_skull", x = 3400, y = 440, patrolRange = 600, patrolSpeed = 3.0, fireInterval = 1.2},
        {type = "tentacled_abomination", x = 3800, y = 520}
    },
    obstacles = {
        -- Maximum difficulty obstacles
        {type = "blood_geyser", x = 400, y = 340, eruptInterval = 1.5},
        {type = "screaming_pillar", x = 800, y = 260, screamInterval = 1.5},
        {type = "infernal_gate", x = 1200, y = 180, openTime = 0.8, closeTime = 1.2},
        {type = "soul_chain", x = 1600, y = -50, chainLength = 300, swingSpeed = 4.0},
        {type = "blood_geyser", x = 2000, y = 160, eruptInterval = 1.5},
        {type = "screaming_pillar", x = 2400, y = 240, screamInterval = 1.5},
        {type = "infernal_gate", x = 2800, y = 320, openTime = 0.8, closeTime = 1.2},
        {type = "soul_chain", x = 3200, y = 270, chainLength = 300, swingSpeed = 4.0}
    }
}