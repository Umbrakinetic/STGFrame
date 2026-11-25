extends Control

## The pause menu immediately closes after pressing "Escape" without this.
## This feels a little obtuse, but whatever
var switched_pause_this_frame: bool = false

var last_button: Button

func pause():
	switched_pause_this_frame = true
	RenderingServer.global_shader_parameter_set("paused", true)
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
	
	if get_viewport().gui_get_focus_owner() is Button:
		last_button = get_viewport().gui_get_focus_owner()
	
	if Input.is_anything_pressed() and not get_viewport().gui_get_focus_owner() is Button:
		last_button.grab_focus()
	

func _on_resume_button_pressed() -> void:
	resume()

func resume():
	RenderingServer.global_shader_parameter_set("paused", false)
	hide()
	release_focus()
	get_tree().paused = false

func _on_restart_button_pressed() -> void:
	go_to_confirm("Restart from beginning stage", restart)

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
	go_to_confirm("Return to Main Menu", go_to_main_menu)

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
