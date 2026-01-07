
extends Node
# Handles everything associated with bullets, lasers and objects.
# Not exclusive to "bullets" like the title implies, but it pretty much only affects bullet-hell-related things, so...

#var Gametray

func refresh_vars() -> void:
	pass
	#Gametray = get_tree().current_scene.get_node("Gametray")

#region Bullet Definition

const TYPE_CIRCLE    = 0
const TYPE_ARROWHEAD = 1
const TYPE_SCALE     = 2
const TYPE_STAR      = 3
const TYPE_BLADE     = 4
const TYPE_LTRLBULLET= 5
const TYPE_DROPLET   = 6
const TYPE_CRYSTAL   = 7
const TYPE_FLOWER    = 8
const TYPE_HEART     = 9
const TYPE_AMULET    = 10
const TYPE_SQUARE    = 11
const TYPE_SLAVE     = 12

enum Bullet_Type {
	TYPE_CIRCLE,
	TYPE_ARROWHEAD,
	TYPE_SCALE,
	TYPE_STAR,
	TYPE_BLADE,
	TYPE_LTRLBULLET,
	TYPE_DROPLET,
	TYPE_CRYSTAL,
	TYPE_FLOWER,
	TYPE_HEART,
	TYPE_AMULET,
	TYPE_SQUARE,
	
	TYPE_SLAVE,

#TYPE_FOURSTAR,
#TYPE_FIVESTAR,
#TYPE_FLUX,
#TYPE_CUBE,
}

var type_dict: Dictionary[Bullet_Type, Array] = {
	TYPE_CIRCLE : [
		preload("uid://cn41eioj5bci2"), ##Bottom Sprite
		preload("uid://ctspv41uplp2w"), ##Top Sprite
		PackedVector2Array([            ##Hitbox Transform
			Vector2(1.175, 0.0), Vector2(0.0, 1.175), Vector2(0.0, 0.0)
		]),
	],
	TYPE_ARROWHEAD : [
		preload("uid://begcn0v515v5d"), 
		preload("uid://bpsn8nt18a74x"), 
		PackedVector2Array([Vector2(1.225, 0.0),Vector2(0.0, 1.07),Vector2(-2.0, 0.0)]) 
	],
	TYPE_SCALE : [
		null,
		null,
		null,
	],
	TYPE_STAR : [
		preload("uid://beutbbk8b73f1"),
		preload("uid://cud8ha8exmwed"),
		PackedVector2Array([Vector2(1.44, 0.0), Vector2(0.0, 1.44), Vector2(-3.015, 0.0)])
	],
	TYPE_BLADE : [
		null,
		null,
		null,
	],
	TYPE_LTRLBULLET : [
		preload("uid://bvf7vs7uj6xg"), 
		preload("uid://cinahlei7woqp"), 
		PackedVector2Array([Vector2(2.0, 0.0), Vector2(0.0, 0.65), Vector2(0.0, 0.0)])
	],
	TYPE_DROPLET : [
		null,
		null,
		null,
	],
	TYPE_CRYSTAL : [
		preload("uid://dim0dtvfwjn7f"), 
		preload("uid://y23x8gvo0bho"), 
		PackedVector2Array([Vector2(1.48, 0.0), Vector2(0.0, 0.83), Vector2(0.0, 0.0)])
	],
	TYPE_FLOWER : [
		preload("uid://sylq8croohvf"), 
		preload("uid://c3wj7vxojir7c"), 
		PackedVector2Array([Vector2(2.045, 0.0), Vector2(0.0, 2.045), Vector2(-2.0, 0.0)])
	],
	TYPE_HEART : [
		preload("uid://ca6743anyg4cw"), 
		preload("uid://c62371rbi08hp"), 
		PackedVector2Array([Vector2(2.05, 0.0), Vector2(0.0, 2.05), Vector2(-0.955, 0.0)])
	],
	TYPE_AMULET : [
		null,
		null,
		null,
	],
	
	TYPE_SQUARE : [
		preload("uid://dgubyl47j20d6"),
		preload("uid://b6kquodabdlco"),
		PackedVector2Array([Vector2(1.35, 0.0), Vector2(0.0, 1.35), Vector2(0.0, 0.0)])
	],
	
	TYPE_SLAVE : [
		preload("uid://cqsq5hog5bg11"),
		null,
		PackedVector2Array([Vector2.ZERO, Vector2.ZERO, Vector2.ZERO])

	],
}

