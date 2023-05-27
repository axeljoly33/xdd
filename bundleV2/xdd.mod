return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`xdd` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("xdd", {
			mod_script       = "scripts/mods/xdd/xdd",
			mod_data         = "scripts/mods/xdd/xdd_data",
			mod_localization = "scripts/mods/xdd/xdd_localization",
		})
	end,
	packages = {
		"resource_packages/xdd/xdd",
	},
}
