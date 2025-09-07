-- level4.lua
return {
    name = "Hell's Cathedral",
    track = {
        {100,500}, {200,480}, {300,460}, {400,440}, {500,420}, {600,400},
        {700,380}, {800,360}, {900,340}, {1000,320}, {1100,300}, {1200,300},
        {1300,300}, {1400,320}, {1500,340}, {1600,360}, {1700,380}, {1800,400},
        {1900,420}, {2000,440}, {2100,460}, {2200,480}, {2300,500}, {2400,500}
    },
    enemies = {
        {type = "flaming_skull", x = 700, y = 380, patrolRange = 180, patrolSpeed = 1.0, fireInterval = 4.0},
        {type = "lava_serpent", x = 1200, y = 300, segmentCount = 4, emergeInterval = 3.5, emergeDuration = 4.0},
        {type = "tormentor_demon", x = 1900, y = 420, patrolRadius = 120, diveInterval = 3.5}
    },
    obstacles = {
        {type = "soul_chain", x = 500, y = 270, chainLength = 140, swingSpeed = 1.8},
        {type = "screaming_pillar", x = 1600, y = 360, screamInterval = 4.5}
    }
}