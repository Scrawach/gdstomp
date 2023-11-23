# gdstomp
Godot 4 addon for accessing messaging servers using the STOMP protocol.

## Usage

Create STOMP Client over tcp:

```gdscript
var stomp_client: STOMPClient = STOMP.over_tcp()
```

Establish connection to message broker:

```gdscript
var connect_error: int = stomp_client.connect_to_host("127.0.0.1:61613")
if connect_error != OK:
  push_error("connection error: $s" % connect_error)
```

> **Important!** You need poll STOMP client every frame (or less often) for receive or transceive packets. Process method in nodes is good place for it.

```gdscript
func _process(delta: float) -> void:
  stomp_client.poll()
```

Before send any packets wait until connection:

```gdscript
await stomp_client.connection.connected;
```

## Sending and receiving messages

After established connection you can connect to broker. Use default `send` method:

```gdscript
stomp_client.send(STOMPPacket.connection("/", "admin", "admin"))
var connected_answer: STOMPPacket = await stomp_client.received
```

Or use specific method `send_connection`:

```gdscript
stomp_client.send_connection("admin", "admin", "/")
var connected_answer: STOMPPacket = await stomp_client.received
```

So after this you can send message to queues:

```gdscript
var hello_packet: STOMPPacket = STOMPPacket.to("/queue/test").with_message("Hello, World!")
stomp_client.send(hello_packet)
```

## Callbacks

By default, the Stomp client will convert **all** received data into a STOMPPacket in received signal that you can connect to.

```gdscript
func _ready() -> void:
  stomp_client.received.connect(_on_received_stomp_packet)

func _on_received_stomp_packet(packet: STOMPPacket) -> void:
  # do something...
```

But If you want to filter received data by a specific queue, use `listen` and `unlisten` methods:

```gdscript
stomp_client.listen("/queue/test", _on_received_stomp_packet)
```