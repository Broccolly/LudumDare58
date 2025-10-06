class_name mob_base
extends CharacterBody3D

var sdf_func : Callable
var grad_sdf_func : Callable

@export_group("Drag Coefficients")
@export var vertical_drag : float = 10.0
@export var general_drag : float = 2.0

enum mob_state {ALIVE, DEAD, DELIVERED}
enum mob_type {FLY, WORM}

var state : mob_state
var type : mob_type

var force_this_frame : Vector3

func _physics_process(delta: float) -> void:
	
	force_this_frame += -vertical_drag* velocity.dot(grad_sdf.normalized()) * grad_sdf.normalized()
	force_this_frame += -general_drag * velocity
	velocity += force_this_frame * delta
	force_this_frame = Vector3.ZERO
