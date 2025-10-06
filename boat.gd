class_name CharacterMain
extends CharacterBody3D

@export_group("Nodes")
@export var ocean_node : Node3D
@export var head_node : Node3D

enum Stat {SPEED, DECAY, STRENGTH, LEVEL}
signal level_up(character : CharacterMain)

@export_group("Settings")
@export var max_pitch : float = 89
@export var min_pitch : float = -15
@export_range(1,100,1) var mouse_sensitivity: int = 50

var speed_level : int=1
var decay_level : int=1
var strength_level : int=1
var mult_level : int=1

var speed_array : Array[int] = [64, 80, 100, 125, 156]
var decay_array : Array[float] = [1, 0.9, 0.8, 0.7, 0.5]
var strength_array : Array[int] = [2, 4, 7, 11, 16]
var mult_array : Array[int] = [20, 25, 33, 50, 80]

var speed_collected : int = 0
var decay_collected : int = 0
var strength_collected : int = 0
var mult_collected : int = 0

var get_stat

var sdf_func : Callable

var grad_sdf_func : Callable

var force = Vector3.ZERO

var move_dir= Vector2.ZERO

var followers : Array[Fly] =[]

var is_paused : bool = true

func _ready():
	Input.set_use_accumulated_input(false)
	$spider_forward/AnimationPlayer.play("Animation")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if (not is_paused):
			aim(event)
		return

func _physics_process(delta):
	var sdf : float
	var grad_sdf : Vector3
	if (is_paused):
		return
	if (Input.is_action_pressed("forwards", true)):
		move_dir.y+=1
	if (Input.is_action_pressed("backwards", true)):
		move_dir.y-=1
	if (Input.is_action_pressed("left", true)):
		move_dir.x-=1
	if (Input.is_action_pressed("right", true)):
		move_dir.x+=1
		
	if (sdf_func):
		sdf = sdf_func.call(position)
	if (grad_sdf_func):
		grad_sdf = grad_sdf_func.call(position)
	
	if (sdf > 0):
		force = -40.0 * grad_sdf * sdf
	else:
		force = -100.0 * grad_sdf * sdf
	
	if (grad_sdf != Vector3.ZERO):
		var angle_to_rotate = acos(grad_sdf.normalized().dot(basis.y))
		if (angle_to_rotate > 0.0):
			rotate(-grad_sdf.cross(basis.y).normalized(), angle_to_rotate)
	

	
	# up/down drag to stop oscillation
	force += -10.0 * velocity.dot(grad_sdf.normalized()) * grad_sdf.normalized()
	force += -4.0 * velocity
	#force += 100.0 * basis.z
	var target_dir = -move_dir.y * head_node.basis.z + move_dir.x * head_node.basis.x
	target_dir.y =0.0
	if (target_dir.length() > 0.0):
		target_dir = target_dir.normalized()
		var rot_angle = min(20.0 * delta, 100.0) * acos(Vector3.FORWARD.dot(target_dir)) * sign(Vector3.RIGHT.dot(target_dir))
		var rot_axis = -basis.y
		if (rot_axis.length() > 0.0):
			rotate(rot_axis, rot_angle)
			head_node.quaternion = Quaternion(Vector3.UP, rot_angle) * head_node.quaternion
			orthonormalize()
			head_node.orthonormalize()
		force += -speed_array[speed_level] * basis.z
			
	velocity += force * delta
	move_and_slide()
	# Iterate through all collisions that occurred this frame
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)

		if collision.get_collider() == null:
			continue

		# If the collider is with a mob
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider() as Fly
			if (!mob.is_dead()):
				if (followers.is_empty()):
					mob.kill()
				else:
					mob.kill()
				followers.push_back(mob)
				update_follower_chain()
			
	$spider_forward/AnimationPlayer.speed_scale = velocity.length() * 0.1
	move_dir = Vector2.ZERO

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
	motion.x*=-1
	if (motion.y + current_pitch > max_pitch):
		motion.y=max_pitch-current_pitch
	if (motion.y + current_pitch < min_pitch):
		motion.y=min_pitch-current_pitch
	add_head_yaw(motion.x)
	add_head_pitch(motion.y)

func on_delivery(_zone : DeliveryZone, node : Node3D):
	while (followers.has(node)):
		followers.erase(node)
	
	match node.type:
		Fly.MobType.LADYBIRD:
			if (speed_level < 5):
				speed_collected += 1
				if (speed_collected >= speed_level):
					speed_level+=1
					speed_collected=0
				level_up.emit(self)
	
	update_follower_chain()

func update_follower_chain():
	for follower_idx in range(followers.size()):
		if (follower_idx==0):
			followers[follower_idx].set_follow_node(self)
		else:
			followers[follower_idx].set_follow_node(followers[follower_idx - 1])


func _on_world_pause() -> void:
	is_paused=true
	$spider_forward/AnimationPlayer.pause()


func _on_world_resume() -> void:
	is_paused=false
	$spider_forward/AnimationPlayer.play()
