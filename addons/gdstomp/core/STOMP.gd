class_name STOMP
extends RefCounted

static func over_tcp() -> STOMPClient:
	return STOMPClient.new(TcpSTOMPConnection.new())

static func over_websockets(handshake_headers: PackedStringArray = [], tls: TLSOptions = null) -> STOMPClient:
	return STOMPClient.new(WebSTOMPConnection.new(handshake_headers, tls))
