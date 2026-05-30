-- 1. Register a custom Solid Stone Block 
minetest.register_node("void:stone", {
    description = "Builder's Stone",
    tiles = {"default_stone.png"}, 
    is_ground_content = false, -- Stops the engine's cave generator from cutting holes in your placed builds
    groups = {cracky = 3, stone = 1},
    sounds = minetest.node_sound_stone_defaults and minetest.node_sound_stone_defaults() or nil,
})

-- 2. Register a custom Water Block (Stationary Source)
minetest.register_node("void:water", {
    description = "Builder's Water",
    drawtype = "liquid",
    tiles = {
        {
            name = "default_water_source_animated.png",
            backface_culling = false,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 2.0,
            },
        },
        {
            name = "default_water_source_animated.png",
            backface_culling = true,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 2.0,
            },
        },
    },
    alpha = 160, 
    paramtype = "light",
    walkable = false,
    pointable = true,
    diggable = false,
    buildable_to = true,
    drowning = 1,
    liquidtype = "source",
    liquid_alternative_flowing = "void:water_flowing",
    liquid_alternative_source = "void:water",
    liquid_viscosity = 1,
    liquid_renewable = true,
    liquid_range = 8, 
    post_effect_color = {a = 64, r = 0, g = 60, b = 120}, 
    groups = {water = 3, liquid = 1},
})

-- 3. Register the Flowing Water variant
minetest.register_node("void:water_flowing", {
    description = "Flowing Builder's Water",
    drawtype = "flowingliquid",
    tiles = {"default_water.png"},
    special_tiles = {
        {
            name = "default_water_flowing_animated.png",
            backface_culling = false,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 0.8,
            },
        },
        {
            name = "default_water_flowing_animated.png",
            backface_culling = true,
            animation = {
                type = "vertical_frames",
                aspect_w = 16,
                aspect_h = 16,
                length = 0.8,
            },
        },
    },
    alpha = 160,
    paramtype = "light",
    paramtype2 = "flowingliquid", 
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    drowning = 1,
    liquidtype = "flowing",
    liquid_alternative_flowing = "void:water_flowing",
    liquid_alternative_source = "void:water",
    liquid_viscosity = 1,
    liquid_range = 8,
    post_effect_color = {a = 64, r = 0, g = 60, b = 120},
    groups = {water = 3, liquid = 1, not_in_creative_inventory = 1}, 
})

-- 4. Enforce the mapgen engine's internal tags to redirect to AIR
minetest.register_alias_force("mapgen_stone", "air")
minetest.register_alias_force("mapgen_water_source", "air")
minetest.register_alias_force("mapgen_river_water_source", "air")
minetest.register_alias_force("mapgen_lava_source", "air")
