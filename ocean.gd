class_name Ocean
extends Node3D


@onready
var mesh : TorusMesh = $WorldTorus.mesh as TorusMesh

var cylinder_sdfs : Array

var torus_sdf : TorusSDF = TorusSDF.new()

func _ready():
	torus_sdf.major_r = get_major_radius()
	torus_sdf.minor_r = get_minor_radius()
	
	cylinder_sdfs.clear()
	var arr: Array = $Web.get_web_parts()
	cylinder_sdfs = arr.map(node_to_cylinder_sdf)

func node_to_cylinder_sdf(node : MeshInstance3D) -> CylinderSDF:
	var ret = CylinderSDF.new()
	var shape = node.mesh as CylinderMesh
	var h = shape.height
	ret.pointA = node.position + node.basis.y * shape.height * 0.5
	ret.pointB = node.position - node.basis.y * shape.height * 0.5
	ret.r = shape.top_radius
	print("Convert", ret.pointA, ret.pointB, ret.r)
	return ret

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

func global_sdf(pos_in : Vector3) -> float:

	var k = 1.0
	var val = torus_sdf.sdf(pos_in)
	for cylinder_sdf in cylinder_sdfs:
		val = smin(val, cylinder_sdf.sdf(pos_in), k)
		
	return val

func global_grad_sdf(pos_in : Vector3) -> Vector3:
	var delta : float = 0.001
	var sxA = global_sdf(pos_in - delta*Vector3.RIGHT)
	var sxB = global_sdf(pos_in + delta*Vector3.RIGHT)
	var syA = global_sdf(pos_in - delta*Vector3.UP)
	var syB = global_sdf(pos_in + delta*Vector3.UP)
	var szA = global_sdf(pos_in - delta*Vector3.BACK)
	var szB = global_sdf(pos_in + delta*Vector3.BACK)
	
	var inv = 1.0/(2.0*delta)
	return Vector3((sxB-sxA) * inv, (syB- syA)*inv, (szB-szA)*inv)
	#var a = (pos_in.x**2 + pos_in.z**2)
	#var l = sqrt(a)
	#var d = 1.0/sqrt((l-get_major_radius())**2 + pos_in.y**2)
	#return Vector3(pos_in.x * d*(l-get_major_radius())/l, d*pos_in.y, d*pos_in.z*(l-get_major_radius())/l)

class TorusSDF:
	func _init():
		major_r = 50
	var major_r : float = 10.0
	var minor_r : float = 1.0
	func sdf(pos_in : Vector3) -> float:
		var q : Vector2 = Vector2(Vector3(pos_in.x, 0.0, pos_in.z).length()-major_r,pos_in.y)
		return q.length()-minor_r
		
	func grad_sdf(pos_in : Vector3) -> Vector3:
		var a = (pos_in.x**2 + pos_in.z**2)
		var l = sqrt(a)
		var d = 1.0/sqrt((l-major_r)**2 + pos_in.y**2)
		return Vector3(pos_in.x * d*(l-major_r)/l, d*pos_in.y, d*pos_in.z*(l-major_r)/l)
#
class CylinderSDF:
	var pointA: Vector3 = Vector3.ZERO
	var pointB: Vector3 = Vector3.ZERO
	var r : float = 0.5
	
	func sdf(pos_in):
		var pa : Vector3 = pos_in - pointA
		var ba = pointB - pointA
		var h = clamp( pa.dot(ba)/ba.dot(ba), 0.0, 1.0 );
		return ( pa - ba*h ).length() - r
		
func smin(a: float ,b: float,k: float = 2.0):
	k*=4.0
	var h = max(k-abs(a-b), 0.0)/k
	return min(a, b) - h*h*k*0.25
