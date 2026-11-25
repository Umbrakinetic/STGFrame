extends Control

func _ready() -> void:
	hide()

func pause():
	get_tree().paused = true
	show()
	%ContinueButton.grab_focus()

func _on_continue_button_pressed() -> void:
	Gametray.continued_run = true
	Stage.player.lives = 2
	resume()

func resume():
	hide()
	release_focus()
	get_tree().paused = false

func _on_restart_button_pressed() -> void:
	restart()

func restart():
	Gametray.clear()
	if Gametray.full_run:
		var stage_1 = Gametray.stage_order[0]
		Transition.load_next_scene(Transition.STAGE, stage_1)
		await Transition.finished
		resume()
	else:
		var current_stage = load(get_tree().current_scene.get_script().get_path())
		Transition.load_next_scene(Transition.STAGE, current_stage)
		await Transition.finished
		resume()

func _on_main_menu_button_pressed() -> void:
	go_to_main_menu()

func go_to_main_menu():
	Gametray.clear()
	Transition.load_next_scene(Transition.MAIN_MENU)
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
