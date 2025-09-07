-- level25.lua
return {
    name = "The War Factory",
    track = {
        {400,400}, {500,370}, {590,320}, {670,260}, {730,180}, {770,90},
        {790,0}, {790,-90}, {770,-180}, {730,-260}, {670,-320}, {590,-370},
        {500,-400}, {400,-400}, {310,-370}, {230,-320}, {170,-260}, {130,-180},
        {110,-90}, {110,0}, {130,90}, {170,180}, {230,260}, {310,320},
        {400,370}, {500,400}, {600,430}, {700,460}, {800,490}, {900,520}
    },
    enemies = {
        {type = "tormentor_demon", x = 400, y = 0, patrolRadius = 200, diveInterval = 2.0},
        {type = "tentacled_abomination", x = 200, y = 0},
        {type = "tentacled_abomination", x = 600, y = 0},
        {type = "flaming_skull", x = 700, y = 460, patrolRange = 350, patrolSpeed = 2.0, fireInterval = 2.0},
        {type = "damned_souls", x = 400, y = -200, swarmRadius = 180, swarmSpeed = 3.2}
    },
    obstacles = {
        {type = "infernal_gate", x = 300, y = 0, openTime = 1.5, closeTime = 2.5},
        {type = "infernal_gate", x = 500, y = 0, openTime = 1.5, closeTime = 2.5},
        {type = "soul_chain", x = 400, y = -250, chainLength = 200, swingSpeed = 3.0},
        {type = "screaming_pillar", x = 600, y = 430, screamInterval = 2.5}
    }
}