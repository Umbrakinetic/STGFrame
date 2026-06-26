extends Node2D

var player

var boss: Enemy

#Did the player game over and choose "Continue" during this playthrough?
var continued_run: bool = false

signal boss_entered

func clear():
	for i in get_children():
		i.queue_free()

var max_bullet_count: int = 1000

var bullet_list: Array = []:
	get():
		return get_tree().get_nodes_in_group("bullet")
