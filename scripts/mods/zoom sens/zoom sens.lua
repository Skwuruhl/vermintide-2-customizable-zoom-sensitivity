local mod = get_mod("zoom sens")
local status_extension = ScriptUnit.extension(owner_unit, "status_system")

local sensMult = 1.0
local mode = mod:get("scaling_method")
local coef = 1.0

-- Everything here is optional, feel free to remove anything you're not using

--[[
	Functions
--]]

-- "Private" function - not accessible to other mods
local function update_sensMult()
	local configFOV = Application.user_setting("render_settings", "fov") * math.pi / 180 --gets configured FOV in radians
	if mode == "focal_length" then
		sensMult = configFOV / math.tan(configFOV/2) / 0.785 --calculates a sensitivity multiplier to make hipfire the same as without the mod.
	else
		sensMult = configFOV / math.atan(coef*math.tan(configFOV/2)) / 0.785
	end
end

local function update_mode()
	mode = mod:get("scaling_method")
	coef = mod:get("coefficient") / 100
end

-- "Public" function - accessible to other mods
--function mod.my_function()

--end


--[[
	Hooks
--]]

-- If you simply want to call a function after SomeObject.some_function has been executed
-- Arguments for SomeObject.some_function will be passed to my_function as well
--mod:hook_safe(SomeObject, "some_function", my_function)

-- If you want to do something more involved
mod:hook_origin(CharacterStateHelper, "look", function (input_extension, viewport_name, first_person_extension, status_extension, inventory_extension, override_sens, override_delta)
	local camera_manager = Managers.state.camera
	local fieldOfView = override_sens or (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1 --modified "look_sensitivity" equation which is originally just fov / 0.785. So I removed the "/ 0.785"
	local is_3p = false
	local look_delta = CharacterStateHelper.get_look_input(input_extension, status_extension, inventory_extension, is_3p)
	
	if mode == "focal_length" then --replaced "look_delta = look_delta * look_sensitivity" with this.
		if status_extension:is_zooming() then --only apply coefficient if zooming
			look_delta = look_delta * math.tan(fieldOfView/2) * sensMult * coef
		else
			look_delta = look_delta * math.tan(fieldOfView/2) * sensMult --makes sensitivity scale by the tangent of FOV instead of just by FOV. Again, sensMult is to offset the change in hipfire sensitivity so it's the same as vanilla.
		end
	else
		look_delta = look_delta * math.atan(coef*math.tan(look_sensitivity/2)) * sensMult --makes sensivivity scale by a different FOV aspect ratio. E.g. 177.78% coefficient would be scaling by horizontal FOV since 16/9 is 1.78. Or 133.33% works like CS:GO etc.
	end

	if override_delta then
		look_delta = look_delta + override_delta
	end

	first_person_extension:set_look_delta(look_delta)
end)


--[[
	Callbacks
--]]

-- All callbacks are called even when the mod is disabled
-- Use mod:is_enabled() to check that the mod is enabled

-- Called on every update to mods
-- dt - time in milliseconds since last update
mod.update = function(dt)
	
end

-- Called when all mods are being unloaded
-- exit_game - if true, game will close after unloading
mod.on_unload = function(exit_game)
	
end

-- Called when game state changes (e.g. StateLoading -> StateIngame)
-- status - "enter" or "exit"
-- state  - "StateLoading", "StateIngame" etc.
mod.on_game_state_changed = function(status, state)
	update_mode()
	update_sensMult()
end

-- Called when a setting is changed in mod settings
-- Use mod:get(setting_name) to get the changed value
mod.on_setting_changed = function(setting_name)
	update_mode()
	update_sensMult()
end

-- Called when the checkbox for this mod is unchecked
-- is_first_call - true if called right after mod initialization
mod.on_disabled = function(is_first_call)

end

-- Called when the checkbox for this is checked
-- is_first_call - true if called right after mod initialization
mod.on_enabled = function(is_first_call)

end


--[[
	Initialization
--]]

-- Initialize and make permanent changes here
