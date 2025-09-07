-- level21.lua
return {
    name = "The Gear Grinder",
    track = {
        {100,400}, {200,380}, {300,360}, {400,340}, {500,320}, {600,300},
        {700,280}, {800,260}, {900,240}, {1000,220}, {1100,200}, {1200,180},
        {1300,160}, {1400,140}, {1500,120}, {1600,100}, {1700,100}, {1800,120},
        {1900,140}, {2000,160}, {2100,180}, {2200,200}, {2300,220}, {2400,240},
        {2500,260}, {2600,280}, {2700,300}, {2800,320}, {2900,340}, {3000,360}
    },
    enemies = {
        {type = "flaming_skull", x = 500, y = 320, patrolRange = 200, patrolSpeed = 1.6, fireInterval = 2.8},
        {type = "tormentor_demon", x = 900, y = 240, patrolRadius = 150, diveInterval = 2.3},
        {type = "tentacled_abomination", x = 1300, y = 160},
        {type = "flaming_skull", x = 1700, y = 100, patrolRange = 200, patrolSpeed = 1.6, fireInterval = 2.8},
        {type = "tormentor_demon", x = 2100, y = 180, patrolRadius = 150, diveInterval = 2.3}
    },
    obstacles = {
        {type = "infernal_gate", x = 700, y = 280, openTime = 2.0, closeTime = 3.0},
        {type = "screaming_pillar", x = 1100, y = 200, screamInterval = 3.0},
        {type = "infernal_gate", x = 1500, y = 120, openTime = 2.0, closeTime = 3.0},
        {type = "screaming_pillar", x = 1900, y = 140, screamInterval = 3.0}
    }
}