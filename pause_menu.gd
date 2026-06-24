extends Control

## The pause menu immediately closes after pressing "Escape" without this.
## This feels a little obtuse, but whatever
var switched_pause_this_frame: bool = false

func pause():
	switched_pause_this_frame = true
	get_tree().paused = true
	show()
	%ResumeButton.grab_focus()
	
	await get_tree().process_frame
	switched_pause_this_frame = false

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and not switched_pause_this_frame:
		switched_pause_this_frame = true
		resume()
		
		await get_tree().process_frame
		switched_pause_this_frame = false

func _on_resume_button_pressed() -> void:
	resume()

func resume():
	hide()
	release_focus()
	get_tree().paused = false

func _on_restart_button_pressed() -> void:
	go_to_confirm("Restart from beginning stage", restart)

func restart():
	Gametray.clear()
	Transition.load_next_scene(get_tree().current_scene.scene_file_path)
	await Transition.finished
	resume()

func _on_main_menu_button_pressed() -> void:
	go_to_confirm("Return to Main Menu", go_to_main_menu)

func go_to_main_menu():
	Gametray.clear()
	Transition.load_next_scene("res://main_menu/main_menu.tscn")
	await Transition.finished
	resume()

func _on_desktop_button_pressed() -> void:
	go_to_confirm("Quit to Desktop", quit_to_desktop)

func quit_to_desktop():
	get_tree().quit()

var to_call: Callable

func go_to_confirm(request: String, action: Callable):
	%ConfirmationText.text = \
	"YOU ARE ABOUT TO: \n[color=yellow]" + request + "\n[/color]ARE YOU SURE?"
	
	to_call = action
	
	%MainPauseMenu.hide()
	%ConfirmationMenu.show()
	
	%ConfirmButton.grab_focus()

func _on_confirm_button_pressed() -> void:
	to_call.call()

func _on_back_button_pressed() -> void:
	%MainPauseMenu.show()
	%ConfirmationMenu.hide()
	
	%ResumeButton.grab_focus()
