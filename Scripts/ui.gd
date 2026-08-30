extends CanvasLayer

@onready var pause_menu: Control = $PauseMenu
@onready var end_game: Control = $EndGame

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		pause_menu.visible = true
		get_tree().paused = true


func _on_btn_continue_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pause_menu.visible = false


func _on_btn_exit_pressed() -> void:
	get_tree().quit()


func _on_btn_play_again_pressed() -> void:
	get_tree().paused = false
	get_parent().get_tree().reload_current_scene()


func _on_car_home() -> void:
	end_game.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
