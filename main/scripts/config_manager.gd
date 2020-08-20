extends Node


var settings := Settings.new()

func _enter_tree() -> void:
	add_child(settings)

