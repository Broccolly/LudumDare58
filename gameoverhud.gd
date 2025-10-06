extends CanvasLayer




func _on_message_ready() -> void:
	$Message.text = "Score: " + str(global.score)


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://UItest.tscn")
