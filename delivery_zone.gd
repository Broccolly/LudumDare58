class_name DeliveryZone
extends Area3D

signal object_delivered(zone : DeliveryZone, node: Node3D)

@export
var type : Fly.MobType

func _on_body_entered(body: Node3D) -> void:
	print(body)
	if body is Fly and body.type == type:
		object_delivered.emit(self, body)
		body.deliver()
