extends Node

var commands = preload("res://Scripts/Commands.gd").new()

# Keeps track of every runned command
var history = [""] 
var history_index = -1


func _init():
	pass

func _enter_tree():
	pass


func _ready():
	pass


func execute(line : String):
	var command_parts = Array(line.split(" ", false))
	if command_parts.size() <= 0:
		return
	var command = command_parts[0]
	if commands.list.has(command):
		command_parts.remove(0)
		if commands.list.get(command).get("args").size() == command_parts.size():
			var flag = false
			for i in range(commands.list.get(command).get("args").size()):
				var type = commands.list.get(command).get("args").values()[i]
				match type:
					commands.TYPE.COMMAND:
						if not commands.list.has(command_parts[i]):
							Log.warn("Argument '{0}' is not a type of Command", [command_parts[i]])
							commands.callv(commands.list.get("help").get("target"), [""])
							flag = true
							break
					commands.TYPE.INTEGER:
						command_parts[i] = int(command_parts[i])
			if not flag:
				commands.callv(commands.list.get(command).get("target"), command_parts)
		else:
			commands.callv(commands.list.get("help").get("target"), [command])
	else:
		Log.warn("Unknown command {0}. Type 'help' to list all available commands", [command])
	
	

func get_next():
	history_index += 1
	history_index = int(clamp(history_index, 0, history.size() - 1))
	return history[history_index]


func get_prev():
	history_index -= 1
	history_index = int(clamp(history_index, 0, history.size() - 1))
	return history[history_index]

func predict(text : String) -> String:
	var best_match = ""
	for i in history:
		if not text.empty() and i.begins_with(text):
			if i == text:
				continue
			best_match = i
	return best_match


func list_similar(text : String):
	var list = []
	for i in commands.list:
		if not text.empty() and i.begins_with(text):
			list.append(i)
	return list


func _exit_tree():
	commands.free()
	pass
