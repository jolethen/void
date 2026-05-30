# Mod Documentation: Void Engine Base

This mod forms the absolute core layout of a fully customized building environment. It completely intercepts Luanti's standard C++ map generation routines, suppressing default world generation and building a fully customized node registry under a locked, hardcoded namespace.

---

### 1. System Architecture & Lifecycle Execution Flow

The codebase divides operations into two distinct stages: direct settings manipulation at initial execution, and delayed overrides triggered during engine callbacks to prevent race conditions with external mods.

[Server Startup]
       |
       v
+--------------------------------------------------------+
| 1. init.lua Core Loading                               |
|   - Instantly caches Mod Name & Approved Paths         |
|   - Disables Mapgen Flag Parameters (nocaves, etc.)    |
|   - Sets Mapgen V7 Specific Override Variables         |
+--------------------------------------------------------+
       |
       v
+--------------------------------------------------------+
| 2. register_on_generated Event Hook                    |
|   - Loops through raw VoxelManip data chunk coordinates|
|   - Overwrites every standard map block index to 'air' |
|   - Overrides default daylight lighting arrays to 15   |
+--------------------------------------------------------+
       |
       v
+--------------------------------------------------------+
| 3. register_on_mods_loaded Callback Stage              |
|   - Flushes decoration, biome, and ore tables          |
|   - Resolves secure sandboxed path structures          |
|   - Evaluates nodes.lua via protected dofile call      |
+--------------------------------------------------------+
       |
       v
+--------------------------------------------------------+
| 4. nodes.lua Runtime Parsing                           |
|   - Forces bypass prefix matching via leading ':'      |
|   - Registers void:stone                               |
|   - Registers liquid source & flowing variants         |
|   - Enforces fallback mapgen redirection aliases       |
+--------------------------------------------------------+

---

### 2. Core File Manifest

The mod architecture relies on a strict two-file design pattern standard to clean Lua mod styling:

#### A. init.lua (The Master Controller)
* Purpose: Handles active memory caching, hooks into low-level mapgen loops, and manages secure directory execution.
* Key Mechanics:
  * Disables mapgen features directly via minetest.set_mapgen_setting.
  * Runs a maximum-coverage loop over the Voxel Manipulator bounds (emin to emax) to replace natural generation arrays with pure air IDs.
  * Explicitly rebuilds light vectors (light_data[i] = 15) to eliminate server shadow-rendering bugs in completely open space.
  * Wipes global biome tracking arrays (minetest.registered_biomes = {}) to kill intrusive asset loading from base games.

#### B. nodes.lua (The Asset Registry)
* Purpose: Manages item and block registrations under hardcoded identification rules.
* Key Mechanics:
  * Prefixes item handles with a leading colon (:void:...). This completely bypasses folder-naming validations, forcing the engine to compile custom items into the void registry regardless of directory renaming schemes on your host panel.
  * Sets specific parameters for physics interactions, visual transparency layers, and liquid viscosity behaviors.

---

### 3. Registered Node Specifications

The following table details the technical parameters configured for each custom block type registered in the engine:

| Technical Node Name | Visual Drawtype | Associated Texture Files | Important Mechanical Parameters | Custom Group Tags |
| :--- | :--- | :--- | :--- | :--- |
| void:stone | Normal Block | default_stone.png | is_ground_content = false (Prevents engine carvers from creating random air pockets) | cracky = 3, stone = 1 |
| void:water (Source) | liquid | default_water_source_animated.png | alpha = 160 (High transparency), walkable = false, drowning = 1, liquid_range = 8 | water = 3, liquid = 1 |
| void:water_flowing | flowingliquid | Top Layer: default_water.png, Side Panels: default_water_flowing_animated.png | paramtype2 = "flowingliquid" (Enables downward slope mesh scaling), not_in_creative_inventory = 1 | water = 3, liquid = 1, not_in_creative_inventory = 1 |

---

### 4. Mapgen Alias Enforcement & Redirections

To prevent core crashes when default mechanics attempt to interact with missing environment structures, the engine explicitly re-routes built-in map targets. By using minetest.register_alias_force, the following internal labels are caught and immediately translated into the global air index:

* mapgen_stone -> air
* mapgen_water_source -> air
* mapgen_river_water_source -> air
* mapgen_lava_source -> air

This guarantees that even if a baseline mechanic or external module tries to pull structural assets from the default generation registry, it evaluates as pure empty coordinates without throwing index faults.
