-- level8.lua
return {
    name = "Tentacle Terror",
    track = {
        {100,400}, {200,380}, {300,360}, {400,340}, {500,320}, {600,300},
        {700,300}, {800,300}, {900,320}, {1000,340}, {1100,360}, {1200,380},
        {1300,400}, {1400,420}, {1500,440}, {1600,460}, {1700,480}, {1800,500},
        {1900,500}, {2000,500}, {2100,500}, {2200,500}, {2300,500}, {2400,500}
    },
    enemies = {
        {type = "tentacled_abomination", x = 500, y = 320},
        {type = "tentacled_abomination", x = 1000, y = 340},
        {type = "damned_souls", x = 1500, y = 440, swarmRadius = 90, swarmSpeed = 1.6},
        {type = "tentacled_abomination", x = 2000, y = 500}
    },
    obstacles = {
        {type = "blood_geyser", x = 700, y = 300, eruptInterval = 4.8},
        {type = "blood_geyser", x = 1300, y = 400, eruptInterval = 4.8},
        {type = "blood_geyser", x = 1700, y = 480, eruptInterval = 4.8}
    }
}