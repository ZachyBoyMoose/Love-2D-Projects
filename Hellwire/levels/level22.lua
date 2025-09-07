-- level22.lua
return {
    name = "Steam Pressure Chamber",
    track = {
        {100,500}, {200,480}, {300,460}, {400,440}, {500,420}, {600,400},
        {700,380}, {800,360}, {900,340}, {1000,320}, {1100,300}, {1200,280},
        {1300,260}, {1400,240}, {1500,220}, {1600,200}, {1700,200}, {1800,220},
        {1900,240}, {2000,260}, {2100,280}, {2200,300}, {2300,320}, {2400,340},
        {2500,360}, {2600,380}, {2700,400}, {2800,420}, {2900,440}, {3000,460}
    },
    enemies = {
        {type = "lava_serpent", x = 600, y = 400, segmentCount = 5, emergeInterval = 2.5, emergeDuration = 5.0},
        {type = "infernal_grasper", x = 1000, y = 420, grabHeight = 190, grabInterval = 2.8},
        {type = "lava_serpent", x = 1400, y = 240, segmentCount = 6, emergeInterval = 2.5, emergeDuration = 5.0},
        {type = "infernal_grasper", x = 1800, y = 320, grabHeight = 190, grabInterval = 2.8},
        {type = "flaming_skull", x = 2200, y = 300, patrolRange = 250, patrolSpeed = 1.7, fireInterval = 2.5}
    },
    obstacles = {
        {type = "blood_geyser", x = 400, y = 440, eruptInterval = 3.0},
        {type = "soul_chain", x = 800, y = 210, chainLength = 170, swingSpeed = 2.8},
        {type = "blood_geyser", x = 1200, y = 280, eruptInterval = 3.0},
        {type = "soul_chain", x = 1600, y = 50, chainLength = 170, swingSpeed = 2.8}
    }
}