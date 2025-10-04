extends CharacterBody3D

@export_group("Nodes")
@export var ocean_node : Node3D
@export var head_node : Node3D

@export_group("Settings")
@export var max_pitch : float = 89
@export var min_pitch : float = -15
@export_range(1,100,1) var mouse_sensitivity: int = 50

var sdf_func : Callable

var grad_sdf_func : Callable

var force = Vector3.ZERO

var move_dir= Vector2.ZERO

func _ready():
	Input.set_use_accumulated_input(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if event.is_action_pressed("click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
		
	if event is InputEventMouseMotion:
		aim(event)
		return
		
	if (event.is_action_pressed("forwards", true)):
		move_dir.y+=1
		return
	if (event.is_action_pressed("backwards", true)):
		move_dir.y-=1
		
	
	if (event.is_action_pressed("left", true)):
		move_dir.x-=1
	if (event.is_action_pressed("right", true)):
		move_dir.y+=1

func _physics_process(delta):
	var sdf : float
	var grad_sdf : Vector3
	
	if (sdf_func):
		sdf = sdf_func.call(position)
	if (grad_sdf_func):
		grad_sdf = grad_sdf_func.call(position)
	
	if (sdf > 0):
		force = -20.0 * grad_sdf * sdf
	else:
		force = -50.0 * grad_sdf * sdf
	
	if (grad_sdf != Vector3.ZERO):
		var angle_to_rotate = acos(grad_sdf.normalized().dot(basis.y))
		if (angle_to_rotate > 0.0):
			rotate(-grad_sdf.cross(basis.y).normalized(), angle_to_rotate)
		

	
	# up/down drag to stop oscillation
	force += -10.0 * velocity.dot(grad_sdf.normalized()) * grad_sdf.normalized()
	force += -2.0 * velocity
	#force += 100.0 * basis.z
	var target_dir = -move_dir.y * head_node.basis.z + move_dir.x * head_node.basis.x
	target_dir.y =0.0
	if (target_dir.length() > 0.0):
		target_dir = target_dir.normalized()
		force += -200.0 * basis.z
		var rot_angle = min(5.0 * delta, 1.0) * acos(Vector3.FORWARD.dot(target_dir)) * sign(Vector3.RIGHT.dot(target_dir))
		var rot_axis = -basis.y
		if (rot_axis.length() > 0.0):
			rotate(rot_axis, rot_angle)
			head_node.quaternion = Quaternion(Vector3.UP, rot_angle) * head_node.quaternion
			orthonormalize()
			head_node.orthonormalize()
			
	velocity += force * delta
	print("v", velocity)
	print("x", position)
	#velocity += force * delta
	move_and_collide(velocity * delta)
	move_dir = Vector2(0,0)

func add_head_yaw(angle : float):
	if (is_zero_approx(angle)):
		return
		
	head_node.quaternion = Quaternion(Vector3.UP, deg_to_rad(angle)) * head_node.quaternion
	head_node.orthonormalize()
	
func add_head_pitch(angle : float) -> void:
	if is_zero_approx(angle):
		return
		
	head_node.rotate_object_local(Vector3.LEFT, deg_to_rad(angle))
	head_node.orthonormalize()

func aim(event : InputEventMouseMotion) -> void:
	var motion : Vector2 = event.relative
	var degrees_per_unit: float = 0.001
	var current_pitch: float = -rad_to_deg(head_node.rotation.x)
	
	motion *= mouse_sensitivity
	motion *= degrees_per_unit
	motion.y*=-1
	if (motion.y + current_pitch > max_pitch):
		motion.y=max_pitch-current_pitch
	if (motion.y + current_pitch < min_pitch):
		motion.y=min_pitch-current_pitch
	add_head_yaw(motion.x)
	add_head_pitch(motion.y)
