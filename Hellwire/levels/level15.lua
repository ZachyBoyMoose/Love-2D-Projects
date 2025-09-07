-- level15.lua
return {
    name = "The Soul Harvest",
    track = {
        {100,500}, {200,480}, {300,460}, {400,440}, {500,420}, {600,400},
        {700,380}, {800,360}, {900,340}, {1000,320}, {1100,300}, {1200,280},
        {1300,260}, {1400,240}, {1500,220}, {1600,200}, {1700,200}, {1800,200},
        {1900,200}, {2000,200}, {2100,200}, {2200,200}, {2300,200}, {2400,200}
    },
    enemies = {
        {type = "damned_souls", x = 500, y = 420, swarmRadius = 110, swarmSpeed = 2.2},
        {type = "damned_souls", x = 900, y = 340, swarmRadius = 110, swarmSpeed = 2.2},
        {type = "damned_souls", x = 1300, y = 260, swarmRadius = 110, swarmSpeed = 2.2},
        {type = "damned_souls", x = 1700, y = 200, swarmRadius = 110, swarmSpeed = 2.2},
        {type = "damned_souls", x = 2100, y = 200, swarmRadius = 110, swarmSpeed = 2.2}
    },
    obstacles = {
        {type = "soul_chain", x = 300, y = 310, chainLength = 150, swingSpeed = 2.5},
        {type = "soul_chain", x = 700, y = 230, chainLength = 150, swingSpeed = 2.5},
        {type = "soul_chain", x = 1100, y = 150, chainLength = 150, swingSpeed = 2.5},
        {type = "soul_chain", x = 1500, y = 70, chainLength = 150, swingSpeed = 2.5}
    }
}