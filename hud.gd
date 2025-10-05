extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game

signal end_game

var score = 0
var hunger = 5000

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



func _on_message_timer_timeout() -> void:
	$Message.hide()


func _on_score_timer_timeout() -> void:
	hunger -= 50
	if hunger <= 0:
		end_game.emit()
	$HungerBar.value = hunger
	score += 1
	update_score(score)
	
