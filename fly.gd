class_name Fly
extends CharacterBody3D

var sdf_func : Callable

var grad_sdf_func : Callable

var procession_rate : float = 0.5
var gravity_rate : float = 15.0
var ground_rate : float = 100.0
var flying_speed : float = 20.0
var landing_height : float = 5.0
var vertical_drag : float = 10.0
var general_drag : float = 2.0

func _ready():
	Input.set_use_accumulated_input(false)
	$fly/AnimationPlayer.play("ArmatureAction")

func _physics_process(delta: float) -> void:
	var sdf : float
	var grad_sdf : Vector3
	var force : Vector3

	if (sdf_func):
		sdf = sdf_func.call(position)
		if (sdf > landing_height):
			print(sdf)
			rotate(basis.y, procession_rate * delta)
			force = -basis.z * flying_speed * min(sdf, 10.0)
	if (grad_sdf_func):
		grad_sdf = grad_sdf_func.call(position)
		if (sdf > 0):
			force += -sdf * grad_sdf * gravity_rate
		else:
			force += -sdf * grad_sdf * ground_rate
	
	# up/down drag to stop oscillation
	force += -vertical_drag* velocity.dot(grad_sdf.normalized()) * grad_sdf.normalized()
	force += -general_drag * velocity
	if (grad_sdf != Vector3.ZERO):
		var angle_to_rotate = acos(grad_sdf.normalized().dot(basis.y))
		if (angle_to_rotate > 0.0):
			rotate(-grad_sdf.cross(basis.y).normalized(), angle_to_rotate)
		
	velocity += force * delta
	move_and_collide(velocity * delta)
	
