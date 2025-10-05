class_name Web
extends Node3D

var web_parts: Array[Node3D] = []

func _ready():
	for child in get_children():
		if (child is MeshInstance3D):
			if (child.mesh is CylinderMesh):
				web_parts.push_back(child)
				
func get_web_parts() -> Array[Node3D]:
	return web_parts
