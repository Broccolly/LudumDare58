class_name Ocean
extends Node3D


@onready
var mesh : TorusMesh = $WorldTorus.mesh as TorusMesh

func get_inner_radius() -> float:
	return mesh.inner_radius

func get_outer_radius() -> float:
	return mesh.outer_radius
	
func get_closest_minor_axis(position_in : Vector3)	-> Vector3:
	var plane_vector : Vector3
	if (position_in.x**2 + position_in.z**2 > 0):
		plane_vector = Vector3(position_in.x, 0.0, position_in.z).normalized() * (get_outer_radius() + get_inner_radius()) * 0.5
	else:
		plane_vector = Vector3.RIGHT * 0.5 * (get_outer_radius() + get_inner_radius())
		call
	return plane_vector
