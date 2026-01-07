extends Control

@onready var player = get_tree().current_scene.get_node("Player")

var graze_count: int = 0

var boss_present: bool = false:
	set(value):
		boss_present = value
		%BossInfo.visible = value

var life_texture = preload("uid://c64nnupck6cy1")
var bomb_texture = preload("uid://buh7ownntc031")

func _ready() -> void:
	player.resources_updated.connect(update_resources)
	update_resources()
	
	player.grazed.connect(func():
		graze_count += 1
		%GrazeCount.text = "GRAZE: " + str(graze_count)
	)

func boss_added() -> void:
	%BossName.text = Tool.boss.boss_name
	Tool.boss.phase_started.connect(func():
		%BossHealthBar.max_value = Tool.boss.health
		%BossHealthBar.value = Tool.boss.health
	)
	Tool.boss.defeated.connect(func():
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
	if Tool.boss != null and boss_present:
		%BossHealthBar.value = Tool.boss.health
