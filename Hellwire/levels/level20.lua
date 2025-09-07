-- level20.lua
return {
    name = "BOSS: The Flesh Colossus",
    track = {
        {100,400}, {200,380}, {300,360}, {400,340}, {500,320}, {600,300},
        {700,280}, {800,260}, {900,240}, {1000,220}, {1100,200}, {1200,180},
        {1300,160}, {1400,140}, {1500,120}, {1600,100}, {1700,100}, {1800,120},
        {1900,140}, {2000,160}, {2100,180}, {2200,200}, {2300,220}, {2400,240},
        {2500,260}, {2600,280}, {2700,300}, {2800,320}, {2900,340}, {3000,360},
        {3100,380}, {3200,400}, {3300,420}, {3400,440}, {3500,460}, {3600,480}
    },
    enemies = {
        -- Boss: Giant Lava Serpent that chases
        {type = "lava_serpent", x = -200, y = 400, segmentCount = 10, speed = 150},
        {type = "infernal_grasper", x = 600, y = 400, grabHeight = 180, grabInterval = 2.5},
        {type = "tentacled_abomination", x = 1000, y = 220},
        {type = "infernal_grasper", x = 1400, y = 240, grabHeight = 180, grabInterval = 2.5},
        {type = "tentacled_abomination", x = 1800, y = 120},
        {type = "infernal_grasper", x = 2200, y = 300, grabHeight = 180, grabInterval = 2.5}
    },
    obstacles = {
        {type = "blood_geyser", x = 400, y = 340, eruptInterval = 2.8},
        {type = "blood_geyser", x = 800, y = 260, eruptInterval = 2.8},
        {type = "blood_geyser", x = 1200, y = 180, eruptInterval = 2.8},
        {type = "blood_geyser", x = 1600, y = 100, eruptInterval = 2.8}
    }
}