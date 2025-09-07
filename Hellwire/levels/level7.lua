-- level7.lua
return {
    name = "The Grasping Depths",
    track = {
        {100,400}, {200,400}, {300,400}, {400,400}, {500,400}, {600,400},
        {700,400}, {800,400}, {900,400}, {1000,400}, {1100,400}, {1200,400},
        {1300,400}, {1400,400}, {1500,400}, {1600,400}, {1700,400}, {1800,400},
        {1900,400}, {2000,400}, {2100,400}, {2200,400}, {2300,400}, {2400,400}
    },
    enemies = {
        {type = "infernal_grasper", x = 500, y = 500, grabHeight = 150, grabInterval = 4.0},
        {type = "infernal_grasper", x = 1000, y = 500, grabHeight = 150, grabInterval = 4.0},
        {type = "tentacled_abomination", x = 1500, y = 400},
        {type = "infernal_grasper", x = 2000, y = 500, grabHeight = 150, grabInterval = 4.0}
    },
    obstacles = {
        {type = "screaming_pillar", x = 750, y = 400, screamInterval = 4.5},
        {type = "screaming_pillar", x = 1750, y = 400, screamInterval = 4.5}
    }
}