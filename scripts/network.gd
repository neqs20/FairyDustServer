extends Node


const SIGNALS := {
	"network_peer_connected" : "peer_connected",
	"network_peer_disconnected" : "peer_disconnected",
	"peer_packet" : "on_peer_packet",
}

const CLIENTS := {}
const UDP_PORT := 4444

var _server := ENetNode.new()
var _server_peer := ENetPacketPeer.new()
var net_queue := ThreadQueue.new()


func _enter_tree() -> void:
	Logger.info("Starting up the server")

	_server_peer.create_server(UDP_PORT, 2)

	_server.set_network_peer(_server_peer)
	_server.poll_mode = ENetNode.MODE_PHYSICS
	_server.signal_mode = ENetNode.MODE_PHYSICS

	for signal_name in SIGNALS:
		if not _server.is_connected(signal_name, self, SIGNALS[signal_name]):
			_server.connect(signal_name, self, SIGNALS[signal_name])

	add_child(_server)

	net_queue.connect("done", self, "process_packet")
	add_child(net_queue)


func on_peer_packet(id: int, channel: int, raw_packet: PoolByteArray) -> void:
	if raw_packet.empty():
		return
	var packet := raw_packet.get_string_from_utf8()
	if packet.length() < Packet.LENGTH:
		return
	var type = packet.lcut(2)
	match type:
		Packet.LOGIN:
			net_queue.start(DataBase, "find_user", [packet.lcut(get_int(packet.lcut(2))), packet], 
					{"id":id,"type":type,"channel":channel})
		Packet.BASIC_CHAR_DATA:
			if is_logged_in(id):
				net_queue.start(DataBase, "get_characters", [CLIENTS[id]["real_id"]], 
						{"id":id,"type":type,"channel":channel})
		Packet.FULL_CHAR_DATA:
			var character = DataBase.get_character(CLIENTS[id]['real_id'], packet)
		_:
			Logger.info("Unhandled packet. Data: {0}", [packet])


func send_tcp(id: int, packet: PoolByteArray, channel: int) -> void:
	_server.send(id, packet, channel)


func send_udp(id: int, packet: PoolByteArray, channel: int) -> void:
	_server.send_unreliable(id, packet, channel)


func broadcast_tcp(packet: PoolByteArray, channel: int, exclude := []) -> void:
	for client in CLIENTS:
		if client in exclude:
			continue
		send_tcp(client, packet, channel)


func broadcast_udp(packet: PoolByteArray, channel: int, exclude := []) -> void:
	for client in CLIENTS:
		if client in exclude:
			continue
		send_udp(client, packet, channel)


func peer_connected(id: int) -> void:
	print("Connected %d" % id)
	CLIENTS[id] = {}


func peer_disconnected(id: int) -> void:
	print("Disconneted %d" % id)
	CLIENTS.erase(id)


func is_logged_in(id: int) -> bool:
	return CLIENTS[id].has("real_id")


func process_packet(result, custom_data) -> void:
	match custom_data["type"]:
		Packet.LOGIN:
			var response = "1"
			if result > 0:
				CLIENTS[custom_data["id"]]["real_id"] = result
				response = "0"
			send_udp(custom_data["id"], (custom_data["type"] + response).to_ascii(), custom_data["channel"])
		Packet.BASIC_CHAR_DATA:
			for i in result:
				send_tcp(custom_data["id"], (custom_data["type"] + hex(i["map"], 2)
						+ hex(i["level"], 2) + hex(i["class"], 1) + i["name"]).to_utf8(), custom_data["channel"])
			send_tcp(custom_data["id"], custom_data["type"].to_utf8(), custom_data["channel"])
