extends Control

## This feels a little obtuse, but whatever
var paused_this_frame: bool = false

func pause():
	paused_this_frame = true
	get_tree().paused = true
	show()
	%ResumeButton.grab_focus()
	
	await get_tree().process_frame
	paused_this_frame = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and not paused_this_frame:
		resume()

func _on_resume_button_pressed() -> void:
	resume()

func _on_restart_button_pressed() -> void:
	Gametray.clear()
	resume()
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)

func _on_main_menu_button_pressed() -> void:
	Gametray.clear()
	resume()
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")

func _on_desktop_button_pressed() -> void:
	get_tree().quit()

func resume():
	hide()
	release_focus()
	get_tree().paused = false
