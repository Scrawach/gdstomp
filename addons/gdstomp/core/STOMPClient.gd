class_name STOMPClient
extends RefCounted

const BODY_SEPARATOR: String = "\n\n"

signal received(packet: STOMPPacket)

var connection: STOMPConnection
var callbacks: Dictionary

func _init(socket: STOMPConnection) -> void:
	self.connection = socket

func connect_to_host(address: String) -> int:
	if !connection.received.is_connected(_on_received_bytes):
		connection.received.connect(_on_received_bytes)
	return connection.connect_to_host(address)

func poll() -> void:
	connection.poll()

func subscribe(path: String, id: String) -> int:
	return send(STOMPPacket.subscribe(path, id))

func unsubscribe(id: String) -> int:
	return send(STOMPPacket.unsubscribe(id))

func ack(id: String, transaction: String = "") -> int:
	return send(STOMPPacket.ack(id, transaction))

func nack(id: String, transaction: String = "") -> int:
	return send(STOMPPacket.nack(id, transaction))

func begin(transaction: String) -> int:
	return send(STOMPPacket.begin(transaction))

func commit(transaction: String) -> int:
	return send(STOMPPacket.commit(transaction))

func abort(transaction: String) -> int:
	return send(STOMPPacket.abort(transaction))

func send_connection(login: String, passcode: String, host: String = "/") -> int:
	return send(STOMPPacket.connection(host, login, passcode))

func send_disconnection(receipt: int = 77) -> int:
	return send(STOMPPacket.disconnection(receipt))

func send(packet: STOMPPacket) -> int:
	return send_raw(packet.command, packet.headers, packet.body)

func send_raw(command: String, headers: Dictionary, body: String) -> int:
	var bytes: PackedByteArray = _pack_message(command, headers, body)
	return connection.send(bytes)

func listen(path: String, callback: Callable) -> void:
	if not callbacks.has(path):
		callbacks[path] = Array()
	if not callbacks[path].has(callback):
		callbacks[path].append(callback)

func unlisten(path: String, callback: Callable) -> void:
	if callbacks.has(path) && callbacks[path].has(callback):
		callbacks[path].erase(callback)

func close(code: int = 1000, reason: String = "") -> void:
	connection.close(code, reason)

func clear() -> void:
	callbacks.clear()
	connection.close()

func _on_received_bytes(bytes: PackedByteArray) -> void:
	var message: String = bytes.get_string_from_utf8()	
	var packet: STOMPPacket = _unpack_message(message)
	_invoke_listeners(packet)	
	received.emit(packet)

func _invoke_listeners(packet: STOMPPacket) -> void:
	const DESTINATION: String = "destination"
	
	if not packet.headers.has(DESTINATION):
		return
	
	var destination = packet.headers[DESTINATION]
	
	if callbacks.has(destination):
		for callback in callbacks[destination]:
			callback.call(packet)

func _unpack_message(message: String) -> STOMPPacket:
	var content = message.split(BODY_SEPARATOR)
	var packed_headers = content[0].split("\n")
	var command = packed_headers[0]
	var headers = _unpack_headers(packed_headers)
	var body = content[1]
	return STOMPPacket.new(command, headers, body)

func _unpack_headers(headers: PackedStringArray) -> Dictionary:
	const key_separator = ":"
	var unpacked_headers := Dictionary()
	for i in range(1, len(headers)):
		var separated_line: PackedStringArray = headers[i].split(key_separator)
		unpacked_headers[separated_line[0]] = separated_line[1]
	return unpacked_headers

func _pack_message(command: String, headers: Dictionary, body: String) -> PackedByteArray:
	var message: String = command + "\n" + _pack_headers(headers) + BODY_SEPARATOR + body
	var raw_bytes: PackedByteArray = message.to_utf8_buffer()
	raw_bytes.append(0)
	return raw_bytes

func _pack_headers(headers: Dictionary) -> String:
	var packed_headers := String()
	for key in headers:
		var line = "%s:%s\n" % [key, headers[key]]
		packed_headers += line
	return packed_headers.left(-1)
