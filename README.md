# Void 

This mod forms the core layout of a minigame server when u use this mod, any mod which generates stuff completely stops from doing so giving you full freedom over an empty canvas

---

### 1. Core File Manifest

#### A. init.lua
* Runs a maximum-coverage loop over Voxel Manipulator bounds (`emin` to `emax`) to replace natural generation arrays with pure air IDs.
* Explicitly rebuilds light vectors (`light_data[i] = 15`) to eliminate server shadow-rendering bugs in completely open space.
* Wipes global biome tracking arrays (`minetest.registered_biomes = {}`) to kill intrusive asset loading from base games.

#### B. nodes.lua
* Adds new stone and water incase the game refuses to register, its a known bug where game completely removes water, stone from existence and even reguse to register so u can use void mods water and stone alternatively
* Sets specific parameters for physics interactions, visual transparency layers, and liquid viscosity behaviors.

---

### 2. Registered Node Specifications

| Technical Node Name | Visual Drawtype | Associated Texture Files | Important Mechanical Parameters | Custom Group Tags |
| :--- | :--- | :--- | :--- | :--- |
| void:stone | Normal Block | default_stone.png | is_ground_content = false | cracky = 3, stone = 1 |
| void:water (Source) | liquid | default_water_source_animated.png | alpha = 160, walkable = false, drowning = 1, liquid_range = 8 | water = 3, liquid = 1 |
| void:water_flowing | flowingliquid | Top Layer: default_water.png, Side Panels: default_water_flowing_animated.png | paramtype2 = "flowingliquid", not_in_creative_inventory = 1 | water = 3, liquid = 1, not_in_creative_inventory = 1 |

---

### 3. Mapgen Alias Enforcement & Redirections

Forces built-in map targets to redirect into the global **`air`** index using `minetest.register_alias_force` to avoid crashes:

* mapgen_stone -> air
* mapgen_water_source -> air
* mapgen_river_water_source -> air
* mapgen_lava_source -> air

# Important 
* Sometimes it may remove stone and water from existence completely so use wisely on a test world before.
