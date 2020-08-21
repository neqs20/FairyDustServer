class_name AbstractConfig extends Node

var is_loaded := false

func _load_file(cfg: ConfigFile, path: String) -> void:
	is_loaded =  cfg.load(path) == OK


func _get_value(cfg: ConfigFile, section: String, key: String, default):
	if is_loaded:
		var v = cfg.get_value(section, key, default)
		if typeof(v) == typeof(default):
			return v
	return default


func _set_value(cfg: ConfigFile, section: String, key: String, value) -> void:
	if is_loaded:
		cfg.set_value(section, key, value)


func _get_section_keys(cfg: ConfigFile, section: String):
	if is_loaded:
		return cfg.get_section_keys(section)
	return null

func _save_file(cfg: ConfigFile, path: String) -> void:
	if not cfg.save(path) == OK or not is_loaded:
		Logger.error("Cannot save configuration file @ '{0}'", [path])
