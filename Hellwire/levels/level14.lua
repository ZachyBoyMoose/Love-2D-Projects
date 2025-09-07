-- level14.lua
return {
    name = "Screaming Spiral",
    track = {
        {100,400}, {200,400}, {300,380}, {400,360}, {500,340}, {600,320},
        {700,300}, {800,280}, {900,260}, {1000,260}, {1100,260}, {1200,280},
        {1300,300}, {1400,320}, {1500,340}, {1600,360}, {1700,380}, {1800,400},
        {1900,400}, {2000,400}, {2100,400}, {2200,400}, {2300,400}, {2400,400}
    },
    enemies = {
        {type = "damned_souls", x = 600, y = 320, swarmRadius = 100, swarmSpeed = 2.0},
        {type = "tormentor_demon", x = 1000, y = 260, patrolRadius = 150, diveInterval = 2.8},
        {type = "damned_souls", x = 1500, y = 340, swarmRadius = 100, swarmSpeed = 2.0},
        {type = "flaming_skull", x = 2000, y = 400, patrolRange = 220, patrolSpeed = 1.3, fireInterval = 3.5}
    },
    obstacles = {
        {type = "screaming_pillar", x = 400, y = 360, screamInterval = 3.8},
        {type = "screaming_pillar", x = 800, y = 280, screamInterval = 3.8},
        {type = "screaming_pillar", x = 1300, y = 300, screamInterval = 3.8},
        {type = "soul_chain", x = 1700, y = 230, chainLength = 150, swingSpeed = 2.4}
    }
}