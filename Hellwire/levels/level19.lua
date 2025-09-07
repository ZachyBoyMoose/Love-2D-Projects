-- level19.lua
return {
    name = "Blood River Rapids",
    track = {
        {100,200}, {200,220}, {300,240}, {400,260}, {500,280}, {600,300},
        {700,320}, {800,340}, {900,360}, {1000,380}, {1100,400}, {1200,420},
        {1300,440}, {1400,460}, {1500,480}, {1600,500}, {1700,500}, {1800,480},
        {1900,460}, {2000,440}, {2100,420}, {2200,400}, {2300,380}, {2400,360},
        {2500,340}, {2600,320}, {2700,300}, {2800,280}, {2900,260}, {3000,240}
    },
    enemies = {
        {type = "lava_serpent", x = 600, y = 300, segmentCount = 7, emergeInterval = 2.3, emergeDuration = 6.0},
        {type = "tentacled_abomination", x = 1000, y = 380},
        {type = "lava_serpent", x = 1400, y = 460, segmentCount = 7, emergeInterval = 2.3, emergeDuration = 6.0},
        {type = "tentacled_abomination", x = 1800, y = 480},
        {type = "lava_serpent", x = 2200, y = 400, segmentCount = 7, emergeInterval = 2.3, emergeDuration = 6.0}
    },
    obstacles = {
        {type = "blood_geyser", x = 300, y = 240, eruptInterval = 3.2},
        {type = "blood_geyser", x = 500, y = 280, eruptInterval = 3.2},
        {type = "blood_geyser", x = 700, y = 320, eruptInterval = 3.2},
        {type = "blood_geyser", x = 900, y = 360, eruptInterval = 3.2},
        {type = "blood_geyser", x = 1100, y = 400, eruptInterval = 3.2},
        {type = "blood_geyser", x = 1300, y = 440, eruptInterval = 3.2}
    }
}