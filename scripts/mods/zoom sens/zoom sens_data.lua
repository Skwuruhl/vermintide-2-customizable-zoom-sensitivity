local mod = get_mod("zoom sens")

-- Everything here is optional. You can remove unused parts.
return {
	name = "Customizable Zoom Sensitivity",			-- Readable mod name
	description = "mod_description",	-- Mod description
	is_togglable = false,							-- If the mod can be enabled/disabled
	is_mutator = false,								-- If the mod is mutator
	mutator_settings = {},							-- Extra settings, if it's mutator
	options = {										-- Widget settings for the mod options menu
		widgets = {
			{
				setting_id = "scaling_method",
				type = "dropdown",
				tooltip = "scaling_method_tooltip",
				options = {
					{text = "setting_zoom_ratio",			value = "zoom_ratio"},
					{text = "setting_monitor_distance",		value = "monitor_distance"},
				},
				default_value = "zoom_ratio"
			},
			{
				setting_id = "coefficient",
				type = "numeric",
				tooltip = "coefficient_tooltip",
				unit_text = "unit_percent",
				range = {1, 200},
				decimals_number = 2,
				default_value = 100
			}
		}
	}
}