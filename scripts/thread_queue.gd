class_name ThreadQueue
extends Node


signal done(result, custom_data)

var thread: Thread = null

var queue := []


func _ready() -> void:
	connect("done", self, "_done", [], CONNECT_DEFERRED)


func _physics_process(delta) -> void:
	if thread == null:
		return
	if not thread.is_active() and not queue.empty():
		var call = queue.pop_front()
		initialize(call["node"], call["callback"], call["parameters"], call["custom_data"])

func start(node: Node, callback: String, parameters: Array, custom_data: Dictionary) -> void:
	if not thread == null:
		if thread.is_active():
			queue.push_back({"node":node,"callback":callback,"parameters":parameters,"custom_data":custom_data})
			return
	initialize(node, callback, parameters, custom_data)


func initialize(node: Node, callback: String, data: Array, custom_data: Dictionary) -> void:
	thread = Thread.new()
	thread.start(self, "_thread_callback", [node, callback, data, custom_data])


func _thread_callback(data) -> void:
	emit_signal("done", data[0].callv(data[1], data[2]), data[3])


func _done(result, custom_data) -> void:
	thread.wait_to_finish()

