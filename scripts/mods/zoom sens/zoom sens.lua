local mod = get_mod("zoom sens")
local status_extension = ScriptUnit.extension(owner_unit, "status_system")

local mode
local coef

-- "Private" function - not accessible to other mods

local function update_mode()
	if mod:get("scaling_method") == "zoom_ratio" then
		mode = 1
	elseif mod:get("scaling_method") == "monitor_distance" then
		mode = 2
	end
	coef = mod:get("coefficient") / 100
end

--[[
	Hooks
--]]

mod:hook_origin(CharacterStateHelper, "look", function (input_extension, viewport_name, first_person_extension, status_extension, inventory_extension, override_sens, override_delta)
	local camera_manager = Managers.state.camera
	local fieldOfView = override_sens or (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1 --modified "look_sensitivity" equation which is originally just fov / 0.785. So I removed the "/ 0.785"
	local configFOV = Application.user_setting("render_settings", "fov") * math.pi / 180 -- gets configured FOV in radians
	local is_3p = false
	local look_delta = CharacterStateHelper.get_look_input(input_extension, status_extension, inventory_extension, is_3p)
	look_delta = look_delta * fieldOfView / 0.785 -- default scaling, moved the '/ 0.785' to here.

	if status_extension:is_zooming() then -- only apply new scaling in ADS
		look_delta = look_delta * configFOV / fieldOfView -- undoes vanilla scaling
		if mode == 1 then
			look_delta = look_delta * math.tan(fieldOfView/2) / math.tan(configFOV/2) * coef
		elseif mode == 2 then
			look_delta = look_delta * math.atan(coef*math.tan(fieldOfView/2)) / math.atan(coef*math.tan(configFOV/2))
		end
	end

	if override_delta then
		look_delta = look_delta + override_delta
	end

	first_person_extension:set_look_delta(look_delta)
end)

--[[
	Callbacks
--]]

-- Called when game state changes (e.g. StateLoading -> StateIngame)
-- status - "enter" or "exit"
-- state  - "StateLoading", "StateIngame" etc.

mod.on_game_state_changed = function(status, state)
	update_mode()
end

-- Called when a setting is changed in mod settings
-- Use mod:get(setting_name) to get the changed value

mod.on_setting_changed = function(setting_name)
	update_mode()
end
