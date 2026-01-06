class_name Phase
extends Node

var boss: Enemy

var phase_health: float = 1000

signal ended

func start() -> void:
	pass

func end_phase() -> void:
	emit_signal("ended")
	set_script(null)
