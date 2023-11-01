class_name TcpSTOMPConnection
extends STOMPConnection

signal start_connecting()
signal error(code: int)

var status: int = 0
var stream: StreamPeerTCP = StreamPeerTCP.new()

func connect_to_host(address: String) -> int:
	status = stream.STATUS_NONE
	var splitten: PackedStringArray = address.split(":")
	var host: String = splitten[0]
	var port: int = int(splitten[1])
	return stream.connect_to_host(host, port)

func send(bytes: PackedByteArray) -> int:
	return stream.put_data(bytes)

func poll() -> void:
	stream.poll()
	var next_status: int = stream.get_status()
	
	if next_status != status:
		_change_status_to(next_status)
	
	if status == stream.STATUS_CONNECTED:
		_receive_bytes()

func close(code: int = 1000, reason: String = "") -> void:
	stream.disconnect_from_host()

func _change_status_to(next_status: int) -> void:
	status = next_status
	match status:
		stream.STATUS_NONE:
			disconnected.emit()
		stream.STATUS_CONNECTING:
			start_connecting.emit()
		stream.STATUS_CONNECTED:
			connected.emit()
		stream.STATUS_ERROR:
			error.emit(FAILED)

func _receive_bytes() -> void:
	const ERROR_INDEX: int = 0
	const PACKET_INDEX: int = 1
	
	var available_bytes: int = stream.get_available_bytes()
	if available_bytes > 0:
		var data: Array = stream.get_partial_data(available_bytes)
		if (data[ERROR_INDEX] != OK):
			error.emit(data[ERROR_INDEX])
		else:
			for packet in _create_packets_from(data[PACKET_INDEX]):
				received.emit(packet)

func _create_packets_from(bytes: PackedByteArray) -> Array[PackedByteArray]:
	const NULL: int = 0
	const LINE_FEED: int = 10
	
	var result: Array[PackedByteArray]
	var head: int = 0
	
	for pointer in bytes.size() - 1:
		if bytes[pointer] == NULL && bytes[pointer + 1] == LINE_FEED:
			pointer += 2
			var raw_packet: PackedByteArray = bytes.slice(head, pointer)
			head += raw_packet.size()
			result.append(raw_packet)
	
	return result
