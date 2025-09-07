-- level2.lua
return {
    name = "The Burning Path",
    track = {
        {100,400}, {200,380}, {300,360}, {400,340}, {500,320}, {600,300},
        {700,280}, {800,260}, {900,260}, {1000,260}, {1100,280}, {1200,300},
        {1300,320}, {1400,340}, {1500,360}, {1600,380}, {1700,400}, {1800,420},
        {1900,440}, {2000,460}, {2100,480}, {2200,500}, {2300,500}, {2400,500}
    },
    enemies = {
        {type = "tormentor_demon", x = 600, y = 300, patrolRadius = 100, diveInterval = 4.0},
        {type = "flaming_skull", x = 1400, y = 340, patrolRange = 150, patrolSpeed = 0.9, fireInterval = 4.5}
    },
    obstacles = {
        {type = "soul_chain", x = 900, y = 110, chainLength = 120, swingSpeed = 1.5},
        {type = "screaming_pillar", x = 1800, y = 420, screamInterval = 5.0}
    }
}