extends Enemy

var start_pos: Vector2 = Vector2.ZERO

var boss_name: String = "Minnatsmonki"

signal entered

var phases: Array[GDScript] = [
	preload("uid://bjxy3cjmsrv4u"),
	preload("uid://cdmh8q7o5ku51"),
]

var current_phase_num: int = 0

@onready var current_phase: = $Phase

var first_phase_time: float = 30

signal phase_started
signal phase_ended

signal spell_declared(spell_name: String)

signal defeated

func _ready() -> void:
	entered.emit()
	allowed_out_of_bounds = true
	
	start_phase()

func start_phase() -> void:
	$Phase.set_script(phases[current_phase_num])
	$Phase.boss = self
	health = $Phase.phase_health
	$Phase.start()
	await get_tree().physics_frame
	phase_started.emit()

func declare_spell(spell_name: String):
	emit_signal("spell_declared", spell_name)

## when boss health reaches 0, stops the current pattern (phase), 
## & waits for a second before starting a new pattern.
## if no patterns remain, the boss will die for real.
func _on_death() -> void:
	clear_all_bullets()
	give_drops()
	phase_ended.emit()
	if current_phase_num + 1 < phases.size():
		await $Phase.end_phase()
		current_phase_num += 1
		start_phase()
		dying = false
	else:
		defeated.emit()
		queue_free()

## Clears all enemy bullets.
## There is a (purely cosmetic) delay where the bullets further away take longer to delete.
## the moment this function is run, all enemy bullets can no longer hit the player.
func clear_all_bullets() -> void:
	var bullets: Array = Gametray.bullet_list
	bullets = Tool.sort_closest(bullets, position)
	#bullets.reverse()
	var a_pos: int = 0
	for i in bullets:
		if not i.is_in_group("playerbullet"):
			i.start_free(Danmaku.DELETE_FADEGROW, a_pos / 1024.0)
			a_pos += 1
