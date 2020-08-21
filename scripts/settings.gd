class_name Settings extends AbstractConfig


const _PATH := "user://settings.ini"

var _config := ConfigFile.new()


func _enter_tree():
	._load_file(_config, _PATH)
	._save_file(_config, _PATH)

func get_prefix() -> String:
	return ._get_value(_config, "DATABASE", "prefix", "")


func get_ip() -> String:
	return ._get_value(_config, "DATABASE", "ip", "127.0.0.1")


func get_schema() -> String:
	return ._get_value(_config, "DATABASE", "schema", "fairy_dust")


func get_username() -> String:
	return ._get_value(_config, "DATABASE", "username", "root")


func get_password() -> String:
	return ._get_value(_config, "DATABASE", "password", "1234")
