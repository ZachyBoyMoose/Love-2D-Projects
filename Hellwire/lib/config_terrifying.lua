local Config = require('lib.config')
local Animation = require('lib.animation')

function Config.loadTerrifyingAssets()
    -- Keep existing static assets
    Config.loadAssets()
    
    -- Load animated enemy assets
    Config.animations = {
        damned_souls = Animation.new({
            "hell_assets/enemy_damned_souls_frame1.png",
            "hell_assets/enemy_damned_souls_frame2.png",
            "hell_assets/enemy_damned_souls_frame3.png",
            "hell_assets/enemy_damned_souls_frame4.png"
        }, 0.15, true),
        
        infernal_grasper = Animation.new({
            "hell_assets/enemy_infernal_grasper_frame1.png",
            "hell_assets/enemy_infernal_grasper_frame2.png",
            "hell_assets/enemy_infernal_grasper_frame3.png",
            "hell_assets/enemy_infernal_grasper_frame4.png"
        }, 0.2, true),
        
        flaming_skull = Animation.new({
            "hell_assets/enemy_flaming_skull_frame1.png",
            "hell_assets/enemy_flaming_skull_frame2.png",
            "hell_assets/enemy_flaming_skull_frame3.png",
            "hell_assets/enemy_flaming_skull_frame4.png"
        }, 0.18, true),
        
        tentacled_abomination = Animation.new({
            "hell_assets/enemy_tentacled_abomination_frame1.png",
            "hell_assets/enemy_tentacled_abomination_frame2.png",
            "hell_assets/enemy_tentacled_abomination_frame3.png",
            "hell_assets/enemy_tentacled_abomination_frame4.png"
        }, 0.25, true),
        
        tormentor_demon = Animation.new({
            "hell_assets/enemy_tormentor_demon_frame1.png",
            "hell_assets/enemy_tormentor_demon_frame2.png",
            "hell_assets/enemy_tormentor_demon_frame3.png",
            "hell_assets/enemy_tormentor_demon_frame4.png"
        }, 0.12, true),
        
        lava_serpent = Animation.new({
            "hell_assets/enemy_lava_serpent_segment_frame1.png",
            "hell_assets/enemy_lava_serpent_segment_frame2.png",
            "hell_assets/enemy_lava_serpent_segment_frame3.png",
            "hell_assets/enemy_lava_serpent_segment_frame4.png"
        }, 0.2, true),
        
        -- Obstacle animations
        blood_geyser = Animation.new({
            "hell_assets/obstacle_blood_geyser_frame1.png",
            "hell_assets/obstacle_blood_geyser_frame2.png",
            "hell_assets/obstacle_blood_geyser_frame3.png",
            "hell_assets/obstacle_blood_geyser_frame4.png"
        }, 0.3, true),
        
        soul_chain = Animation.new({
            "hell_assets/obstacle_soul_chain_frame1.png",
            "hell_assets/obstacle_soul_chain_frame2.png",
            "hell_assets/obstacle_soul_chain_frame3.png",
            "hell_assets/obstacle_soul_chain_frame4.png"
        }, 0.15, true),
        
        infernal_gate = Animation.new({
            "hell_assets/obstacle_infernal_gate_frame1.png",
            "hell_assets/obstacle_infernal_gate_frame2.png",
            "hell_assets/obstacle_infernal_gate_frame3.png",
            "hell_assets/obstacle_infernal_gate_frame4.png"
        }, 0.4, true),
        
        screaming_pillar = Animation.new({
            "hell_assets/obstacle_screaming_pillar_frame1.png",
            "hell_assets/obstacle_screaming_pillar_frame2.png",
            "hell_assets/obstacle_screaming_pillar_frame3.png",
            "hell_assets/obstacle_screaming_pillar_frame4.png"
        }, 0.5, true),
        
        -- Effect animations
        fire_blast = Animation.new({
            "hell_assets/effect_fire_blast_frame1.png",
            "hell_assets/effect_fire_blast_frame2.png",
            "hell_assets/effect_fire_blast_frame3.png",
            "hell_assets/effect_fire_blast_frame4.png"
        }, 0.1, false)
    }
end

return Config