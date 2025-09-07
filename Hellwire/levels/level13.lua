-- level13.lua
return {
    name = "Chain Prison",
    track = {
        {100,400}, {200,380}, {300,360}, {400,340}, {500,320}, {600,300},
        {700,300}, {800,300}, {900,300}, {1000,320}, {1100,340}, {1200,360},
        {1300,380}, {1400,400}, {1500,420}, {1600,440}, {1700,460}, {1800,480},
        {1900,500}, {2000,500}, {2100,500}, {2200,500}, {2300,500}, {2400,500}
    },
    enemies = {
        {type = "tormentor_demon", x = 600, y = 300, patrolRadius = 140, diveInterval = 3.0},
        {type = "damned_souls", x = 1100, y = 340, swarmRadius = 95, swarmSpeed = 1.9},
        {type = "tormentor_demon", x = 1600, y = 440, patrolRadius = 140, diveInterval = 3.0},
        {type = "damned_souls", x = 2100, y = 500, swarmRadius = 95, swarmSpeed = 1.9}
    },
    obstacles = {
        {type = "soul_chain", x = 400, y = 190, chainLength = 140, swingSpeed = 2.2},
        {type = "soul_chain", x = 800, y = 150, chainLength = 140, swingSpeed = 2.2},
        {type = "soul_chain", x = 1200, y = 210, chainLength = 140, swingSpeed = 2.2},
        {type = "soul_chain", x = 1800, y = 330, chainLength = 140, swingSpeed = 2.2}
    }
}