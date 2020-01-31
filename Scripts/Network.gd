extends Node

enum PacketType { AUTH, POSITION, CHAT, LATENCY }
enum ChatType { GLOBAL, MAP, AREA, WHISPER, GROUP, YELL }

var clients = {}

var server_peer = ENetPacketPeer.new()
var server = ENetNode.new()

const PORT = 4666


func _ready():
	setup_server()


func on_peer_packet(id, channel, pkt):
	pkt = pkt.get_string_from_utf8()
	match get_int(pkt.lcut(2)):
		PacketType.POSITION:
			var x = get_float(pkt.lcut(16))
			var y = get_float(pkt.lcut(16))
			var z = get_float(pkt.lcut(16))
			Log.info("Pos: " + str(x) + " " + str(y) + " " + str(z))
		PacketType.CHAT:
			var chat_type = get_int(pkt.lcut(2))
			Log.info("It's {0}", [chat_type])
			match chat_type:
				ChatType.WHISPER:
					var target = get_int(pkt.lcut(16))
					Log.info("Target {0}", [target])
					var packet = hex(PacketType.CHAT, 2) + hex(ChatType.WHISPER, 2) + pkt
					Log.info("Packet: {0}", [packet])
					#check if target is connected
					send_tcp(target, packet.to_utf8(), channel)
		PacketType.AUTH:
			var result = DB.find_user(pkt.lcut(get_int(pkt.lcut(2))), pkt)
			if typeof(result) == TYPE_DICTIONARY:
				send_tcp(id, (hex(PacketType.AUTH, 2) + hex(1, 1)).to_utf8(), channel)
				print("found")
			else:
				send_tcp(id, (hex(PacketType.AUTH, 2) + hex(result, 1)).to_utf8(), channel)
	send_latency_packet(id, channel)

func send_latency_packet(target : int, channel : int):
	send_udp(target, (hex(PacketType.LATENCY, 2)).to_utf8(), channel)


func send_udp(target : int, packet : PoolByteArray, channel : int):
	server.send_unreliable(target, packet, channel)


func send_tcp(target : int, packet : PoolByteArray, channel : int):
	server.send_ordered(target, packet, channel)


func send(target : int, packet : PoolByteArray, channel : int):
	server.send(target, packet, channel)

func server_client_connect(id):
	Log.info("{0} - Connected", [id])
	clients[id] = {"world_id" : null}

func server_client_disconnect(id):
	Log.info("{0} - Disconnected", [id])
	clients.erase(id)
	

func setup_server():
	server.connect("network_peer_disconnected", self, "server_client_disconnect")
	server.connect("network_peer_connected", self, "server_client_connect")
	server.connect("peer_packet", self, "on_peer_packet")
	
	server.poll_mode = ENetNode.MODE_PHYSICS
	server.signal_mode = ENetNode.MODE_PHYSICS
	
	server_peer.create_server(PORT, 16) #default: channels = 16
	
	server.set_network_peer(server_peer)
	
	add_child(server)
