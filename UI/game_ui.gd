extends Control

var player

var boss

var graze_count: int = 0

var life_texture = preload("uid://by5bhbi1is1k0")
var bomb_texture = preload("uid://cfpshct2k52qa")

func _ready() -> void:
	%BossInfo.hide()

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
	set_process(true)
	%BossName.text = boss.boss_name
	boss.phase_started.connect(func():
		%BossHealthBar.max_value = boss.health
		%BossHealthBar.value = boss.health
		%BossPhaseTimer.start(30)
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

func _physics_process(delta: float) -> void:
	if boss != null:
		%BossHealthBar.value = lerp(\
		%BossHealthBar.value, boss.health, 0.2)
		
		%BossTimer.text = str(snappedi(%BossPhaseTimer.time_left, 1))
		
		%BossPhasesRemaining.text = str(boss.current_phase + 1) + "/" + str(boss.phases.size())

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
