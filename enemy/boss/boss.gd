## A Boss is a powerful enemy that appears on the screen for extended periods of time.
## They have their own healthbars and pattern timers appended to the top,
## A position indicator at the bottom of the screen,
## And use several Phases (see below) before they are defeated.
## By these rules, Midbosses are also considered Bosses.
class_name Boss extends Enemy

@export var boss_name: String = "BossName"

## Phase:
## A bullet pattern used within the confines of one healthbar and timer.
## PhaseCollection:
## An Array of Phases that appear simultaneously, represented by separate colors within the same healthbar.
## (ex: nonspells, spells)
## For simplicity's sake, a PhaseCollection can simply be referred to as a "Collection".
## PhaseCollection is not a class of its own, but it helps to differentiate terminology.
## -----
## A boss will start with the first PhaseCollection, using the first Phase within that Collection.
## Once that Phase is cleared, they will use the second Phase of that Collection.
## Repeat until all Phases from that PhaseCollection are cleared.
## Then, the boss will use the next PhaseCollection, with the same logic as before.
## Once all PhaseCollections are completely cleared, the boss is defeated.

var phases: Array[Array] = [
	[ ##Healthbar 1
		preload("uid://bjxy3cjmsrv4u"),
		preload("uid://cdmh8q7o5ku51")
	],
]
##index of the current collection.
@onready var current_collection_num: int = 0
## how many phases are in the current collection.
@onready var current_collection_size: int = phases[current_collection_num].size()
## how many collections there are in total.
@onready var total_collection_size: int = phases.size()

@onready var current_phase: = $Phase
@onready var current_phase_num: int = 0

var first_phase_time: float = 30

signal entered

signal phase_started
signal phase_ended

signal collection_started
signal collection_ended

signal spell_declared(spell_name: String)

signal defeated

func _ready() -> void:
	entered.emit()
	allowed_out_of_bounds = true
	
	emit_signal("collection_started")
	start_phase()

func start_phase() -> void:
	$Phase.set_script(phases[current_collection_num][current_phase_num])
	$Phase.boss = self
	health = $Phase.phase_health
	$Phase.start()
	await get_tree().physics_frame
	emit_signal("phase_started")

func declare_spell(spell_name: String):
	emit_signal("spell_declared", spell_name)

## when boss health reaches 0, stops the current pattern (phase), 
## & waits for a second before starting a new pattern.
## if no patterns remain, the boss will die for real.
func _die() -> void:
	Stage.clear_all_bullets(global_position)
	if current_phase.give_drops: give_drops()
	emit_signal("phase_ended")
	if current_phase_num + 1 < current_collection_size:
		await $Phase.end_phase()
		current_phase_num += 1
		start_phase()
		dying = false
	elif current_collection_num + 1 < total_collection_size:
		emit_signal("collection_ended")
		await $Phase.end_phase()
		current_phase_num = 0
		current_collection_num += 1
		emit_signal("collection_started")
		start_phase()
		dying = false
	else:
		defeated.emit()
		queue_free()


	
	for i in Gametray.laser_list:
		i.start_free()
