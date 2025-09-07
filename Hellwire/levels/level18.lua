-- level18.lua
return {
    name = "Sinew Symphony",
    track = {
        {100,400}, {200,380}, {300,360}, {400,380}, {500,400}, {600,380},
        {700,360}, {800,380}, {900,400}, {1000,380}, {1100,360}, {1200,380},
        {1300,400}, {1400,380}, {1500,360}, {1600,380}, {1700,400}, {1800,380},
        {1900,360}, {2000,380}, {2100,400}, {2200,400}, {2300,400}, {2400,400}
    },
    enemies = {
        {type = "lava_serpent", x = 500, y = 400, segmentCount = 4, emergeInterval = 3.0, emergeDuration = 4.2},
        {type = "infernal_grasper", x = 900, y = 480, grabHeight = 150, grabInterval = 3.2},
        {type = "lava_serpent", x = 1300, y = 400, segmentCount = 5, emergeInterval = 3.0, emergeDuration = 4.2},
        {type = "infernal_grasper", x = 1700, y = 480, grabHeight = 150, grabInterval = 3.2},
        {type = "lava_serpent", x = 2100, y = 400, segmentCount = 4, emergeInterval = 3.0, emergeDuration = 4.2}
    },
    obstacles = {
        {type = "blood_geyser", x = 700, y = 360, eruptInterval = 3.8},
        {type = "blood_geyser", x = 1100, y = 360, eruptInterval = 3.8},
        {type = "blood_geyser", x = 1500, y = 360, eruptInterval = 3.8}
    }
}