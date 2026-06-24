class_name Item
extends Area2D

var item_gravity:     float = 0.098
var initial_velocity: Vector2 = Vector2(0, -4)
var velocity:         Vector2 = initial_velocity
var max_velocity:     float = 6

var tracking_player:  bool = false

var sprite_dict: Dictionary[ItemType, Texture2D] = {
	ItemType.POINT  : preload("uid://cj2flfxe1v0qw"),
	ItemType.POWER  : preload("uid://4jpdwepgww7b"),
}

enum ItemType {
	POINT,
	POWER,
	EXTEND,
	BOMB,
}

var sprite: ItemType:
	set(value):
		sprite = value
		$ItemSprite.texture = sprite_dict[sprite]

func _ready() -> void:
	scale = Vector2.ZERO
	var tween : = Tool.quick_tween(self, "global_rotation_degrees", global_rotation_degrees + 360, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.3)
	#tracking_player = true

func _physics_process(delta: float) -> void:
	if not tracking_player:
		velocity.y = clamp(velocity.y + item_gravity, -4, 2.5)
		global_position.y += velocity.y
	else:
		if Gametray.player.respawning:
			tracking_player = false
			velocity = Vector2.ZERO
		velocity = global_position.direction_to(Gametray.player.global_position) * 16
	
	global_position += velocity
	
	if global_position.y > 688: queue_free()
