-- level23.lua
return {
    name = "Molten Assembly Line",
    track = {
        {100,400}, {200,400}, {300,400}, {400,400}, {500,400}, {600,400},
        {700,400}, {800,400}, {900,400}, {1000,400}, {1100,400}, {1200,400},
        {1300,400}, {1400,400}, {1500,400}, {1600,400}, {1700,400}, {1800,400},
        {1900,400}, {2000,400}, {2100,400}, {2200,400}, {2300,400}, {2400,400},
        {2500,400}, {2600,400}, {2700,400}, {2800,400}, {2900,400}, {3000,400}
    },
    enemies = {
        {type = "infernal_grasper", x = 400, y = 500, grabHeight = 200, grabInterval = 2.5},
        {type = "infernal_grasper", x = 700, y = 500, grabHeight = 200, grabInterval = 2.5},
        {type = "infernal_grasper", x = 1000, y = 500, grabHeight = 200, grabInterval = 2.5},
        {type = "infernal_grasper", x = 1300, y = 500, grabHeight = 200, grabInterval = 2.5},
        {type = "infernal_grasper", x = 1600, y = 500, grabHeight = 200, grabInterval = 2.5},
        {type = "infernal_grasper", x = 1900, y = 500, grabHeight = 200, grabInterval = 2.5}
    },
    obstacles = {
        {type = "infernal_gate", x = 500, y = 400, openTime = 1.5, closeTime = 2.0},
        {type = "infernal_gate", x = 900, y = 400, openTime = 1.5, closeTime = 2.0},
        {type = "infernal_gate", x = 1300, y = 400, openTime = 1.5, closeTime = 2.0},
        {type = "infernal_gate", x = 1700, y = 400, openTime = 1.5, closeTime = 2.0}
    }
}