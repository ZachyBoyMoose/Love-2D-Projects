-- level17.lua
return {
    name = "Organ Overflow",
    track = {
        {100,300}, {200,300}, {300,300}, {400,320}, {500,340}, {600,360},
        {700,380}, {800,400}, {900,420}, {1000,440}, {1100,460}, {1200,480},
        {1300,500}, {1400,500}, {1500,480}, {1600,460}, {1700,440}, {1800,420},
        {1900,400}, {2000,380}, {2100,360}, {2200,340}, {2300,320}, {2400,300}
    },
    enemies = {
        {type = "tentacled_abomination", x = 500, y = 340},
        {type = "lava_serpent", x = 1000, y = 440, segmentCount = 6, emergeInterval = 3.2, emergeDuration = 5.0},
        {type = "tentacled_abomination", x = 1500, y = 480},
        {type = "lava_serpent", x = 2000, y = 380, segmentCount = 6, emergeInterval = 3.2, emergeDuration = 5.0}
    },
    obstacles = {
        {type = "blood_geyser", x = 700, y = 380, eruptInterval = 4.0},
        {type = "screaming_pillar", x = 1200, y = 480, screamInterval = 3.8},
        {type = "blood_geyser", x = 1700, y = 440, eruptInterval = 4.0}
    }
}