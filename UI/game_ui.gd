extends Control

var player

var boss

var graze_count: int = 0

var boss_present: bool = false:
	set(value):
		boss_present = value
		%BossInfo.visible = value

var life_texture = preload("uid://by5bhbi1is1k0")
var bomb_texture = preload("uid://cfpshct2k52qa")


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
	boss = Gametray.get_node("Boss")
	%BossName.text = boss.boss_name
	boss.phase_started.connect(func():
		%BossHealthBar.max_value = boss.health
		%BossHealthBar.value = boss.health
	)
	boss.defeated.connect(func():
		boss_present = false
		
	)

func update_resources() -> void:
	var lives = player.lives
	var bombs = player.bombs
	
	set_resource_counter(%LifeTexture, lives)
	set_resource_counter(%BombTexture, bombs)

func set_resource_counter(counter_node, resource_count) -> void:
	if resource_count <= 0: counter_node.hide()
	else: counter_node.show()
	counter_node.custom_minimum_size.x = 48 * resource_count

func _physics_process(delta: float) -> void:
	if boss != null and boss_present:
		%BossHealthBar.value = lerp(\
		%BossHealthBar.value, boss.health, 0.2)
		
