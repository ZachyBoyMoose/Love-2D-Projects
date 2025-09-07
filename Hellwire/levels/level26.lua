-- level26.lua
return {
    name = "Event Horizon",
    track = {
        {100,400}, {200,380}, {300,360}, {400,340}, {500,320}, {600,300},
        {700,280}, {800,260}, {900,240}, {1000,220}, {1100,200}, {1200,180},
        {1300,160}, {1400,140}, {1500,120}, {1600,100}, {1700,80}, {1800,60},
        {1900,40}, {2000,20}, {2100,0}, {2200,0}, {2300,20}, {2400,40},
        {2500,60}, {2600,80}, {2700,100}, {2800,120}, {2900,140}, {3000,160}
    },
    enemies = {
        {type = "flaming_skull", x = 600, y = 300, patrolRange = 400, patrolSpeed = 2.2, fireInterval = 2.0},
        {type = "tormentor_demon", x = 1000, y = 220, patrolRadius = 180, diveInterval = 1.8},
        {type = "tentacled_abomination", x = 1400, y = 140},
        {type = "lava_serpent", x = 1800, y = 60, segmentCount = 9, emergeInterval = 2.0, emergeDuration = 6.5},
        {type = "damned_souls", x = 2200, y = 0, swarmRadius = 200, swarmSpeed = 3.5}
    },
    obstacles = {
        {type = "screaming_pillar", x = 400, y = 340, screamInterval = 2.3},
        {type = "infernal_gate", x = 800, y = 260, openTime = 1.2, closeTime = 2.0},
        {type = "blood_geyser", x = 1200, y = 180, eruptInterval = 2.3},
        {type = "soul_chain", x = 1600, y = -50, chainLength = 220, swingSpeed = 3.2}
    }
}