#ifndef NETWORK_H
#define NETWORK_H

#include <Dictionary.hpp>
#include <ENetNode.hpp>
#include <ENetPacketPeer.hpp>
#include <Godot.hpp>

namespace godot {

class Network : public Node {
	GODOT_CLASS(Network, Node);

private:
	int64_t port;
	Dictionary clients;
	ENetNode *server;
	Ref<ENetPacketPeer> peer;


	struct Packet {
        static const int length = 3;

		static constexpr const char s[length] = "00";
	};

public:
	void _enter_tree();

	void send_tcp(int p_id, int p_channel, PoolByteArray p_packet);
	void send_udp(int p_id, int p_channel, PoolByteArray p_packet);

	void broadcast_tcp(int p_channel, PoolByteArray p_packet, PoolIntArray p_exclude);
	void broadcast_udp(int p_channel, PoolByteArray p_packet, PoolIntArray p_exclude);
	Network();
	~Network();

private:
	void on_peer_packet(int p_id, int p_channel, PoolByteArray p_packet);
	void peer_connected(int p_id);
	void peer_disconnected(int p_id);

	void process_packet(Variant p_result, Dictionary p_data);
};

} // namespace godot

#endif // NETWORK_H