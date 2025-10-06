class_name World
extends Node3D

signal pause
signal resume
signal start

var is_paused : bool = true
var is_started : bool = false

func _ready():
	$Character.sdf_func = $Ocean.global_sdf
	$Character.grad_sdf_func = $Ocean.global_grad_sdf
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$HUD.show_message("3")
	
	for node in $Ocean/Web.get_children(true):
		if (node is DeliveryZone):			
			node.object_delivered.connect($Character.on_delivery)
			node.object_delivered.connect($HUD._on_delivery)
	for node in get_children(true):
		if (node is MobSpawner):
			node.sdf_func = $Ocean.global_sdf
			node.grad_sdf_func = $Ocean.global_grad_sdf
			pause.connect(node._on_world_pause)
			resume.connect(node._on_world_resume)
			start.connect(node._on_world_start)

	#DeliveryZone0..connect(object_delivered)
	#pause_game()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if (not is_paused):
			pause_game()
		return
	if event.is_action_pressed("click"):
		if (is_paused):
			if (is_started):
				resume_game()
			#else:
				#start_game()
	
func start_game():
	start.emit()
	is_started=true
	resume_game()
	
func pause_game():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pause.emit()
	is_paused=true
	
func resume_game():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	resume.emit()
	is_paused=false
	
func game_over():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://GameOver.tscn")
	
#func on_delivery(body : Node3D):
	#if (body is Fly):
		#print ("Delivered ", body)
		#if (body.is_dead() and not body.is_delivered()):
			#body.deliver()


func _on_hud_start_game() -> void:
	start_game()
