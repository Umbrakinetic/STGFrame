class_name Stage
extends Node2D

var player_scene: PackedScene = Gametray.chosen_player_type
var background_scene: PackedScene
var spellcard_background_scene: PackedScene

var sections: Array[Callable] = []
var boss: Enemy

signal section_cleared
signal all_sections_cleared

func pre_start():
	pass

func start():
	var player: Player = player_scene.instantiate()
	add_child(player)
	player.global_position = Vector2(0, 512)
	if background_scene != null:
		var background: Node = background_scene.instantiate()
		add_child(background)
		background.global_position = Vector2(-384, -240)
	else: printerr("no background provided for this stage!")
	if spellcard_background_scene != null:
		var spellcard_background: Node = spellcard_background_scene.instantiate()
		add_child(spellcard_background)
		spellcard_background.global_position = Vector2(-384, -240)
	else: printerr("no spellcard background provided for this stage!")
	
	Gametray.player = player
	%GameUI.start_ui()
	
	await Transition.finished
	
	for section in sections:
		await section.call()
		emit_signal("section_cleared")
	
	await Tool.quick_timer(1).timeout
	emit_signal("all_sections_cleared")
	
	if Gametray.full_run and get_script() == Gametray.stage_order[-1]:
		%GameUI.open_game_clear_menu()
	elif Gametray.full_run and not Gametray.stage_order.find(get_script()) == Gametray.stage_order[-1]:
		pass
		##stage clear screen
		##next stage
	elif not Gametray.full_run:
		%GameUI.open_game_clear_menu()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	
	##Point of Collection-- if player's y value is low enough (y < 0), all items start tracking the player
	if Gametray.player.global_position.y <= 0 and not Gametray.player.respawning:
		Gametray.player._collect_all_items()
	
