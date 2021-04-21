local mod = get_mod("zoom sens")
local status_extension = ScriptUnit.extension(owner_unit, "status_system")

local sensMult = 1.0
local mode = mod:get("scaling_method")
local coef = 1.0

-- "Private" function - not accessible to other mods

local function update_mode()
	if mod:get("scaling_method") == "zoom_ratio" then
		mode = 1
	else
		mode = 2
	end
	coef = mod:get("coefficient") / 100.0
end

local update_sensMult = {
	function()
		local configFOV = Application.user_setting("render_settings", "fov") * math.pi / 180 -- gets configured FOV in radians
		sensMult = configFOV / 0.785 / math.tan(configFOV/2) -- calculates a sensitivity multiplier to make starting (1x) zoom the same as without the mod.
	end,
	function()
		local configFOV = Application.user_setting("render_settings", "fov") * math.pi / 180
		sensMult = configFOV / 0.785 / math.atan(coef*math.tan(configFOV/2)) -- same thing but for the 2nd scaling method
	end
}

local scalingMethod = {
	[1] = function(fov)	-- zoom ratio
		return math.tan(fov/2) * coef * sensMult
	end,
	[2] = function(fov)	-- monitor distance
		return math.atan(coef*math.tan(fov/2)) * sensMult
	end
}

--[[
	Hooks
--]]

mod:hook_origin(CharacterStateHelper, "look", function (input_extension, viewport_name, first_person_extension, status_extension, inventory_extension, override_sens, override_delta)
	local camera_manager = Managers.state.camera
	local fieldOfView = override_sens or (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1 --modified "look_sensitivity" equation which is originally just fov / 0.785. So I removed the "/ 0.785"
	local is_3p = false
	local look_delta = CharacterStateHelper.get_look_input(input_extension, status_extension, inventory_extension, is_3p)
	
	if status_extension:is_zooming() then -- only apply new scaling in ADS
		look_delta = look_delta * scalingMethod[mode](fieldOfView)
	else
		look_delta = look_delta * fieldOfView / 0.785 -- default scaling
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
	update_sensMult[mode]()
end

-- Called when a setting is changed in mod settings
-- Use mod:get(setting_name) to get the changed value

mod.on_setting_changed = function(setting_name)
	update_mode()
	update_sensMult[mode]()
end
