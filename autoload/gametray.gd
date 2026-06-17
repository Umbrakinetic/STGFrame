extends Node2D

var player

var boss: Enemy

signal boss_entered

#func _ready() -> void:
	#process_mode = Node.PROCESS_MODE_ALWAYS
	

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and not get_tree().paused:
		get_tree().current_scene.get_node("PauseMenu").pause()
		

var max_bullet_count: int = 1000

var bullet_list: Array = []:
	get():
		return get_tree().get_nodes_in_group("bullet")
