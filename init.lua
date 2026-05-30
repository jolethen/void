-- Force mapgen settings to disable all default elements during generation
minetest.set_mapgen_setting("mg_flags", "nocaves, nodungeons, light, decorations")
minetest.set_mapgen_setting("mgv7_spflags", "no mountains, no ridges")

-- Cache the content ID for air for fast execution
local c_air = minetest.get_content_id("air")

-- This only runs ONCE per chunk right when the world generates it
minetest.register_on_generated(function(minp, maxp, blockseed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local data = vm:get_data()
    local area = VoxelArea:new({emin = emin, emax = emax})

    -- Wipe the newly generated chunk to pure air
    for z = minp.z, maxp.z do
        for y = minp.y, maxp.y do
            for x = minp.x, maxp.x do
                local vi = area:index(x, y, z)
                data[vi] = c_air
            end
        end
    end

    -- Save the empty chunk to the map database
    vm:set_data(data)
    vm:write_to_map()
end)

-- Clear core registration tables so default game engines don't try to
-- spawn structures, trees, or ores on top of your void later
minetest.register_on_mods_loaded(function()
    minetest.registered_decorations = {}
    minetest.registered_biomes = {}
    minetest.registered_ores = {}
end)
