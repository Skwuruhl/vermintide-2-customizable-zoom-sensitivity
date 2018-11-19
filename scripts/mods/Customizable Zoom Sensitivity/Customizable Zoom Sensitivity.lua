local mod = get_mod("Customizable Zoom Sensitivity")
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
	sensMult = Application.user_setting("render_settings", "fov") * math.pi / 180
	if mode == "focal_length" then
		sensMult = 200/157 * sensMult / math.tan(sensMult/2)
	else
		sensMult = 200/157 * sensMult / math.atan(coef*math.tan(sensMult/2))
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
mod:hook_origin(CameraStateObserver, "update", function (self, unit, input, dt, context, t)
	local csm = self.csm
	local camera_extension = self.camera_extension
	local viewport_name = camera_extension.viewport_name
	local camera_manager = Managers.state.camera
	local input_source = Managers.input:get_service("Player")

	if input_source:get("next_observer_target") or not Unit.alive(self._follow_unit) then
		self:follow_next_unit()

		if not Unit.alive(self._follow_unit) then
			csm:change_state("idle")

			return
		end
	end

	local external_state_change = camera_extension.external_state_change

	if external_state_change and external_state_change ~= self.name then
		csm:change_state(external_state_change)
		camera_extension:set_external_state_change(nil)

		return
	end

	local rotation = Unit.local_rotation(unit, 0)
	local look_sensitivity = (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1
	local gamepad_active = Managers.input:is_device_active("gamepad")
	local look_input = (gamepad_active and input_source:get("look_controller_3p")) or input_source:get("look")
	local look_delta = Vector3(0, 0, 0)

	if look_input then
		if mode == "focal_length" then
			if status_extension:is_zooming() then
				look_delta = look_delta + look_input * math.tan(look_sensitivity/2) * sensMult * coef
				mod:echo("is zooming")
			else
				look_delta = look_delta + look_input * math.tan(look_sensitivity/2) * sensMult
				mod:echo("isn't zooming")
			end
		else
			look_delta = look_delta + look_input * math.atan(coef*math.tan(look_sensitivity/2)) * sensMult
		end
	end

	local yaw = Quaternion.yaw(rotation) - look_delta.x
	local pitch = math.clamp(Quaternion.pitch(rotation) + look_delta.y, -MAX_MIN_PITCH, MAX_MIN_PITCH)
	local yaw_rotation = Quaternion(Vector3.up(), yaw)
	local pitch_rotation = Quaternion(Vector3.right(), pitch)
	local look_rotation = Quaternion.multiply(yaw_rotation, pitch_rotation)

	Unit.set_local_rotation(unit, 0, look_rotation)

	local follow_unit = self._follow_unit
	local follow_node = Unit.node(follow_unit, self._follow_node_name)
	local position = Unit.world_position(follow_unit, follow_node)
	local previous_position = Unit.world_position(unit, 0)
	local new_position = Vector3.lerp(previous_position, position, dt * 10)

	if self._snap_camera then
		new_position = position
		self._snap_camera = false

		Managers.state.event:trigger("camera_teleported")
	end

	assert(Vector3.is_valid(new_position), "Camera position invalid.")
	Unit.set_local_position(unit, 0, new_position)
end)

mod:hook_origin(CharacterStateHelper, "look", function (input_extension, viewport_name, first_person_extension, status_extension, inventory_extension, override_sens, override_delta)
	local camera_manager = Managers.state.camera
	local look_sensitivity = override_sens or (camera_manager:has_viewport(viewport_name) and camera_manager:fov(viewport_name)) or 1
	local is_3p = false
	local look_delta = CharacterStateHelper.get_look_input(input_extension, status_extension, inventory_extension, is_3p)
	
	if mode == "focal_length" then
		if status_extension:is_zooming() then
			look_delta = look_delta * math.tan(look_sensitivity/2) * sensMult * coef
		else
			look_delta = look_delta * math.tan(look_sensitivity/2) * sensMult
		end
	else
		look_delta = look_delta * math.atan(coef*math.tan(look_sensitivity/2)) * sensMult
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
