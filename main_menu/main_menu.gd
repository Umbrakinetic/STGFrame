extends Control

@onready var menus: Array[Node] = [%MainMenu, %StageMenu, %PlayerMenu]

var stage_scene: String = preload("uid://dkhguhsi42glx").resource_path
var stage: String = preload("uid://dkhguhsi42glx").resource_path

var chosen_player_type: PackedScene

var load_step: Callable

func _ready() -> void:
	Gametray.continued_run = false
	change_menu(%MainMenu)
	%PlayButton.grab_focus()

var play_all: Callable = func():
	Gametray.next_stage = preload("uid://d1vogmed8b64b")
	Gametray.full_run = true
	Transition.load_next_scene(stage)

var play_stage: Callable = func():
	Gametray.full_run = false
	Transition.load_next_scene(stage)

func _on_play_button_pressed() -> void:
	load_step = play_all
	change_menu(%PlayerMenu) 
func _on_stage_button_pressed() -> void:
	change_menu(%StageMenu)
	
func _on_stage_selected(stage_number: int) -> void:
	load_step = play_stage
	if   stage_number == 0: Gametray.next_stage = preload("uid://d1vogmed8b64b")
	elif stage_number == 1: Gametray.next_stage = preload("uid://ce4gciehm5e0h")
	change_menu(%PlayerMenu)

func _on_player_button_hover(source: int) -> void:
	if source == 0:
		%Player1Img.show()
		%Player2Img.hide()
	else:
		%Player1Img.hide()
		%Player2Img.show()

func _on_player_selected(source: int) -> void:
	if source == 0:
		chosen_player_type = preload("uid://u5q5a7xl7gpt")
		Gametray.chosen_player_type = chosen_player_type
	else:
		chosen_player_type = preload("uid://dwasf6mnbwagh")
		Gametray.chosen_player_type = chosen_player_type
	
	release_focus()
	
	load_step.call()

func change_menu(menu: Node) -> void:
	release_focus()
	for i in menus:
		i.hide()
	
	menu.show()
	menu.get_child(0).get_child(0).grab_focus()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
