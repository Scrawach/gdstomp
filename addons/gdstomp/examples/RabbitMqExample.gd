class_name RabbitMqExample
extends Node

const RABBIT_MQ_ADDRESS = "127.0.0.1:61613"

var stomp_client: STOMPClient = STOMP.over_tcp()

func _ready() -> void:
	var connect_error: int = stomp_client.connect_to_host(RABBIT_MQ_ADDRESS)
	
	if connect_error != OK:
		push_error("connection error: %s" % connect_error)
	
	await stomp_client.connection.connected;
	stomp_client.send(STOMPPacket.connection("/", "admin", "admin"))
	var connected_packed: STOMPPacket = await stomp_client.received;
	

func _process(delta: float) -> void:
	stomp_client.poll();
