extends Node

var exec_path : String = OS.get_executable_path().get_base_dir()


var tables = ["users", "characters", "inventories", "items"]

var users = []
var characters = []
var inventories = []
var items = []
var blocking = false

var scheduled_saver = Thread.new()
var file = File.new()

func _init():
	var data_folder = Directory.new()
	if not data_folder.dir_exists("user://data/"):
		var error = data_folder.make_dir("user://data/")
		if error != OK:
			Log.error("Cannot create directory user://data/. Error code {0}", [error])
			return
	for table in tables:
		if file.file_exists("user://data/" + table + ".json"):
			file.open("user://data/" + table + ".json", File.READ_WRITE)
			var parsed = parse_json(file.get_as_text())
			if typeof(parsed) == TYPE_ARRAY:
				set(table, parsed)
			else:
				if file.get_len() == 0:
					Log.error("File {0}.json is empty", [table])
					file.store_line("[]")
				else:
					Log.error("File {0}.json isn't a proper json file", [table])
		else:
			file.open("user://data/" + table + ".json", File.WRITE)
		file.close()

func _ready():
	scheduled_saver.start(self, "scheduler", [1], Thread.PRIORITY_HIGH)

func scheduler(data):
	var timer = Timer.new()
	timer.set_timer_process_mode(Timer.TIMER_PROCESS_PHYSICS)
	timer.set_autostart(true)
	timer.connect("timeout", self, "save")
	add_child(timer)
	timer.start(data[0] * 60)

func save():
	blocking = true
	for table in tables:
		file.open("user://data/" + table + ".json", File.WRITE)
		var json = to_json(get(table))
		file.store_string(json)
		file.close()
	blocking = false


func _notification(what):
	if what == 19:
		if not blocking:
			if scheduled_saver.is_active():
				scheduled_saver.wait_to_finish()


func find_user(login : String, password : String):
	var found_users = []
	for i in range(users.size()):
		if users[i]['username'] == login:
			found_users.append(i)
	if found_users.size() == 1:
		if users[found_users[0]]['password'] == password:
			return users[found_users[0]]
		else:
			return 0
	else:
		return 2
