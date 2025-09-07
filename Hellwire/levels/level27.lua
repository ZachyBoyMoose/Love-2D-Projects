-- level27.lua
return {
    name = "Void Spiral",
    track = {
        {400,400}, {480,380}, {560,360}, {630,330}, {690,290}, {740,240},
        {780,180}, {810,110}, {830,40}, {840,-30}, {840,-100}, {830,-170},
        {810,-240}, {780,-300}, {740,-350}, {690,-390}, {630,-420}, {560,-440},
        {480,-450}, {400,-450}, {320,-440}, {250,-420}, {190,-390}, {140,-350},
        {100,-300}, {70,-240}, {50,-170}, {40,-100}, {40,-30}, {50,40},
        {70,110}, {100,180}, {140,240}, {190,290}, {250,330}, {320,360}
    },
    enemies = {
        {type = "damned_souls", x = 440, y = -35, swarmRadius = 250, swarmSpeed = 3.8},
        {type = "infernal_grasper", x = 200, y = -150, grabHeight = 220, grabInterval = 2.0},
        {type = "infernal_grasper", x = 600, y = -150, grabHeight = 220, grabInterval = 2.0},
        {type = "tentacled_abomination", x = 400, y = -250},
        {type = "tormentor_demon", x = 100, y = 100, patrolRadius = 200, diveInterval = 1.5}
    },
    obstacles = {
        {type = "screaming_pillar", x = 300, y = -35, screamInterval = 2.0},
        {type = "screaming_pillar", x = 500, y = -35, screamInterval = 2.0},
        {type = "blood_geyser", x = 400, y = -350, eruptInterval = 2.0},
        {type = "soul_chain", x = 440, y = 200, chainLength = 250, swingSpeed = 3.5}
    }
}