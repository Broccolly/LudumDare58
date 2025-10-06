class_name HUD
extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

signal end_game

var score = 0

var start_time = 3

@onready
var hunger = hunger_max

@export
var hunger_max = 5000

func _ready():
	$HungerBar.max_value=hunger_max
	$HungerBar.value=hunger_max

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	

func show_game_over():
	show_message("Game Over")
	
	
	
func update_score(_score):
	$ScoreLabel.text = "score: " + str(_score)

func _on_delivery(zone : DeliveryZone, node : Node3D):
	score += 1
	update_score(score)

func _on_message_timer_timeout() -> void:
	$Message.hide()


func _on_score_timer_timeout() -> void:
	hunger -= 50
	if hunger <= 0:
		end_game.emit()
	$HungerBar.value = hunger
	update_score(score)
	


func _on_world_pause() -> void:
	$MessageTimer.paused = true
	$ScoreTimer.paused = true


func _on_world_resume() -> void:
	$MessageTimer.paused = false
	$ScoreTimer.paused = false


func _on_start_timer_timeout() -> void:
	if start_time > 1:
		start_time -= 1
		show_message(str(start_time))
	else:
		start_time = 0
		$StartTimer.stop()
		$ScoreTimer.start()
		start_game.emit()
		show_message("GO!")
