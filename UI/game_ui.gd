extends Control

var player

var boss

var graze_count: int = 0

var life_texture = preload("uid://bi0yej7noch3r")
var bomb_texture = preload("uid://cfpshct2k52qa")

func _ready() -> void:
	%BossInfo.hide()
	
	%SpellName.text = ""
	%SpellNameBG.modulate.a = 0
	%SpellNameBG.scale = Vector2(2, 2)
	%SpellNameBG.offset_transform_position_ratio.y = 8.33

## The reason this is not a _ready() function is because it fires before Gametray.player is defined;
## So it is only manually called *after* that variable is defined.
func start_ui() -> void:
	player = Gametray.player
	Gametray.player.resources_updated.connect(update_resources)
	update_resources()
	
	player.grazed.connect(func():
		graze_count += 1
		%GrazeCount.text = str(graze_count)
	)

func boss_added() -> void:
	%BossInfo.show()
	boss = Gametray.get_node("Boss")
	boss.spell_declared.connect(declare_spell.bind())
	boss.phase_ended.connect(reset_spell_ui.bind())
	
	set_process(true)
	%BossName.text = boss.boss_name
	boss.phase_started.connect(func():
		%BossHealthBar.max_value = boss.health
		%BossHealthBar.value = boss.health
		%BossPhaseTimer.start(\
		boss.current_phase.get_phase_time() + 2 if boss.current_phase_num == 0
		else boss.current_phase.get_phase_time() + 1
		)
	)
	boss.defeated.connect(func():
		set_process(false)
		%BossInfo.hide()
	)

func update_resources() -> void:
	var lives = player.lives
	var bombs = player.bombs
	
	set_resource_counter(%LifeTexture, lives)
	set_resource_counter(%BombTexture, bombs)
	
	if lives < 0: %GameOverMenu.pause()

func set_resource_counter(counter_node, resource_count) -> void:
	if resource_count <= 0: counter_node.hide()
	else: counter_node.show()
	counter_node.custom_minimum_size.x = 48 * resource_count

var spell_tween: Tween

func declare_spell(spell_name: String):
	%SpellName.text = spell_name
	%SpellNameBG.modulate.a = 0
	%SpellNameBG.offset_transform_scale = Vector2(2, 2)
	%SpellNameBG.offset_transform_position_ratio.y = 8.33
	
	if spell_tween != null: spell_tween.kill()
	
	spell_tween = Tool.quick_tween(%SpellNameBG, "offset_transform_scale", Vector2.ONE, 0.75, Tween.EASE_OUT)
	spell_tween.parallel().tween_property(%SpellNameBG, "modulate:a", 1, 0.75)
	spell_tween.tween_interval(0.2)
	spell_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	spell_tween.tween_property(%SpellNameBG, "offset_transform_position_ratio:y", 0, 1)

func reset_spell_ui():
	%SpellName.text = ""
	%SpellNameBG.modulate.a = 0
	%SpellNameBG.offset_transform_scale = Vector2(2, 2)
	%SpellNameBG.offset_transform_position_ratio.y = 8.33

func _process(delta: float) -> void:
	if boss != null:
		%BossHealthBar.value = lerp(\
		%BossHealthBar.value, boss.health, 0.2)
		
		%BossTimer.text = str(min(snappedi(%BossPhaseTimer.time_left + 0.5, 1),99))
		if %BossPhaseTimer.time_left < 10: %BossTimer.add_theme_color_override("font_color", Color.RED)
		else: %BossTimer.add_theme_color_override("font_color", Color.WHITE)
		
		%BossPhasesRemaining.text = str(boss.current_phase_num + 1) + "/" + str(boss.phases.size())

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause") and not %PauseMenu.switched_pause_this_frame:
		%PauseMenu.pause()
	else:
		%PauseMenu.resume()

func open_game_clear_menu():
	%GameClearMenu.pause()

func _on_boss_phase_timer_timeout() -> void:
	boss.health = 0
	boss._on_death()
