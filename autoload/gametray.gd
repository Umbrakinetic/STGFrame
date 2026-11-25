extends Node2D

var chosen_player_type: PackedScene

## The order of stages in a full run.
var stage_order: Array = [
	preload("uid://d1vogmed8b64b"),
	preload("uid://ce4gciehm5e0h"),
	preload("uid://bygnqv77oy373"),
	
]

## Is the player attempting a playthrough of all stages? (as opposed to one stage)
var full_run: bool = false

## Did the player game over and choose "Continue" during this playthrough?
var continued_run: bool = false

func clear():
	for i in get_children():
		i.queue_free()

## The max amount of bullets allowed to exist at any one point.[br]
## If the current bullet count is at the maximum, Danmaku.Spawn_Bullet() will not create a bullet.
var max_bullet_count: int = 1000

var bullet_list: Array = []:
	get():
		return get_tree().get_nodes_in_group("bullet")

var laser_list: Array = []:
	get():
		return get_tree().get_nodes_in_group("laser")
