class_name WebSTOMPConnection
extends STOMPConnection

signal start_connecting()
signal opened()

signal start_closing()
signal closed()

var state: int = -1
var peer: WebSocketPeer = WebSocketPeer.new()
var tls: TLSOptions

func _init(tls: TLSOptions = null) -> void:
	self.tls = tls

func connect_to_host(url: String) -> int:
	return peer.connect_to_url(url)

func close(code: int = 1000, reason: String = "") -> void:
	peer.close(code, reason)

func poll() -> void:
	peer.poll()
	var next_state: int = peer.get_ready_state()
	
	if next_state != state:
		_change_state_to(next_state)
	
	if state == peer.STATE_OPEN:
		_receive_bytes()

func send(packet: PackedByteArray) -> int:
	return peer.put_packet(packet)

func _change_state_to(next_state: int) -> void:
	state = next_state
	match state:
		peer.STATE_CONNECTING:
			start_connecting.emit()
		peer.STATE_OPEN:
			opened.emit()
			connected.emit()
		peer.STATE_CLOSING:
			start_closing.emit()
		peer.STATE_CLOSED:
			closed.emit()
			disconnected.emit()

func _receive_bytes() -> void:
	var available_packets: int = peer.get_available_packet_count()
	if available_packets > 0:
		var packet: PackedByteArray = peer.get_packet()
		received.emit(packet)
