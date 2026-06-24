extends Control

func _ready() -> void:
	hide()

func pause():
	get_tree().paused = true
	show()
	%RestartButton.grab_focus()

func resume():
	hide()
	release_focus()
	get_tree().paused = false

func _on_restart_button_pressed() -> void:
	restart()

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
