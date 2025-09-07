-- level16.lua
return {
    name = "Flesh Tunnels",
    track = {
        {100,400}, {200,420}, {300,440}, {400,460}, {500,480}, {600,500},
        {700,520}, {800,540}, {900,560}, {1000,580}, {1100,600}, {1200,600},
        {1300,600}, {1400,580}, {1500,560}, {1600,540}, {1700,520}, {1800,500},
        {1900,480}, {2000,460}, {2100,440}, {2200,420}, {2300,400}, {2400,400}
    },
    enemies = {
        {type = "lava_serpent", x = 600, y = 500, segmentCount = 4, emergeInterval = 3.5, emergeDuration = 4.5},
        {type = "infernal_grasper", x = 1100, y = 700, grabHeight = 160, grabInterval = 3.4},
        {type = "lava_serpent", x = 1600, y = 540, segmentCount = 5, emergeInterval = 3.5, emergeDuration = 4.5},
        {type = "infernal_grasper", x = 2100, y = 540, grabHeight = 160, grabInterval = 3.4}
    },
    obstacles = {
        {type = "blood_geyser", x = 400, y = 460, eruptInterval = 4.2},
        {type = "blood_geyser", x = 900, y = 560, eruptInterval = 4.2},
        {type = "blood_geyser", x = 1400, y = 580, eruptInterval = 4.2},
        {type = "blood_geyser", x = 1900, y = 480, eruptInterval = 4.2}
    }
}