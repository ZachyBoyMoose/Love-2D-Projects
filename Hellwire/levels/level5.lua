-- level5.lua
return {
    name = "The First Circle",
    track = {
        {100,400}, {200,400}, {300,400}, {400,380}, {500,360}, {600,340},
        {700,320}, {800,300}, {900,300}, {1000,300}, {1100,320}, {1200,340},
        {1300,360}, {1400,380}, {1500,400}, {1600,400}, {1700,400}, {1800,400},
        {1900,400}, {2000,400}, {2100,400}, {2200,400}, {2300,400}, {2400,400}
    },
    enemies = {
        {type = "lava_serpent", x = 800, y = 300, segmentCount = 5, emergeInterval = 3.0, emergeDuration = 4.5},
        {type = "tormentor_demon", x = 600, y = 340, patrolRadius = 100, diveInterval = 3.3},
        {type = "flaming_skull", x = 1500, y = 400, patrolRange = 200, patrolSpeed = 1.1, fireInterval = 3.8},
        {type = "damned_souls", x = 2000, y = 400, swarmRadius = 80, swarmSpeed = 1.4}
    },
    obstacles = {
        {type = "infernal_gate", x = 1100, y = 320, openTime = 3.0, closeTime = 3.0},
        {type = "blood_geyser", x = 1700, y = 400, eruptInterval = 5.5}
    }
}