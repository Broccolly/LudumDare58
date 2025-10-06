extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

signal end_game

var score = 0

@onready
var hunger = hunger_max

@export
var hunger_max = 5000

func _ready():
	$HungerBar.max_value=hunger_max

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	

func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(_score):
	$ScoreLabel.text = "score: " + str(_score)

func _on_delivery(zone : DeliveryZone, node : Node2D):
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
