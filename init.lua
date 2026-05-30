-- Safe way to capture the current mod name before any delayed loops run
local my_mod_name = minetest.get_current_modname()

-- 1. Tell the C++ engine to completely turn off its terrain shapes
minetest.set_mapgen_setting("mg_flags", "nocaves, nodungeons, light, decorations", true)
minetest.set_mapgen_setting("mgv7_spflags", "no mountains, no ridges", true)

-- Get the ID of pure air
local c_air = minetest.get_content_id("air")

-- 2. Wipe EVERY remaining node to air during the generation phase
minetest.register_on_generated(function(minp, maxp, blockseed)
    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
    local data = vm:get_data()
    local area = VoxelArea:new({emin = emin, emax = emax})

    -- Absolute wipe from the furthest edge to edge (emin to emax)
    for z = emin.z, emax.z do
        for y = emin.y, emax.y do
            for x = emin.x, emax.x do
                local vi = area:index(x, y, z)
                data[vi] = c_air
            end
        end
    end
    vm:set_data(data)

    -- THE LIGHTING FIX: Build a table matching the data size and fill it with full daylight (15)
    local light_data = {}
    for i = 1, #data do
        light_data[i] = 15 
    end
    
    -- Inject the clean day/night lighting data into the chunk
    vm:set_light_data(light_data)
    
    -- Force the engine to recalculate the shadow vectors for our new empty space
    vm:calc_lighting()
    
    -- Write back the changes
    vm:write_to_map()
end)

-- 3. Block mods from attempting to load biomes/ores later and load our custom nodes
minetest.register_on_mods_loaded(function()
    minetest.registered_decorations = {}
    minetest.registered_biomes = {}
    minetest.registered_ores = {}
    
    if minetest.clear_registered_biomes then minetest.clear_registered_biomes() end
    if minetest.clear_registered_decorations then minetest.clear_registered_decorations() end
    if minetest.clear_registered_ores then minetest.clear_registered_ores() end

    -- Load the nodes file using the explicit modpath structure
    local modpath = minetest.get_modpath(my_mod_name)
    if modpath then
        dofile(modpath .. "/nodes.lua")
    end
end)
