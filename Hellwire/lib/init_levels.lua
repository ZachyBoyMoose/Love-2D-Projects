local State = require('lib.state')

local InitLevels = {}

function InitLevels.initializeLevels()
    for i = 1, 30 do
        State.levels[i] = require("levels.level" .. i)
    end
end

return InitLevels