local mod = get_mod("zoom sens")

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
				{text = mod:localize("setting_focal_length"),		value = "focal_length"},
				{text = mod:localize("setting_aspect_ratio"),		value = "aspect_ratio"},
			},
			["default_value"] = "focal_length"
		},
		{
			["setting_name"] = "coefficient",
			["widget_type"] = "numeric",
			["text"] = mod:localize("coefficient_name"),
			["tooltip"] = mod:localize("coefficient_tooltip"),
			["unit_text"] = "%",
			["range"] = {1, 200},
			["decimals_number"] = 2,
			["default_value"] = 100
		}
	}
}