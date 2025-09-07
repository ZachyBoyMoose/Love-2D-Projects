-- level12.lua
return {
    name = "The Wailing Ossuary",
    track = {
        {100,300}, {200,320}, {300,340}, {400,360}, {500,380}, {600,400},
        {700,420}, {800,440}, {900,460}, {1000,480}, {1100,500}, {1200,500},
        {1300,500}, {1400,500}, {1500,480}, {1600,460}, {1700,440}, {1800,420},
        {1900,400}, {2000,380}, {2100,360}, {2200,340}, {2300,320}, {2400,300}
    },
    enemies = {
        {type = "damned_souls", x = 600, y = 400, swarmRadius = 85, swarmSpeed = 1.7},
        {type = "infernal_grasper", x = 1100, y = 600, grabHeight = 150, grabInterval = 3.6},
        {type = "damned_souls", x = 1600, y = 460, swarmRadius = 85, swarmSpeed = 1.7},
        {type = "infernal_grasper", x = 2100, y = 460, grabHeight = 150, grabInterval = 3.6}
    },
    obstacles = {
        {type = "screaming_pillar", x = 400, y = 360, screamInterval = 4.0},
        {type = "screaming_pillar", x = 900, y = 460, screamInterval = 4.0},
        {type = "screaming_pillar", x = 1400, y = 500, screamInterval = 4.0},
        {type = "screaming_pillar", x = 1900, y = 400, screamInterval = 4.0}
    }
}