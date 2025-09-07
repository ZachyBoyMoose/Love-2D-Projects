local Config = {}

Config.screenWidth = 800
Config.screenHeight = 600
Config.assets = {}

function Config.loadAssets()
    Config.assets = {
        gondola = love.graphics.newImage("hell_assets/gondola.png"),
        soul_icon = love.graphics.newImage("hell_assets/soul_icon.png"),
        track_hitch = love.graphics.newImage("hell_assets/track_hitch.png"),
        cable_chain_tile = love.graphics.newImage("hell_assets/cable_chain_tile.png"),
        enemy_spike = love.graphics.newImage("hell_assets/enemy_spike.png"),
        enemy_fireball = love.graphics.newImage("hell_assets/enemy_fireball.png"),
        enemy_swinger_hazard = love.graphics.newImage("hell_assets/enemy_swinger_hazard.png"),
        enemy_rotator_endpoint = love.graphics.newImage("hell_assets/enemy_rotator_endpoint.png"),
        enemy_acid_drop = love.graphics.newImage("hell_assets/enemy_acid_drop.png"),
        enemy_lava_drop = love.graphics.newImage("hell_assets/enemy_lava_drop.png"),
        enemy_bubble = love.graphics.newImage("hell_assets/enemy_bubble.png"),
        enemy_guardian = love.graphics.newImage("hell_assets/enemy_guardian.png"),
        enemy_guardian_projectile = love.graphics.newImage("hell_assets/enemy_guardian_projectile.png"),
        enemy_bone_thrower = love.graphics.newImage("hell_assets/enemy_bone_thrower.png"),
        enemy_bone_projectile = love.graphics.newImage("hell_assets/enemy_bone_projectile.png"),
        enemy_flesh_blob = love.graphics.newImage("hell_assets/enemy_flesh_blob.png"),
        enemy_cannon = love.graphics.newImage("hell_assets/enemy_cannon.png"),
        enemy_cannonball = love.graphics.newImage("hell_assets/enemy_cannonball.png"),
        boss_acid_lord = love.graphics.newImage("hell_assets/boss_acid_lord.png"),
        boss_flesh_colossus = love.graphics.newImage("hell_assets/boss_flesh_colossus.png"),
        boss_flesh_tentacle = love.graphics.newImage("hell_assets/boss_flesh_tentacle.png"),
        boss_hell_train = love.graphics.newImage("hell_assets/boss_hell_train.png"),
        ui_hud_panel = love.graphics.newImage("hell_assets/ui_hud_panel.png"),
        ui_level_button = love.graphics.newImage("hell_assets/ui_level_button.png"),
        bg_title_screen = love.graphics.newImage("hell_backgrounds/bg_title_screen.png"),
        bg_level_select = love.graphics.newImage("hell_backgrounds/bg_level_select.png"),
        bg_game_over = love.graphics.newImage("hell_backgrounds/bg_game_over.png"),
        bg_level_complete = love.graphics.newImage("hell_backgrounds/bg_level_complete.png"),
        bg_world_1_charred = love.graphics.newImage("hell_backgrounds/bg_world_1_charred.png"),
        bg_world_2_toxic = love.graphics.newImage("hell_backgrounds/bg_world_2_toxic.png"),
        bg_world_3_skeletal = love.graphics.newImage("hell_backgrounds/bg_world_3_skeletal.png"),
        bg_world_4_visceral = love.graphics.newImage("hell_backgrounds/bg_world_4_visceral.png"),
        bg_world_5_industrial = love.graphics.newImage("hell_backgrounds/bg_world_5_industrial.png"),
        bg_world_6_oblivion = love.graphics.newImage("hell_backgrounds/bg_world_6_oblivion.png")
    }
end

return Config