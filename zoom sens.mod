return {
	run = function()
		fassert(rawget(_G, "new_mod"), "zoom sens must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("zoom sens", {
			mod_script       = "scripts/mods/zoom sens/zoom sens",
			mod_data         = "scripts/mods/zoom sens/zoom sens_data",
			mod_localization = "scripts/mods/zoom sens/zoom sens_localization"
		})
	end,
	packages = {
		"resource_packages/zoom sens/zoom sens"
	}
}
