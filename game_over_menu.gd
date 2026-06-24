extends Control

func _ready() -> void:
	hide()

func pause():
	get_tree().paused = true
	show()
	%ContinueButton.grab_focus()

func _on_continue_button_pressed() -> void:
	Gametray.continued_run = true
	Gametray.player.lives = 2
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
	go_to_main_menu()

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
