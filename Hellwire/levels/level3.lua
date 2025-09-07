-- level3.lua
return {
    name = "Demon's Playground",
    track = {
        {100,300}, {200,320}, {300,340}, {400,360}, {500,380}, {600,400},
        {700,420}, {800,440}, {900,440}, {1000,440}, {1100,420}, {1200,400},
        {1300,380}, {1400,360}, {1500,340}, {1600,320}, {1700,300}, {1800,300},
        {1900,320}, {2000,340}, {2100,360}, {2200,380}, {2300,400}, {2400,400}
    },
    enemies = {
        {type = "damned_souls", x = 500, y = 380, swarmRadius = 70, swarmSpeed = 1.2},
        {type = "tormentor_demon", x = 1100, y = 420, patrolRadius = 110, diveInterval = 3.8},
        {type = "damned_souls", x = 1700, y = 300, swarmRadius = 70, swarmSpeed = 1.2}
    },
    obstacles = {
        {type = "infernal_gate", x = 800, y = 440, openTime = 3.5, closeTime = 2.5},
        {type = "infernal_gate", x = 2000, y = 340, openTime = 3.5, closeTime = 2.5}
    }
}