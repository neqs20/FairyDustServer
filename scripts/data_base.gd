extends Node

var _mysql := MySQL.new()

var prefix: String

const query := {
	"database_create" : "CREATE SCHEMA IF NOT EXISTS `{prefix}{database}`",
	"users_table_create" : "CREATE TABLE IF NOT EXISTS {prefix}users ({prefix}id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, {prefix}login varchar(32) NOT NULL, {prefix}password char(64) NOT NULL)",
	"characters_table_create" : "CREATE TABLE IF NOT EXISTS {prefix}characters ({prefix}id INT NOT NULL PRIMARY KEY AUTO_INCREMENT, {prefix}user_id INT NOT NULL, {prefix}name varchar(20) NOT NULL, {prefix}map INT NOT NULL, {prefix}level INT NOT NULL, {prefix}class INT NOT NULL, FOREIGN KEY ({prefix}user_id) REFERENCES {prefix}users({prefix}id))",
	
	"select_user" : "SELECT {prefix}id FROM {prefix}users WHERE {prefix}login=? AND {prefix}password=?",
	"select_characters" : "SELECT {prefix}name, {prefix}class, {prefix}level, {prefix}map FROM {prefix}characters WHERE {prefix}user_id=?",
	"select_character" : "SELECT * FROM {prefix}characters WHERE {prefix}user_id=? AND {prefix}name=?"
}


func _enter_tree():
	prefix = ConfigManager.settings.get_prefix()
	_replace_placeholders()


func _ready() -> void:
	_mysql.set_credentials(ConfigManager.settings.get_ip(), ConfigManager.settings.get_username(), ConfigManager.settings.get_password())
	_mysql.connection_start()
	# DataBase setup
	_mysql.query_execute(query['database_create'])
	_mysql.set_database(ConfigManager.settings.get_schema())
	_mysql.query_execute(query['users_table_create'])
	_mysql.query_execute(query['characters_table_create'])


func find_user(login: String, password: String) -> int:
	var result = _mysql.prep_fetch_dictionary(query['select_user'], [login, password], false)
	if result.size() > 0 and result.size() < 2:
		return result[0][prefix + 'id']
	return 0


func get_characters(id: int) -> Array:
	return _mysql.prep_fetch_dictionary(query['select_characters'], [id], false)


func get_character(id: int, name: String) -> Array:
	return _mysql.prep_fetch_dictionary(query['select_character'], [id, name], false)


func _replace_placeholders() -> void:
	for q in query:
		query[q] = query[q].replace("{prefix}", prefix)
	query['database_create'] = query['database_create'].replace("{database}", ConfigManager.settings.get_schema())


func _exit_tree() -> void:
	if _mysql.connection_check():
		_mysql.connection_close()
