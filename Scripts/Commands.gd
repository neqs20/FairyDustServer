extends Node

enum TYPE { COMMAND, NODE, NODE_PATH, INTEGER, STRING, ANY }

var list = {
			"help" : {
				"description" : [ "Displays information about command", "Usage: help <command>" ],
				"args" : { "cmd" : TYPE.COMMAND },
				"target" : "show_help_for"
			},
			"quit" : {
				"description" : [ "Shuts down server" ],
				"args" : { "time" : TYPE.INTEGER },
				"target" : "shutdown"
			},
			"get" : {
				"description" : [ "Dumps variables", "Usage: get <variable>" ],
				"args" : { "name" : TYPE.STRING },
				"target" : "get_var"
			},
			"set" : {
				"description" : [ "Sets variable", "Usage: set <variable> <value>" ],
				"args" : { "name" : TYPE.STRING, "value" : TYPE.ANY },
				"target" : "set_var"
			},
			"adduser" : {
				"description" : [ "Adds new user to database", "Usage: adduser <login> <password>" ],
				"args" : { "login" : TYPE.STRING, "password" : TYPE.STRING },
				"target" : "add_user"
			},
			"listusers" : {
				"description" : [ "Lists all registered users" ],
				"args" : { },
				"target" : "listusers"
			}
}

func _init():
	validate_commands()

func validate_commands():
	for i in list:
		if not list[i].has_all(["description", "args", "target"]):
			if not typeof(list[i].get("args")) == TYPE_DICTIONARY:
				list.erase(i)
				Log.error("Arguments of '{0}' aren't properly formatted. Please make sure the value of 'args' is DICTIONRY({1})", [i, TYPE_DICTIONARY])
			Log.error("Command '{0}' isn't properly formatted. Please make sure to add desciption, args and target keys", [i])
			list.erase(i)


func shutdown(seconds : int):
	if seconds > 0:
		var timer = Timer.new()
		timer.connect("timeout", self, "shutdown", [0])
		Log.add_child(timer)
		timer.start(seconds)
		return
	Log.get_tree().quit()


func show_help_for(command : String):
	if list.has(command):
		for i in list.get(command).get("description"):
			Log.info(i)
	else:
		var temp = ""
		for i in list:
			temp += i + " "
		Log.print_raw(temp)

func get_var(varname : String):
	pass


func set_var(varname : String, value):
	Log.info("works {0} {1}", [varname, value])
	
func add_user(login : String, password : String):
	DB.add_user(login, password)

func listusers():
	Log.info(str(DB.users))
