class_name Stage
extends Node2D

static var player: Player

var player_scene: PackedScene = Gametray.chosen_player_type
var background_scene: PackedScene
var spellcard_background_scene: PackedScene

var background: Node
var spellcard_background: Node

var sections: Array[Callable] = []
var boss: Enemy

signal section_cleared
signal all_sections_cleared

func start():
	if player == null:
		player = player_scene.instantiate()
		add_child(player)
		player.global_position = Vector2(0, 512)
	if background_scene != null:
		background = background_scene.instantiate()
		add_child(background)
		background.global_position = Vector2(-384, -240)
	else: printerr("no background provided for this stage!")
	if spellcard_background_scene != null:
		spellcard_background = spellcard_background_scene.instantiate()
		add_child(spellcard_background)
		spellcard_background.global_position = Vector2(-384, -240)
	else: printerr("no spellcard background provided for this stage!")
	
	%GameUI.start_ui()
	
	background_fadein()
	
	for section in sections:
		await section.call()
		emit_signal("section_cleared")
	
	await Tool.quick_timer(1).timeout
	emit_signal("all_sections_cleared")
	
	#IF full run and cleared the final stage, game clear menu
	if Gametray.full_run and get_script() == Gametray.stage_order[-1]:
		%GameUI.open_game_clear_menu()
	
	##ELSE IF full run and stage cleared is not the final stage, move to next stage
	elif Gametray.full_run and not Gametray.stage_order.find(get_script()) == Gametray.stage_order.size():
		%GameUI.open_stage_clear_menu()
		await %GameUI.confirm_next_stage
		var next_stage = Gametray.stage_order[Gametray.stage_order.find(get_script()) + 1]
		
		await background_fadeout()
		
		background.queue_free()
		spellcard_background.queue_free()
		
		Transition.next_stage(next_stage)
		
	##ELSE if not full run (stage practice), game clear menu
	elif not Gametray.full_run:
		%GameUI.open_game_clear_menu()

func background_fadein():
	background.modulate = Color.BLACK
	var trans_tween = Tool.quick_tween(background, "modulate", Color.WHITE, 1, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)

func background_fadeout():
	var trans_tween = Tool.quick_tween(background, "modulate", Color.BLACK, 1, Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)
	await trans_tween.finished

## Clears all enemy bullets.
## There is a (purely cosmetic) delay where the bullets further away take longer to delete.
## The moment this function is run, all previously-spawned enemy bullets can no longer hit the player.
static func clear_all_bullets(from: Vector2) -> void:
	var bullets: Array[Node] = Gametray.bullet_list
	bullets = Tool.sort_closest(bullets, from)
	var a_pos: int = 0
	for i in bullets:
		if not i.is_in_group("playerbullet"):
			i.start_free(Danmaku.DELETE_FADEGROW, a_pos / 1024.0)
			a_pos += 1

static func clear_all_enemies() -> void:
	var enemies: Array = Engine.get_main_loop().get_nodes_in_group("enemy")
	
	for i in enemies:
		i.drops_items = false
		i._die()

func full_clear():
	clear_all_bullets(player.global_position)
	clear_all_enemies()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	##Point of Collection-- if player's y value is low enough (y < 0), all items start tracking the player
	if player.global_position.y <= 0 and not player.respawning:
		player._collect_all_items()
	
