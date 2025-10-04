extends Node3D

func _ready():
	$Character.sdf_func = $Ocean.torus_sdf
	$Character.grad_sdf_func = $Ocean.torus_grad_sdf
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for child in get_children():
		if child is Fly:
			child.sdf_func = $Ocean.torus_sdf
			child.grad_sdf_func = $Ocean.torus_grad_sdf
			
