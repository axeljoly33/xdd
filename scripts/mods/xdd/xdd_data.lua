local mod = get_mod("xdd")

return {
	name = "xdd",
	description = mod:localize("mod_description"),
	is_togglable = true,
    options = {
		widgets = {
            {
                setting_id    = "hat",
                type          = "checkbox",
                default_value = false
            }
        }
    }
}
