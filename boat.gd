extends CharacterBody3D

@onready
var ocean_node = get_node("../Ocean") as Ocean

var _sdf : Callable = torus_sdf

var _grad_sdf : Callable = torus_grad_sdf

var force = Vector3.ZERO

func _physics_process(delta):
	var sdf = torus_sdf(position)
	var grad_sdf = torus_grad_sdf(position)
	
	if (sdf > 0):
		force = -20.0 * grad_sdf * sdf
	else:
		force = -200.0 * grad_sdf * sdf
	
	if (grad_sdf != Vector3.ZERO):
		var angle_to_rotate = acos(grad_sdf.normalized().dot(basis.y))
		if (angle_to_rotate > 0.0):
			rotate(-grad_sdf.cross(basis.y).normalized(), angle_to_rotate)
		
	if (Input.is_action_pressed("forwards")):
		force += 80.0 * (-basis.z)
	if (Input.is_action_pressed("backwards")):
		force += 80.0 * (-basis.z)
	
	if (Input.is_action_pressed("left")):
		rotate(basis.y, delta * 0.8)
	if (Input.is_action_pressed("right")):
		rotate(basis.y, -delta * 0.8)
		
	force += -10.0 * velocity
	velocity += force * delta
	print("v", velocity)
	print("x", position)
	#velocity += force * delta
	move_and_collide(velocity * delta)

func get_minor_radius():
	return 35.0

func get_major_radius():
	return 85.0

func torus_sdf(pos_in : Vector3) -> float:
	var q : Vector2 = Vector2(Vector3(pos_in.x, 0.0, pos_in.z).length()-get_major_radius(),pos_in.y)
	return q.length()-get_minor_radius();
	
func torus_grad_sdf(pos_in : Vector3) -> Vector3:
	var a = (pos_in.x**2 + pos_in.z**2)
	var l = sqrt(a)
	var d = 1.0/sqrt((l-get_major_radius())**2 + pos_in.y**2)
	return Vector3(pos_in.x * d*(l-get_major_radius())/l, d*pos_in.y, d*pos_in.z*(l-get_major_radius())/l)
	
