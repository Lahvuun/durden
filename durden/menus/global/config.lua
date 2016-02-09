local durden_font = {
	{
		name = "durden_font_sz",
		label = "Size",
		kind = "value";
		validator = gen_valid_num(1, 100),
		initial = function() return tostring(gconfig_get("font_sz")); end,
		handler = function(ctx, val)
			gconfig_set("font_sz", tonumber(val));
		end
	},
	{
		name = "durden_font_hinting",
		label = "Hinting",
		kind = "value",
		validator = gen_valid_num(0, 3);
		initial = function() return gconfig_get("font_hint"); end,
		handler = function(ctx, val)
			gconfig_set("font_hint", tonumber(val));
		end
	},
	{
		name = "durden_font_name",
		label = "Font",
		kind = "value",
		set = function()
			local set = glob_resource("*", SYS_FONT_RESOURCE);
			set = set ~= nil and set or {};
			return set;
		end,
		initial = function() return gconfig_get("font_def"); end,
		handler = function(ctx, val)
			gconfig_set("font_def", val);
		end
	}
};

local durden_visual = {
-- thickness is dependent on area, make sure the labels and
-- constraints update dynamically
	{
		name = "default_font",
		label = "Font",
		kind = "action",
		submenu = true,
		handler = durden_font
	},
	{
		name = "border_thickness",
		label = "Border Thickness",
		kind = "value",
		hint = function() return
			string.format("(0..%d)", gconfig_get("borderw")) end,
		validator = function(val)
			return gen_valid_num(0, gconfig_get("borderw"))(val);
		end,
		initial = function() return tostring(gconfig_get("bordert")); end,
		handler = function(ctx, val)
			local num = tonumber(val);
			gconfig_set("bordert", tonumber(val));
			active_display():rebuild_border();
			for k,v in pairs(active_display().spaces) do
				v:resize();
			end
		end
	},
	{
		name = "border_area",
		label = "Border Area",
		kind = "value",
		hint = "(0..20)",
		inital = function() return tostring(gconfig_get("borderw")); end,
		validator = gen_valid_num(0, 20),
		handler = function(ctx, val)
			gconfig_set("borderw", tonumber(val));
			active_display():rebuild_border();
			for k,v in pairs(active_display().spaces) do
				v:resize();
			end
		end
	},
	{
		name = "config_mouse_scale",
		label = "Mouse Scale",
		kind = "value",
		hint = "(0.1 .. 10.0)",
		initial = function() return tostring(gconfig_get("mouse_scalef")); end,
		handler = function(ctx, val)
			gconfig_set("mouse_scalef", tonumber(val));
			display_cycle_active(true);
		end
	},
	{
		name = "transition_speed",
		label = "Animation Speed",
		kind = "value",
		hint = "(1..100)",
		validator = gen_valid_num(1, 100),
		initial = function() return tostring(gconfig_get("transition")); end,
		handler = function(ctx, val)
			gconfig_set("transition", tonumber(val));
		end
	},
	{
		name = "transition_in",
		label = "In-Animation",
		kind = "value",
		set = {"none", "fade", "move-h", "move-v"},
		initial = function() return tostring(gconfig_get("ws_transition_in")); end,
		handler = function(ctx, val)
			gconfig_set("ws_transition_in", val);
		end
	},
	{
		name = "transition_out",
		label = "Out-Animation",
		kind = "value",
		set = {"none", "fade", "move-h", "move-v"},
		initial = function() return tostring(gconfig_get("ws_transition_out")); end,
		handler = function(ctx, val)
			gconfig_set("ws_transition_out", val);
		end
	},
};

local durden_workspace = {
	{
		name = "durden_ws_autodel",
		label = "Autodelete",
		kind = "value",
		set = {LBL_YES, LBL_NO},
		initial = function() return tostring(gconfig_get("ws_autodestroy")); end,
		handler = function(ctx, val)
			gconfig_set("ws_autodestroy", val == LBL_YES);
		end
	},
	{
		name = "durden_ws_defmode",
		label = "Default Mode",
		kind = "value",
		set = {"tile", "tab", "vtab", "float"},
		initial = function() return tostring(gconfig_get("ws_default")); end,
		handler = function(ctx, val)
			gconfig_set("ws_default", val);
		end
	},
	{
		name = "durden_ws_autoadopt",
		label = "Autoadopt",
		kind = "value",
		set = {LBL_YES, LBL_NO},
		eval = function() return gconfig_get("display_simple") == false; end,
		initial = function() return tostring(gconfig_get("ws_autoadopt")); end,
		handler = function(ctx, val)
			gconfig_set("ws_autoadopt", val == LBL_YES);
		end
	}
};

local durden_system = {
	{
		name = "system_connpath",
		label = "Connection Path",
		kind = "value",
		validator = function(num) return true; end,
		initial = function() local path = gconfig_get("extcon_path");
			return path == "" and "[disabled]" or path;
		end,
		handler = function(ctx, val)
			if (valid_vid(INCOMING_ENDPOINT)) then
				delete_image(INCOMING_ENDPOINT);
				INCOMING_ENDPOINT = nil;
			end
			gconfig_set("extcon_path", val);
			new_connection();
		end
	}
};

local config_terminal_font = {
	{
		name = "terminal_font_sz",
		label = "Size",
		kind = "value",
		validator = gen_valid_num(1, 100),
		initial = function() return tostring(gconfig_get("term_font_sz")); end,
		handler = function(ctx, val)
			gconfig_set("term_font_sz", tonumber(val));
		end
	},
	{
		name = "terminal_font_hinting",
		label = "Hinting",
		kind = "value",
		set = {"light", "mono", "none"},
		initial = function() return gconfig_get("term_font_hint"); end,
		handler = function(ctx, val)
			gconfig_set("term_hint", tonumber(val));
		end
	},
-- should replace with some "font browser" but we don't have asynch font
-- loading etc. and no control over cache size
	{
		name = "terminal_font_name",
		label = "Name",
		kind = "value",
		set = function()
			local set = glob_resource("*", SYS_FONT_RESOURCE);
			set = set ~= nil and set or {};
			table.insert(set, "BUILTIN");
			return set;
		end,
		initial = function() return gconfig_get("term_font"); end,
		handler = function(ctx, val)
			gconfig_set("term_font", val == "BUILTIN" and "" or val);
		end
	}
};

local config_terminal = {
	{
		name = "terminal_bgalpha",
		label = "Background Alpha",
		kind = "value",
		hint = "(0..1)",
		validator = gen_valid_float(0, 1),
		initial = function() return tostring(gconfig_get("term_opa")); end,
		handler = function(ctx, val)
			gconfig_set("term_opa", tonumber(val));
		end
	},
	{
		name = "terminal_font",
		label = "Font",
		kind = "action",
		submenu = true,
		handler = config_terminal_font
	}
};

return {
	{
		name = "config_visual",
		label = "Visual",
		kind = "action",
		submenu = true,
		hint = "Visual:",
		handler = durden_visual
	},
	{
		name = "config_workspaces",
		label = "Workspaces",
		kind = "action",
		submenu = true,
		hint = "Config Workspaces:",
		handler = durden_workspace
	},
	{
		name = "config_system",
		label = "System",
		kind = "action",
		submenu = true,
		hint = "Config System:",
		handler = durden_system
	},
	{
		name = "config_terminal",
		label = "Terminal",
		kind = "action",
		submenu = true,
		eval = function()
			return string.match(FRAMESERVER_MODES, "terminal") ~= nil;
		end,
		handler = config_terminal
	}
};
