-- level24.lua
return {
    name = "Crucible Crossing",
    track = {
        {100,300}, {200,280}, {300,260}, {400,240}, {500,220}, {600,200},
        {700,200}, {800,220}, {900,240}, {1000,260}, {1100,280}, {1200,300},
        {1300,320}, {1400,340}, {1500,360}, {1600,380}, {1700,400}, {1800,420},
        {1900,440}, {2000,460}, {2100,480}, {2200,500}, {2300,520}, {2400,540},
        {2500,560}, {2600,580}, {2700,600}, {2800,620}, {2900,640}, {3000,660}
    },
    enemies = {
        {type = "flaming_skull", x = 600, y = 200, patrolRange = 300, patrolSpeed = 1.8, fireInterval = 2.3},
        {type = "tentacled_abomination", x = 1000, y = 260},
        {type = "tormentor_demon", x = 1400, y = 340, patrolRadius = 160, diveInterval = 2.2},
        {type = "lava_serpent", x = 1800, y = 420, segmentCount = 8, emergeInterval = 2.2, emergeDuration = 6.0},
        {type = "flaming_skull", x = 2200, y = 500, patrolRange = 300, patrolSpeed = 1.8, fireInterval = 2.3}
    },
    obstacles = {
        {type = "screaming_pillar", x = 400, y = 240, screamInterval = 2.8},
        {type = "blood_geyser", x = 800, y = 220, eruptInterval = 2.8},
        {type = "screaming_pillar", x = 1200, y = 300, screamInterval = 2.8},
        {type = "blood_geyser", x = 1600, y = 380, eruptInterval = 2.8}
    }
}