#var Type_Dictionary: = {
	#TYPE_PELLET     : [preload("../bullet/sprites/pellet_top.png"), preload("../bullet/sprites/pellet_bottom.png"), preload("res://bullet/hitbox_shapes/pellet.tres"), Vector2(0, 0)],
	#TYPE_ARROWHEAD  : [preload("res://bullet/sprites/arrowhead_top.png"), preload("res://bullet/sprites/arrowhead_bottom.png"), preload("res://bullet/hitbox_shapes/arrowhead.tres"), Vector2(-5, 0)],
	#TYPE_BLADE      : [preload("res://bullet/sprites/blade_top.png"), preload("res://bullet/sprites/blade_bottom.png"), preload("res://bullet/hitbox_shapes/blade.tres"), Vector2(5, 0)],
	#TYPE_CRYSTAL    : [preload("res://bullet/sprites/crystal_top.png"),preload("res://bullet/sprites/crystal_bottom.png"), preload("res://bullet/hitbox_shapes/blade.tres"), Vector2(0, 0)],
	#
	#TYPE_FOURSTAR   : [preload("res://bullet/sprites/4star_top.png"), preload("res://bullet/sprites/4star_bottom.png"), preload("res://bullet/hitbox_shapes/pellet.tres"), Vector2(0, 0)],
	#TYPE_FIVESTAR   : [preload("res://bullet/sprites/5star_top.png"), preload("res://bullet/sprites/5star_bottom.png"), preload("res://bullet/hitbox_shapes/pellet.tres"), Vector2(0, 0)],
	#TYPE_FLUX       : [preload("res://bullet/sprites/flux_top.png"), preload("res://bullet/sprites/flux_bottom.png"), preload("res://bullet/hitbox_shapes/pellet.tres"), Vector2(0, 0)],
	#TYPE_CUBE       : [preload("res://bullet/sprites/cube_top.png"), preload("res://bullet/sprites/cube_bottom.png"), preload("res://bullet/hitbox_shapes/pellet.tres"), Vector2(0, 0)],
#}

## bullet types with animations. 
## value is the number of frames of the key.
#var animated_types: Dictionary = {
	#TYPE_FOURSTAR   : 3,
	#TYPE_FIVESTAR   : 3,
	#TYPE_FLUX       : 4,
	#TYPE_CUBE       : 7,
#}

#endregion

#region Bullets
const BULLET = preload("uid://pxmibwiq84n0")

func spawn_bullet(spawn_position: Vector2, speed: float, angle: float, type: Bullet_Type = TYPE_CIRCLE, color: Color = Color.RED, origin: Node2D = null, delay: float = 0.2, distance: float = 0, bearing: float = 0 ) -> Bullet:
	if Gametray.bullet_list.size() > Gametray.max_bullet_count:
		Gametray.refresh_bullet_list()
		Gametray.bullet_list.pop_front().start_free()
	var bullet: Bullet = BULLET.instantiate()
	bullet.set_speed(speed)
	bullet.set_angle(angle)
	bullet.delay = delay
	
	bullet.get_node("Sprite").color = color
	bullet.get_node("Sprite").bullet_type = (type)
	#if origin != null: bullet.origin  = origin
	#bullet.get_node("Hitbox").shape = Type_Dictionary[type][2] 
	
	Gametray.call_deferred("add_child", bullet)
	#Gametray.add_child(bullet)
	Gametray.bullet_list.append(bullet)
	if distance:
		bullet.position = spawn_position + (Vector2(cos(deg_to_rad(bearing)), sin(deg_to_rad(bearing))) * distance)
	else: 
		bullet.position = spawn_position
	
	return bullet

func spawn_slave(spawn_position: Vector2 = Vector2.ZERO, passive_rotation: float = 2) -> Bullet:
	var slave = spawn_bullet(spawn_position, 0, 90, TYPE_SLAVE, Color.WHITE, null, 0)
	slave.get_node("%Sprite").passive_rotation = passive_rotation
	slave.z_index -= 10
	return slave

func spawn_circle(count: int, spawn_position: Vector2, speed: float, angle: float, type: Bullet_Type = TYPE_CIRCLE, color: Color = Color.RED, origin: Node2D = null, delay: float = 0.2, distance: float = 0) -> Array[Bullet]:
		var circle: Array[Bullet]
		for i in count:
			var final_angle: float = angle + (360.0 / count) * i
			var b = Danmaku.spawn_bullet(spawn_position, speed,  final_angle, type, color, origin, delay, distance, final_angle)
			circle.append(b)
		return circle

