-- level28.lua
return {
    name = "Gravity Well",
    track = {
        {100,600}, {200,580}, {300,560}, {400,540}, {500,520}, {600,500},
        {700,480}, {800,460}, {900,440}, {1000,420}, {1100,400}, {1200,380},
        {1300,360}, {1400,340}, {1500,320}, {1600,300}, {1700,280}, {1800,260},
        {1900,240}, {2000,220}, {2100,200}, {2200,180}, {2300,160}, {2400,140},
        {2500,120}, {2600,100}, {2700,80}, {2800,60}, {2900,40}, {3000,20}
    },
    enemies = {
        {type = "lava_serpent", x = 600, y = 500, segmentCount = 10, emergeInterval = 1.8, emergeDuration = 7.0},
        {type = "flaming_skull", x = 1000, y = 420, patrolRange = 450, patrolSpeed = 2.5, fireInterval = 1.8},
        {type = "tentacled_abomination", x = 1400, y = 340},
        {type = "infernal_grasper", x = 1800, y = 360, grabHeight = 240, grabInterval = 1.8},
        {type = "tormentor_demon", x = 2200, y = 180, patrolRadius = 220, diveInterval = 1.3},
        {type = "damned_souls", x = 2600, y = 100, swarmRadius = 220, swarmSpeed = 4.0}
    },
    obstacles = {
        {type = "blood_geyser", x = 400, y = 540, eruptInterval = 1.8},
        {type = "blood_geyser", x = 800, y = 460, eruptInterval = 1.8},
        {type = "blood_geyser", x = 1200, y = 380, eruptInterval = 1.8},
        {type = "blood_geyser", x = 1600, y = 300, eruptInterval = 1.8}
    }
}