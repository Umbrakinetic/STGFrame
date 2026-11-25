class_name Enemy
extends CharacterBody2D

enum SpriteType {
	COMMON_FAIRY,
	SUNFLOWER_FAIRY,
}

@export var health: float = 10

@export var drops: Dictionary [Item.ItemType, int]

@onready var player = Stage.player

## Determines whether the enemy can go past the off-screen borders that clear bullets
## and enemies by default.
var allowed_out_of_bounds: bool = false

## Used in the event that an enemy that can drop items shouldn't.
## (currently, only when full-clearing a screen of bullets and enemies.)
var drops_items: bool = true

var invincible: bool = false

signal died

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()

var dying: bool = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Bullet and body.is_in_group("playerbullet"):
		if body.cancellable: body.start_free()
		_damaged()
		if invincible: return
		take_damage(body.get_meta("Damage"))


func take_damage(damage_value: float) -> void:
	if invincible: return
	health -= damage_value
	if health <= 0 and not dying:
		dying = true 
		_die()

func _damaged():
	pass

func _die() -> void:
	var die_fx: = preload("uid://7qebyenh7k7e").instantiate()
	Gametray.add_child(die_fx)
	die_fx.global_position = global_position
	die_fx.get_child(0).play("radial_burst")
	
	died.emit()
	Tool.oneshot_sound(preload("uid://dhm262tj0gt2e"), 1, 0.65)
	if drops_items: give_drops()
	queue_free()

func give_drops() -> void:
	for type in drops:
		for count in drops[type]:
			pass
			var item: Item = preload("uid://bcdxc2w8v28fs").instantiate()
			Gametray.call_deferred("add_child", item)
			item.sprite = type
			item.global_position = global_position + Tool.rand_vector2(128, 128)
			item.global_position.x = clamp(item.global_position.x, -384, 384)
			##add item spawning

func wait(time_sec) -> void:
	if not is_inside_tree(): await tree_entered
	await get_tree().create_timer(time_sec, false, true).timeout

func set_behavior(behavior:Callable, args: Array) -> void:
	behavior.call(args)
