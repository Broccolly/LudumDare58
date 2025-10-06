class_name Fly
extends CharacterBody3D

enum MobType {FLY, LADYBIRD, LADYBLUE, LADYGREEN, LADYYELLOW}

signal im_alive
signal im_dead
signal delivered

var sdf_func : Callable
var grad_sdf_func : Callable

var procession_rate : float = 0.5
var gravity_rate : float = 15.0
var ground_rate : float = 100.0
var flying_speed : float = 20.0
var landing_height : float = 5.0
var vertical_drag : float = 10.0
var general_drag : float = 2.0
var delivery_shrink_rate : float = 1.0
var is_being_damaged : bool = false

@export
var type : MobType

var is_paused : bool = false

@onready
var radius = $CollisionShape3D.shape.radius

@export
var max_health :float = 5.0

@onready
var health : float = max_health

@onready
var start_scale : Vector3 = scale

var sdf : float
var grad_sdf : Vector3
var force : Vector3

enum State {SPAWNING, ALIVE, DEAD, DELIVERED, NONE}

var follow_target : Node3D
var follow_distance : float = 10.0
var state : State = State.SPAWNING
var next_state : State = State.NONE
func _ready():
	Input.set_use_accumulated_input(false)
	if (type == MobType.FLY):
		$fly/AnimationPlayer.play("ArmatureAction")

func deal_damage(delta):
	health -= delta
	is_being_damaged = true

func deliver():
	delivered.emit()
	next_state=State.DELIVERED

func _physics_process(delta: float) -> void:
	if (next_state != State.NONE):
		state = next_state
		next_state = State.NONE
	if (is_paused):
		return
	if (sdf_func):
		sdf = sdf_func.call(position) - radius
	if (grad_sdf_func):
		grad_sdf = grad_sdf_func.call(position)

	match state:
		State.SPAWNING:
			spawn_behaviour(delta)
		State.ALIVE:
			alive_behaviour(delta)
		State.DEAD:
			dead_behaviour(delta)
		State.DELIVERED:
			delivered_behaviour(delta)
	force = Vector3.ZERO
	$SilkBall.visible = is_dead()

func add_gravity() -> void:
	if (sdf > 0):
		force += -sdf * grad_sdf * gravity_rate
	else:
		force += -sdf * grad_sdf * ground_rate

func spawn_behaviour(delta: float):
	if (sdf > landing_height):
		pass
		rotate(basis.y, procession_rate * delta)
		force += -basis.z * flying_speed * min(sdf, 10.0)
		orthonormalize()
	else:
		start_land()
		pass
		
	add_gravity()
	add_drag()
	point_vector_up(Vector3.UP)
	apply_force(delta)

func alive_behaviour(delta: float):
	add_gravity()
	add_drag()
	point_vector_up(Vector3.UP)
	apply_force(delta)

func dead_behaviour(delta: float):
	add_gravity()
	add_drag()
	#rotate(basis.y, procession_rate * delta * 5)
	add_follow()
	apply_force(delta)
	roll_rotation(delta)
	
func delivered_behaviour(delta : float):
	add_gravity()
	add_drag()
	scale *= 0.9
	radius *= 0.9
	if (scale.x/start_scale.x < 0.001):
		queue_free()
	
func roll_rotation(delta):
	var up : Vector3 = grad_sdf.normalized()
	var angle : float = (velocity - velocity.dot(grad_sdf.normalized())*grad_sdf.normalized()).length() / radius
	var axis = up.cross(velocity).normalized()
	rotate(axis, angle * delta)
	
func start_land() -> void:
	next_state = State.ALIVE
	im_alive.emit()

func kill():
	next_state = State.DEAD
	im_dead.emit()

func set_follow_node(node_to_follow : Node3D):
	follow_target = node_to_follow

func is_dead() -> bool:
	return (state == State.DEAD || state==State.DELIVERED || next_state == State.DEAD)

func is_delivered():
	return (state == State.DELIVERED || next_state==State.DELIVERED)

func add_follow() -> void:
	var k = 50.0
	if(follow_target):
		var diff = follow_target.position - position
		var d = diff.length()
		var dir = diff.normalized()
		force += (d-follow_distance) * dir * k
		
		#force += 100.0 * diff.normalized()

func add_drag():
	# up/down drag to stop oscillation
	force += -vertical_drag* velocity.dot(grad_sdf.normalized()) * grad_sdf.normalized()
	force += -general_drag * velocity

func point_vector_up(vec_up):
	if (grad_sdf != Vector3.ZERO):
		var dir = basis * vec_up
		var angle_to_rotate = acos(grad_sdf.normalized().dot(dir))
		if (angle_to_rotate > 0.0):
			rotate(-grad_sdf.cross(dir).normalized(), angle_to_rotate)
		orthonormalize()
		
func apply_force(delta):
	velocity += force * delta
	move_and_slide()
	
func on_pause_fly():
	is_paused=true
	
func on_resume_fly():
	is_paused=false
