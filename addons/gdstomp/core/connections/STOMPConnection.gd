class_name STOMPConnection
extends RefCounted

signal connected()
signal disconnected()
signal received(bytes: PackedByteArray)

func connect_to_host(address: String) -> int:
	push_error("Connect to host not implemented!")
	return FAILED

func send(bytes: PackedByteArray) -> int:
	push_error("Send not implemented!")
	return FAILED

func poll() -> void:
	push_error("Poll not implemented!")

func close(code: int = 1000, reason: String = "") -> void:
	push_error("Close not implemented!")
