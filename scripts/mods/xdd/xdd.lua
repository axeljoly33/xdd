--[[
	author: Uganda (Axel Joly)
	-----
	Copyright © 2023, Uganda
	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
	The Software is provided “as is”, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders X be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the Software.
	Except as contained in this notice, the name of the <copyright holders> shall not be used in advertising or otherwise to promote the sale, use or other dealings in this Software without prior written authorization from the <copyright holders>. »
	-----
--]]

-------------------
-- LUA UTILITIES --

-- for key,value in pairs(input_manager) do
	-- print(key, value)
-- end
-- for key,value in pairs(getmetatable(input_manager)) do
	-- print(key, value)
-- end

-- for i,v in pairs(input_manager) do print(i,v) end

-- print("x = " .. tostring(x))

-- LUA UTILITIES --
-------------------

local mod = get_mod("xdd")

local hat_path = "units/Plane"
local hat_replace = "units/beings/player/bright_wizard_adept/headpiece/bw_a_hat_01"

Managers.package:load("units/beings/player/bright_wizard_scholar/third_person_base/chr_third_person_mesh", "global")
Managers.package:load("units/beings/player/bright_wizard_adept/third_person_base/chr_third_person_mesh", "global")
Managers.package:load("units/beings/player/bright_wizard_unchained/skins/black_and_gold/chr_bright_wizard_unchained_black_and_gold", "global")

NetworkLookup.inventory_packages[hat_path] = NetworkLookup.inventory_packages[hat_replace]
NetworkLookup.inventory_packages[NetworkLookup.inventory_packages[hat_replace]] = hat_path

ItemMasterList.adept_hat_0000.unit = hat_path
ItemMasterList.adept_hat_0000.template = "dr_helmets"

-- Booleans


-- Global variables


-- Backup


------------
-- EVENTS --

mod.on_all_mods_loaded = function()
	
end

mod.on_unload = function(exit_game)
	
end

mod.on_enabled = function(initial_call)
	
end

mod.on_disabled = function(initial_call)
	
end

mod.on_user_joined = function(player)
	
end

mod.on_user_left = function(player)
	
end

mod.on_setting_changed = function(setting_id)
	
end

mod.on_game_state_changed = function(status, state_name)
	
end

mod.update = function(dt)
    if mod:get("hat") then
        if ItemMasterList.adept_hat_0000.unit ~= hat_path then 
            NetworkLookup.inventory_packages[hat_path] = NetworkLookup.inventory_packages[hat_replace]
            NetworkLookup.inventory_packages[NetworkLookup.inventory_packages[hat_replace]] = hat_path
            ItemMasterList.adept_hat_0000.unit = hat_path
            ItemMasterList.adept_hat_0000.template = "dr_helmets"
            re_equip()
        end
    elseif not mod:get("hat") then
        if ItemMasterList.adept_hat_0000.unit == hat_path then 
            NetworkLookup.inventory_packages[hat_replace] = NetworkLookup.inventory_packages[hat_path]
            NetworkLookup.inventory_packages[NetworkLookup.inventory_packages[hat_path]] = hat_replace
            ItemMasterList.adept_hat_0000.unit = hat_replace
            ItemMasterList.adept_hat_0000.template = "bw_gates"
            re_equip()
        end
    end
end

-- EVENTS --
------------

mod:command("testModel", "", function() 
    mod:spawn_package_to_player(unit_path)
end)

mod:command("hat", "", function()
    local unit = spawn_package_to_player(hat_path)
    replace_textures(unit)
end)

--------------------
-- USER FUNCTIONS --

function spawn_package_to_player (package_name)
	local player = Managers.player:local_player()
	local world = Managers.world:world("level_world")
    local unit_spawner = Managers.state.unit_spawner
    local init_data = {}
    
	if world and player and player.player_unit then
        local player_unit = player.player_unit
        
        local position = Unit.local_position(player_unit, 0) + Vector3(0, 0, 1)
        local rotation = Unit.local_rotation(player_unit, 0)
        local unit_template_name = "interaction_unit"
        local extension_init_data  = {}
        
        local unit = World.spawn_unit(world, package_name, position, rotation)
        
        mod:chat_broadcast(#NetworkLookup.inventory_packages + 1)
        return unit
	end
    
	return nil
end

function replace_textures(unit)
    if Unit.has_data(unit, "mat_list") then
        local num_mats = Unit.get_data(unit, "num_mats")
        
        for i=1, num_mats do 
            local mat_slot = Unit.get_data(unit, "mat_slots", "slot"..tostring(i))
            local mat = Unit.get_data(unit, "mat_list", "slot"..tostring(i))
            Unit.set_material(unit, mat_slot, mat)
            
        end
    end 
end

function re_equip()
    local player = Managers.player:local_player()
    local player_unit = player.player_unit    
    local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
    local career_extension = ScriptUnit.extension(player_unit, "career_system")
    local career_name = career_extension:career_name()
    local item_one = BackendUtils.get_loadout_item(career_name, "slot_melee")
    local item_two = BackendUtils.get_loadout_item(career_name, "slot_ranged")
    local item_hat = BackendUtils.get_loadout_item(career_name, "slot_hat")
    
    local skin_item = BackendUtils.get_loadout_item(career_name, "slot_skin")
    local item_data = skin_item and skin_item.data
    local skin_name = item_data.name
    local skin_data = Cosmetics[skin_name]
    local equip_hat_event = skin_data.equip_hat_event
    
    if item_hat and equip_hat_event then
        Unit.flow_event(item_hat, equip_hat_event)
    end
    
    local backend_items = Managers.backend:get_interface("items")
    backend_items:set_loadout_item(item_hat.backend_id, career_name, "slot_hat")
end

-- USER FUNCTIONS --
--------------------

-----------
-- HOOKS --

mod:hook(PackageManager, "load", function(func, self, package_name, reference_name, callback, asynchronous, prioritize)
    if package_name ~= hat_path then
        func(self, package_name, reference_name, callback, asynchronous, prioritize)
    end
end)

mod:hook(PackageManager, "unload", function(func, self, package_name, reference_name)
    if package_name ~= hat_path then
        func(self, package_name, reference_name)
    end
end)

mod:hook(PackageManager, "has_loaded", function(func, self, package, reference_name)
    if package == hat_path then
        return true
    end
	
    return func(self, package, reference_name)
end)

-- HOOKS --
-----------