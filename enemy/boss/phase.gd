class_name Phase
extends Node

var boss: Enemy

var phase_health: float = 1000

## Does the boss give item pickups after this phase?
var give_drops: bool = true

var phase_time: int = 30

signal ended

func get_phase_time() -> int:
	return phase_time

func start() -> void:
	pass

func end_phase() -> void:
	emit_signal("ended")
	set_script(null)
