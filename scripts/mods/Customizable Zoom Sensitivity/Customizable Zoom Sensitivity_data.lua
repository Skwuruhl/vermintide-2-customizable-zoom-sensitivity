local mod = get_mod("Customizable Zoom Sensitivity")

-- Everything here is optional. You can remove unused parts.
return {
	name = "Customizable Zoom Sensitivity",                               -- Readable mod name
	description = mod:localize("mod_description"),  -- Mod description
	is_togglable = false,                            -- If the mod can be enabled/disabled
	is_mutator = false,                             -- If the mod is mutator
	mutator_settings = {},                          -- Extra settings, if it's mutator
	options_widgets = {                             -- Widget settings for the mod options menu
		{
			["setting_name"] = "scaling_method",
			["widget_type"] = "dropdown",
			["text"] = mod:localize("scaling_method_name"),
			["tooltip"] = mod:localize("scaling_method_tooltip"),
			["options"] = {
				{text = mod:localize("setting_zoom"),		value = "zoom"},
				{text = mod:localize("setting_fov"),		value = "fov"},
			},
			["default_value"] = "zoom"
		},
		{
			["setting_name"] = "fov_ratio_coef",
			["widget_type"] = "numeric",
			["text"] = mod:localize("fov_ratio_coef_name"),
			["tooltip"] = mod:localize("fov_ratio_coef_tooltip"),
			["unit_text"] = "%",
			["range"] = {1, 300},
			["default_value"] = 100
		}
	}
}