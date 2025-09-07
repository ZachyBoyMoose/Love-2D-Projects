-- level6.lua
return {
    name = "Acid Rain Valley",
    track = {
        {100,300}, {200,320}, {300,340}, {400,360}, {500,380}, {600,400},
        {700,420}, {800,440}, {900,460}, {1000,480}, {1100,500}, {1200,520},
        {1300,540}, {1400,560}, {1500,580}, {1600,600}, {1700,600}, {1800,600},
        {1900,600}, {2000,600}, {2100,600}, {2200,600}, {2300,600}, {2400,600}
    },
    enemies = {
        {type = "tentacled_abomination", x = 600, y = 400},
        {type = "infernal_grasper", x = 1200, y = 620, grabHeight = 140, grabInterval = 4.5},
        {type = "tentacled_abomination", x = 1800, y = 600}
    },
    obstacles = {
        {type = "blood_geyser", x = 400, y = 360, eruptInterval = 5.0},
        {type = "blood_geyser", x = 900, y = 460, eruptInterval = 5.0},
        {type = "blood_geyser", x = 1500, y = 580, eruptInterval = 5.0}
    }
}