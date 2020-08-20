#include "network.h"

#include "logger.h"

using namespace godot;

void Network::_enter_tree() {
	Logger::get_singleton()->info("Starting up the server");

	peer->create_server(port, 2);

	server->set_network_peer(peer);
	server->set_poll_mode(ENetNode::NetProcessMode::MODE_PHYSICS);
	server->set_signal_mode(ENetNode::NetProcessMode::MODE_PHYSICS);

	server->connect("network_peer_connected", this, "peer_connected");
	server->connect("network_peer_disconnected", this, "peer_disconnected");
	server->connect("peer_packet", this, "on_peer_packet");

	add_child(server);

	// network_queue.connect("done", this, "process_packet");
	// add_child(network_queue);
}

void Network::on_peer_packet(int p_id, int p_channel, PoolByteArray p_packet) {
    String packet((const char *) p_packet.read().ptr());
    if (packet.length() < Packet::length) {

    }
}
void Network::peer_connected(int p_id) {}

void Network::peer_disconnected(int p_id) {}

void Network::process_packet(Variant p_result, Dictionary p_data) {}

void Network::send_tcp(int p_id, int p_channel, PoolByteArray p_packet) {}

void Network::send_udp(int p_id, int p_channel, PoolByteArray p_packet) {}

void Network::broadcast_tcp(int p_channel, PoolByteArray p_packet,
		PoolIntArray p_exclude) {}

void Network::broadcast_udp(int p_channel, PoolByteArray p_packet,
		PoolIntArray p_exclude) {}

Network::Network() {
	server = ENetNode::_new();
	port = 4444;
}

Network::~Network() {}