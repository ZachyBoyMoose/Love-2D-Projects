-- level1.lua
return {
    name = "Welcome to Hell",
    track = {
        {100,400}, {200,400}, {300,400}, {400,400}, {500,400}, {600,400},
        {700,400}, {800,400}, {900,400}, {1000,400}, {1100,400}, {1200,400},
        {1300,400}, {1400,400}, {1500,400}, {1600,400}, {1700,400}, {1800,400},
        {1900,400}, {2000,400}, {2100,400}, {2200,400}, {2300,400}, {2400,400}
    },
    enemies = {
        {type = "flaming_skull", x = 800, y = 400, patrolRange = 200, patrolSpeed = 0.8, fireInterval = 5.0},
        {type = "damned_souls", x = 1600, y = 400, swarmRadius = 60, swarmSpeed = 1.0}
    },
    obstacles = {
        {type = "infernal_gate", x = 1200, y = 400, openTime = 4.0, closeTime = 2.0}
    }
}