extends Enemy

var start_pos: Vector2 = Vector2.ZERO

var current_phase: int = 0

var boss_name: String = "Minnatsmonki"

var phases: Array = [
	preload("uid://bjxy3cjmsrv4u"),
	preload("uid://cdmh8q7o5ku51"),
]

signal phase_started

signal defeated

func _ready() -> void:
	var move_tween = Tool.quick_tween(self, "global_position", start_pos, 1, Tween.EASE_IN, Tween.TRANS_LINEAR)
	await move_tween.finished
	await wait(1)
	start_phase()

func start_phase() -> void:
	$Phase.set_script(phases[current_phase])
	$Phase.boss = self
	health = $Phase.phase_health
	$Phase.start()
	phase_started.emit()

func _on_death() -> void:
	print("on death")
	if current_phase + 1 < phases.size():
		print("boss phase cleared")
		invincible = true
		give_drops()
		await $Phase.end_phase()
		await wait(1)
		current_phase += 1
		start_phase()
		dying = false
		await wait(1)
		invincible = false
	else:
		print("boss die")
		defeated.emit()
		queue_free()
	
