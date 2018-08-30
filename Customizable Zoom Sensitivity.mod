return {
	run = function()
		fassert(rawget(_G, "new_mod"), "Customizable Zoom Sensitivity must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Customizable Zoom Sensitivity", {
			mod_script       = "scripts/mods/Customizable Zoom Sensitivity/Customizable Zoom Sensitivity",
			mod_data         = "scripts/mods/Customizable Zoom Sensitivity/Customizable Zoom Sensitivity_data",
			mod_localization = "scripts/mods/Customizable Zoom Sensitivity/Customizable Zoom Sensitivity_localization"
		})
	end,
	packages = {
		"resource_packages/Customizable Zoom Sensitivity/Customizable Zoom Sensitivity"
	}
}
