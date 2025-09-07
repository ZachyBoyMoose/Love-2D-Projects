-- level9.lua
return {
    name = "Blood Rain Cathedral",
    track = {
        {100,500}, {200,500}, {300,480}, {400,460}, {500,440}, {600,420},
        {700,400}, {800,380}, {900,360}, {1000,340}, {1100,320}, {1200,300},
        {1300,300}, {1400,300}, {1500,320}, {1600,340}, {1700,360}, {1800,380},
        {1900,400}, {2000,420}, {2100,440}, {2200,460}, {2300,480}, {2400,500}
    },
    enemies = {
        {type = "infernal_grasper", x = 600, y = 520, grabHeight = 160, grabInterval = 3.8},
        {type = "tentacled_abomination", x = 1100, y = 320},
        {type = "lava_serpent", x = 1600, y = 340, segmentCount = 5, emergeInterval = 3.2, emergeDuration = 4.8},
        {type = "infernal_grasper", x = 2100, y = 540, grabHeight = 160, grabInterval = 3.8}
    },
    obstacles = {
        {type = "blood_geyser", x = 400, y = 460, eruptInterval = 4.5},
        {type = "blood_geyser", x = 900, y = 360, eruptInterval = 4.5},
        {type = "blood_geyser", x = 1400, y = 300, eruptInterval = 4.5},
        {type = "blood_geyser", x = 1900, y = 400, eruptInterval = 4.5}
    }
}