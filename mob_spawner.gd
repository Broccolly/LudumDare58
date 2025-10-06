class_name MobSpawner
extends Node3D

@export
var mob_scene : PackedScene

signal pause_fly
signal resume_fly

var sdf_func : Callable
var grad_sdf_func : Callable

func _on_timer_timeout() -> void:
	spawn_mob(2)

func spawn_mob(count : int):
	for i in range(count):
		var mob_node=mob_scene.instantiate()
		var dist = randf_range(100.0, 200.0)
		var yaw = randf_range(0.0, 2*PI)
		var pitch = randf_range(0.0, 2*PI)
		var angle = randf_range(0.0,2*PI)
		
		mob_node.position = dist * Vector3.FORWARD.rotated(Vector3.RIGHT,pitch).rotated(Vector3.UP, yaw)
		mob_node.rotation.y = angle
		mob_node.sdf_func = sdf_func
		mob_node.grad_sdf_func = grad_sdf_func
		pause_fly.connect(mob_node.on_pause_fly)
		resume_fly.connect(mob_node.on_resume_fly)
		add_sibling(mob_node)


func _on_world_pause() -> void:
	$Timer.stop()
	pause_fly.emit()

func _on_world_resume() -> void:
	$Timer.start()
	resume_fly.emit()



func _on_world_start() -> void:
	spawn_mob(10)
