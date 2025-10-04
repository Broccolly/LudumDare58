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
	return plane_vector

func get_major_radius():
	return 0.5 * (mesh.inner_radius + mesh.outer_radius)

func get_minor_radius():
	return 0.5 * (mesh.outer_radius - mesh.inner_radius)

func torus_sdf(pos_in : Vector3) -> float:
	var q : Vector2 = Vector2(Vector3(pos_in.x, 0.0, pos_in.z).length()-get_major_radius(),pos_in.y)
	return q.length()-get_minor_radius();
	
func torus_grad_sdf(pos_in : Vector3) -> Vector3:
	var a = (pos_in.x**2 + pos_in.z**2)
	var l = sqrt(a)
	var d = 1.0/sqrt((l-get_major_radius())**2 + pos_in.y**2)
	return Vector3(pos_in.x * d*(l-get_major_radius())/l, d*pos_in.y, d*pos_in.z*(l-get_major_radius())/l)
