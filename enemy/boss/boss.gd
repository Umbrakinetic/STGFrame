extends Enemy

var start_pos: Vector2 = Vector2.ZERO

var current_phase: int = 0

var boss_name: String = "Minnatsmonki"

signal entered

var phases: Array = [
	preload("uid://bjxy3cjmsrv4u"),
	preload("uid://cdmh8q7o5ku51"),
]

signal phase_started

signal defeated

func _ready() -> void:
	entered.emit()
	invincible = true
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

## when boss health reaches 0, stops the current pattern (phase), 
## & waits for a second before starting a new pattern.
## if no patterns remain, the boss will die for real.
func _on_death() -> void:
	clear_all_bullets()
	if current_phase + 1 < phases.size():
		give_drops()
		await $Phase.end_phase()
		await wait(1)
		current_phase += 1
		start_phase()
		dying = false
	else:
		defeated.emit()
		queue_free()

## Clears all enemy bullets.
## There is a (purely cosmetic) delay where the bullets 
## further away take longer to delete.
## the moment this function is run, all enemy bullets can 
## no longer hit the player.
func clear_all_bullets() -> void:
	var bullets: Array = Gametray.bullet_list
	bullets = Tool.sort_closest(bullets, position)
	#bullets.reverse()
	var a_pos: int = 0
	for i in bullets:
		if not i.is_in_group("playerbullet"):
			i.start_free(Danmaku.DELETE_FADEGROW, a_pos / 540.0)
			a_pos += 1