func spawn_arc(count: int, spawn_position: Vector2, speed: float, angle: float, type: Bullet_Type = TYPE_CIRCLE, color: Color = Color.RED, origin: Node2D = null, spread: float = 15, delay: float = 0.2, distance: float = 0) -> Array[Bullet]:
	var arc: Array[Bullet]
	var bullet_angle = angle - (spread / 2.0)
	if not count % 2:
		bullet_angle -= (spread/float(count)) / 2.0
	for i in count:
		var b = Danmaku.spawn_bullet(spawn_position, speed, bullet_angle, type, color, origin, delay, distance, bullet_angle)
		bullet_angle += spread / float(count)
		arc.append(b)
	return arc

func bullet_line(point1: Vector2, point2: Vector2, bullet_count: int = 5, wait_time: float = 0, origin: Node = null) -> Array[Bullet]:
	var array: Array[Bullet] = []
	for i in bullet_count - 1:
		var changed_angle: float = rad_to_deg(point1.angle_to_point(point2))
		var final_pos: Vector2 = lerp(point1, point2, float(i) / float(bullet_count - 1))
		#var final_angle: float = rad_to_deg(final_pos.angle_to_point(Global.player.global_position))
		
		var b = Danmaku.spawn_bullet(final_pos, 0, changed_angle, TYPE_ARROWHEAD, Color.BLUE, origin)
		array.append_array(b)
		
		if wait_time > 0:
			await get_tree().create_timer(wait_time, false, true).timeout
	return array

# makes a bullet act as if it's on the player's side.
# this means it hits enemies and not the player, has a "damage" value and attributes which affect its damage.
# also lowers its z-index as enemy bullets are more important than player bullets
func set_player_bullet(bullet: Bullet, damage_value: float = 10) -> void:
	bullet.add_to_group("playerbullet")
	bullet.set_meta("Damage", damage_value)
	bullet.z_index -= 10
	
#endregion

##region BulletParents
#func spawn_bullet_parent(prefab: PackedScene, position: Vector2, speed: float = 0, angle = 90, rotation_degrees: float = 0) -> BulletParent:
	#var bullet_parent: BulletParent = prefab.instantiate()
	#Gametray.add_child(bullet_parent)
	#bullet_parent.global_position = position
	#bullet_parent.global_rotation = rotation_degrees
	#var vec2 = Vector2.from_angle(deg_to_rad(angle))
	#bullet_parent.velocity = vec2 * speed
	#return bullet_parent
#
#
##endregion

#region Lasers
#const LASER = preload("res://laser.tscn")
#
#func spawn_laser(position: Vector2, angle: float, color: Color = Color.RED, active_time: float = 3, delay: float = 1.5, _solid: bool = false) -> Laser:
	#var laser: Laser = LASER.instantiate()
	#laser.rotation_degrees = angle
	#laser.delay = delay
	#laser.active_time = active_time
	#laser.color = color
	##laser.set_collision_mask_value(2, solid)
	#Gametray.call_deferred("add_child", laser)
	#laser.global_position = position
	#return laser
#
### Spawns an array of bullets along a laser's length.
### The number of bullets depends on the distance argument, where distance is the space between each bullet along the line.
#func laser_bullet_length(laser: Laser, distance: float, speed: float, angle: float, type: Bullet_Type, color: Color) -> Array[Bullet]:
	#var array: Array[Bullet] = []
	#var current_length: float = 0
	#var o = null
	#while current_length < laser.max_distance:
		#var pos = laser.global_position + Vector2(
			#current_length * cos(laser.global_rotation), 
			#current_length * sin(laser.global_rotation))
		#current_length += distance
		#if laser != null and laser.origin != null: o = laser.origin
		#var b = spawn_bullet(pos, speed, angle, type, color, o)
		#array.append(b)
		#
	#return array
#
### Spawns an array of bullets along a laser's length.
### The number of bullets is set in the count argument, spaced evenly along the laser's to its current end point.
#func laser_bullet_number(laser: Laser, count: int, speed: float, angle: float, type: Bullet_Type, color: Color) -> Array[Bullet]:
	#var array: Array[Bullet] = []
	#var o = null
	#var d = laser.end_point
	#for i in count:
		#var l = lerpf(0, d, (1.0 / count) * i)
		#var pos = laser.global_position + Vector2(
			#l * cos(laser.global_rotation), 
			#l * sin(laser.global_rotation))
		#if laser != null and laser.origin != null: o = laser.origin
		#var b = spawn_bullet(pos, speed, angle, type, color, o)
		#array.append(b)
	#return array

#func set_player_laser(laser: Laser, damage_value: float, attribute: Global.attribute_types = Global.attribute_types.NULL, special_attack_charge: float = 1) -> void:
	#pass
#endregion
