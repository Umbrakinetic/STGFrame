extends Node2D

@onready var player = get_tree().current_scene.get_node("Player")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused

var max_bullet_count: int = 1000

var bullet_list: Array = []:
	get():
		return get_tree().get_nodes_in_group("bullet")
