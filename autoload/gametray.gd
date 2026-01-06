extends Node2D

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused

var max_bullet_count: int = 1000

var bullet_list: Array[Bullet] = []

func refresh_bullet_list():
	bullet_list = bullet_list.filter(func(input): return not input == null)
			
