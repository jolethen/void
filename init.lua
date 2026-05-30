-- 1. Force the engine's core settings to disable structures entirely
minetest.set_mapgen_setting("mg_flags", "nocaves, nodungeons, light, decorations", true)
minetest.set_mapgen_setting("mgv7_spflags", "no mountains, no ridges", true)

-- Cache the content ID for air
local c_air = minetest.get_content_id("air")

-- 2. Intercept and completely wipe the entire emerged map block region
minetest.register_on_generated(function(minp, maxp, blockseed)
    -- Grab the voxelmanip object for the chunk
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local data = vm:get_data()
    
    -- CRUCIAL FIX: Loop from emin to emax (the true outer boundaries), 
    -- instead of minp to maxp. This catches bleeding decorations, liquid, and structures.
    local area = VoxelArea:new({emin = emin, emax = emax})
    
    for z = emin.z, emax.z do
        for y = emin.y, emax.y do
            for x = emin.x, emax.x do
                local vi = area:index(x, y, z)
                data[vi] = c_air
            end
        end
    end

    -- Write the absolute void data back to the engine
    vm:set_data(data)
    vm:set_lighting({day = 15, night = 15}) -- Fix lighting so it isn't pitch black pitch
    vm:calc_lighting()
    vm:write_to_map()
end)

-- 3. Nuclear option for database-registered decorations & biomes
-- This completely breaks other mods' abilities to register structures to populate later
minetest.register_on_mods_loaded(function()
    minetest.registered_decorations = {}
    minetest.registered_biomes = {}
    minetest.registered_ores = {}
    
    -- Clear standard biome definitions if they exist natively
    if minetest.clear_registered_biomes then minetest.clear_registered_biomes() end
    if minetest.clear_registered_decorations then minetest.clear_registered_decorations() end
    if minetest.clear_registered_ores then minetest.clear_registered_ores() end
end)
