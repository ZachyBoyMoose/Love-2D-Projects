-- level29.lua
return {
    name = "Final Descent",
    track = {
        {100,100}, {200,120}, {300,140}, {400,160}, {500,180}, {600,200},
        {700,220}, {800,240}, {900,260}, {1000,280}, {1100,300}, {1200,320},
        {1300,340}, {1400,360}, {1500,380}, {1600,400}, {1700,420}, {1800,440},
        {1900,460}, {2000,480}, {2100,500}, {2200,520}, {2300,540}, {2400,560},
        {2500,580}, {2600,600}, {2700,620}, {2800,640}, {2900,660}, {3000,680}
    },
    enemies = {
        {type = "tormentor_demon", x = 500, y = 180, patrolRadius = 240, diveInterval = 1.2},
        {type = "tormentor_demon", x = 900, y = 260, patrolRadius = 240, diveInterval = 1.2},
        {type = "tentacled_abomination", x = 1300, y = 340},
        {type = "lava_serpent", x = 1700, y = 420, segmentCount = 11, emergeInterval = 1.5, emergeDuration = 7.5},
        {type = "infernal_grasper", x = 2100, y = 600, grabHeight = 250, grabInterval = 1.5},
        {type = "flaming_skull", x = 2500, y = 580, patrolRange = 500, patrolSpeed = 2.8, fireInterval = 1.5}
    },
    obstacles = {
        {type = "screaming_pillar", x = 300, y = 140, screamInterval = 1.8},
        {type = "infernal_gate", x = 700, y = 220, openTime = 1.0, closeTime = 1.5},
        {type = "soul_chain", x = 1100, y = 170, chainLength = 280, swingSpeed = 3.8},
        {type = "screaming_pillar", x = 1500, y = 380, screamInterval = 1.8},
        {type = "infernal_gate", x = 1900, y = 460, openTime = 1.0, closeTime = 1.5}
    }
}