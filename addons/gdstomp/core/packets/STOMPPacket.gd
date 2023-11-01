class_name STOMPPacket
extends RefCounted

var command: String
var headers: Dictionary
var body: String

func _init(command: String, headers: Dictionary, body: String = "") -> void:
	self.command = command
	self.headers = headers
	self.body = body

func _to_string() -> String:
	return "%s: %s, [%s]" % [command, headers, body]

func is_connected_message() -> bool:
	return command == "CONNECTED"

func is_message() -> bool:
	return command == "MESSAGE"

func is_error() -> bool:
	return command == "ERROR"

func add_header(header: String, value: String) -> STOMPPacket:
	headers[header] = value
	return self

func with_message(body: String) -> STOMPPacket:
	self.body = body
	return self

func with_correlation_id(value: String) -> STOMPPacket:
	return add_header("correlation-id", value)

func reply_to(path: String) -> STOMPPacket:
	return add_header("reply-to", path)

func with_transaction(transaction: String) -> STOMPPacket:
	headers["transaction"] = transaction
	return self

static func connection(host: String, login: String, passcode: String) -> STOMPPacket:
	var header = { 
		"accept-version": "1.2",
		"host": host,
		"login": login,
		"passcode": passcode
	}
	return STOMPPacket.new("CONNECT", header, "")

static func message(destination: String, body: String = "") -> STOMPPacket:
	var header = { "destination" : destination }
	return STOMPPacket.new("SEND", header, body)

static func to(destination: String) -> STOMPPacket:
	return STOMPPacket.message(destination)

static func subscribe(target: String, id: String, ack: String = "client") -> STOMPPacket:
	return STOMPPacket.new("SUBSCRIBE", { "id": id, "destination": target, "ack": ack})

static func unsubscribe(id: String) -> STOMPPacket:
	return STOMPPacket.new("UNSUBSCRIBE", { "id": id })

static func ack(id: String, transaction: String = "") -> STOMPPacket:
	var packet = STOMPPacket.new("ACK", {"id": id})
	return packet if transaction == "" else packet.with_transaction(transaction)

static func nack(id: String, transaction: String = "") -> STOMPPacket:
	var packet = STOMPPacket.new("NACK", {"id": id})
	return packet if transaction == "" else packet.with_transaction(transaction)

static func begin(transaction: String) -> STOMPPacket:
	return STOMPPacket.new("BEGIN", {"transaction": transaction})

static func commit(transaction: String) -> STOMPPacket:
	return STOMPPacket.new("COMMIT", {"transaction": transaction})

static func abort(transaction: String) -> STOMPPacket:
	return STOMPPacket.new("ABORT", {"transaction": transaction})

static func disconnection(receipt: int = 77) -> STOMPPacket:
	return STOMPPacket.new("DISCONNECT", {"receipt": 77})
