extends Control

func _ready() -> void:
	hide()

var last_button: Button

func pause():
	get_tree().paused = true
	show()
	%MainMenuButton.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if get_viewport().gui_get_focus_owner() is Button:
		last_button = get_viewport().gui_get_focus_owner()
	
	if Input.is_anything_pressed() and not get_viewport().gui_get_focus_owner() is Button:
		last_button.grab_focus()

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
