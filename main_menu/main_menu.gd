extends Control

@onready var menus: Array[Node] = [%MainMenu, %StageMenu, %PlayerMenu]

var menu_tree: Array[Control] = []

var chosen_player_type: PackedScene

var load_step: Callable

var stage_script: GDScript = preload("uid://d1vogmed8b64b")

const Stage1 = preload("uid://d1vogmed8b64b")
const Stage2 = preload("uid://ce4gciehm5e0h")
const Stage3 = preload("uid://bygnqv77oy373")

var stages_order: Array[GDScript] = [
	Stage1,
	Stage2,
	Stage3,
]

func _ready() -> void:
	Gametray.continued_run = false
	change_menu(%MainMenu)
	%PlayButton.grab_focus()

var play_all: Callable = func():
	Gametray.full_run = true
	Transition.load_next_scene(Transition.STAGE)
	menu_tree.append(%MainMenu)

var play_stage: Callable = func():
	Gametray.full_run = false
	Transition.load_next_scene(Transition.STAGE, stage_script)
	menu_tree.append(%MainMenu)

func _on_play_button_pressed() -> void:
	load_step = play_all
	change_menu(%PlayerMenu) 
	menu_tree.append(%MainMenu)
func _on_stage_button_pressed() -> void:
	change_menu(%StageMenu)
	menu_tree.append(%MainMenu)
	
func _on_stage_selected(stage_number: int) -> void:
	load_step = play_stage
	stage_script = stages_order[stage_number]
	change_menu(%PlayerMenu)
	menu_tree.append(%StageMenu)

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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("bomb") and menu_tree.size() > 0:
		change_menu(menu_tree[-1])
		menu_tree.pop_back()
