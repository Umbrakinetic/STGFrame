class_name Phase
extends Node

var boss: Enemy

var phase_health: float = 1000

@export var phase_time: int

signal ended

func get_phase_time() -> int:
	return 30

func start() -> void:
	pass

func end_phase() -> void:
	emit_signal("ended")
	set_script(null)
