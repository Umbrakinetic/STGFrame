extends Control

var player

var boss: Boss

var graze_count: int = 0

var life_texture = preload("uid://bi0yej7noch3r")
var bomb_texture = preload("uid://cfpshct2k52qa")

## temporary fix?
## when timing out a boss's pattern, the healthbar is set to full, currently (should be empty).
## this fixes that
var tracking_health: bool = true


func _ready() -> void:
	%BossInfo.hide()
	
	reset_spell_ui()

## The reason this is not a _ready() function is because it fires before Stage.player is defined;
## So it is only manually called *after* that variable is defined.
func start_ui() -> void:
	if player != null: return
	player = Stage.player
	Stage.player.resources_updated.connect(update_resources)
	update_resources()
	
	player.grazed.connect(func():
		graze_count += 1
		%GrazeCount.text = str(graze_count)
	)

func boss_added() -> void:
	%BossInfo.show()
	boss = Gametray.get_node("Boss")
	boss.spell_declared.connect(declare_spell.bind())
	boss.phase_ended.connect(func():
		current_healthbar.value = 0
		reset_spell_ui()
	)
	
	boss.collection_started.connect(boss_collection_started.bind())
	boss_collection_started()
	
	set_process(true)
	%BossName.text = boss.boss_name
	boss.phase_started.connect(func():
		current_healthbar = healthbars[boss.current_phase_num]
		current_healthbar.max_value = boss.health
		current_healthbar.value = boss.health
		tracking_health = true
		%BossPhaseTimer.start(\
		boss.current_phase.get_phase_time() + 2 if boss.current_phase_num == 0
		else boss.current_phase.get_phase_time() + 1
		)
	)
	boss.defeated.connect(func():
		set_process(false)
		boss = null
		queue_redraw()
		%BossInfo.hide()
		%BossPhaseTimer.stop()
	)


var healthbars: Array[ProgressBar]
var current_healthbar: ProgressBar
var current_healthbar_num: int = 0

func boss_collection_started():
	if boss.current_collection_num + 1 == boss.total_collection_size: 
		%BossPhaseCollectionCounter.hide()
	else:
		%BossPhaseCollectionCounter.show()
		%BossPhaseCollectionCounter.custom_minimum_size.x = 48 * (boss.total_collection_size - (boss.current_collection_num + 1))
	for node in %Healthbars.get_children():
		node.queue_free()
	healthbars.clear()
	var c: int = 1
	for phase in boss.current_collection_size:
		var phase_healthbar = preload("uid://ddym65lowcjss").instantiate()
		if c != boss.current_collection_size:
			phase_healthbar.self_modulate = Color.from_hsv(0, 0.5, 1)
			phase_healthbar.size_flags_stretch_ratio = 0.5
		
		%Healthbars.add_child(phase_healthbar)
		healthbars.push_front(phase_healthbar)
		c += 1
	current_healthbar = healthbars[0]


func update_resources() -> void:
	var lives = player.lives
	var bombs = player.bombs
	
	set_resource_counter(%LifeTexture, lives)
	set_resource_counter(%BombTexture, bombs)
	
	if lives < 0: 
		await Tool.quick_timer(1).timeout
		%GameOverMenu.pause()


func set_resource_counter(counter_node, resource_count) -> void:
	if resource_count <= 0: counter_node.hide()
	else: counter_node.show()
	counter_node.custom_minimum_size.x = 48 * resource_count


var spell_tween: Tween

func declare_spell(spell_name: String):
	reset_spell_ui()
	%SpellName.text = spell_name
	
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
	##real-time debug info
	%DebugBulletCount.text = "Bullet Count: " + str(Gametray.bullet_list.size())
	%DebugFPS.text = "FPS: " + str(snappedi(Engine.get_frames_per_second(), 1))
	
	if boss != null:
		queue_redraw()
		if current_healthbar != null and tracking_health:
			current_healthbar.value = boss.health
		
		%BossTimer.text = str(min(snapped(%BossPhaseTimer.time_left + 0.5, 1),99))
		if %BossPhaseTimer.time_left < 10: %BossTimer.add_theme_color_override("font_color", Color.RED)
		else: %BossTimer.add_theme_color_override("font_color", Color.WHITE)


func _draw() -> void:
	## Draws the boss position indicator at the bottom of the screen.
	if boss != null:
		var boss_x = clamp(boss.global_position.x + 448, 64, 832)
		draw_polygon([
			Vector2(boss_x, 936), 
			Vector2(boss_x + 8, 956), 
			Vector2(boss_x - 8, 956)], 
			[Color.WHITE
			])

signal confirm_next_stage
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("shoot") and %StageClearMenu.visible:
		emit_signal("confirm_next_stage")
		%StageClearMenu.hide()
	
	if Input.is_action_just_pressed("pause") and not %PauseMenu.switched_pause_this_frame:
		%PauseMenu.pause()
	else:
		%PauseMenu.resume()

func open_stage_clear_menu():
	%StageClearMenu.show()

func open_game_clear_menu():
	%GameClearMenu.pause()

func _on_boss_phase_timer_timeout() -> void:
	tracking_health = false
	current_healthbar.value = 0
	boss._die()
