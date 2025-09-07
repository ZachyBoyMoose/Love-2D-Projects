-- level10.lua
return {
    name = "BOSS: The Abomination's Lair",
    track = {
        {100,400}, {200,400}, {300,400}, {400,400}, {500,400}, {600,400},
        {700,400}, {800,400}, {900,400}, {1000,400}, {1100,400}, {1200,400},
        {1300,400}, {1400,400}, {1500,400}, {1600,400}, {1700,400}, {1800,400},
        {1900,400}, {2000,400}, {2100,400}, {2200,400}, {2300,400}, {2400,400},
        {2500,400}, {2600,400}, {2700,400}, {2800,400}, {2900,400}, {3000,400}
    },
    enemies = {
        -- Boss that chases (slower speed for fairness)
        {type = "tentacled_abomination", x = -100, y = 400, scale = 1.5, speed = 120},
        {type = "infernal_grasper", x = 800, y = 500, grabHeight = 170, grabInterval = 3.5},
        {type = "infernal_grasper", x = 1400, y = 500, grabHeight = 170, grabInterval = 3.5},
        {type = "tentacled_abomination", x = 2000, y = 400},
        {type = "infernal_grasper", x = 2600, y = 500, grabHeight = 170, grabInterval = 3.5}
    },
    obstacles = {
        {type = "blood_geyser", x = 600, y = 400, eruptInterval = 4.0},
        {type = "blood_geyser", x = 1200, y = 400, eruptInterval = 4.0},
        {type = "blood_geyser", x = 1800, y = 400, eruptInterval = 4.0}
    }
}