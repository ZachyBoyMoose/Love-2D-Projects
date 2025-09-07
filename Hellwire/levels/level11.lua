-- level11.lua
return {
    name = "Bone Bridge of Sorrow",
    track = {
        {100,400}, {200,380}, {300,360}, {400,340}, {500,320}, {600,300},
        {700,280}, {800,260}, {900,240}, {1000,220}, {1100,200}, {1200,200},
        {1300,200}, {1400,220}, {1500,240}, {1600,260}, {1700,280}, {1800,300},
        {1900,320}, {2000,340}, {2100,360}, {2200,380}, {2300,400}, {2400,400}
    },
    enemies = {
        {type = "damned_souls", x = 500, y = 320, swarmRadius = 75, swarmSpeed = 1.5},
        {type = "damned_souls", x = 1000, y = 220, swarmRadius = 75, swarmSpeed = 1.5},
        {type = "tormentor_demon", x = 1500, y = 240, patrolRadius = 130, diveInterval = 3.2},
        {type = "damned_souls", x = 2000, y = 340, swarmRadius = 75, swarmSpeed = 1.5}
    },
    obstacles = {
        {type = "soul_chain", x = 300, y = 210, chainLength = 130, swingSpeed = 2.0},
        {type = "soul_chain", x = 800, y = 110, chainLength = 130, swingSpeed = 2.0},
        {type = "screaming_pillar", x = 1300, y = 200, screamInterval = 4.2},
        {type = "soul_chain", x = 1700, y = 130, chainLength = 130, swingSpeed = 2.0}
    }
}