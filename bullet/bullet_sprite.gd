@tool
extends Node2D

@export_tool_button("Print Hitbox Transform") var export_hitbox_info = export
func export():
	var st = \
	"PackedVector2Array([" + \
	"Vector2" + str(%Hitbox.get_transform().x) + ", " + \
	"Vector2" + str(%Hitbox.get_transform().y) + ", " + \
	"Vector2" + str(%Hitbox.get_transform().origin) + "])"
	print(st)

@export_tool_button("Redraw") var redraw = queue_redraw

@export var bullet_type: Danmaku.Bullet_Type: 
	set(value):
		if not is_inside_tree():
			await tree_entered
		bullet_type = value
		bottom = Danmaku.type_dict[value][0]
		top = Danmaku.type_dict[value][1]
		if Danmaku.type_dict[value][2]:
			if Danmaku.type_dict[value][2].count(Vector2.ZERO) == 3:
				get_parent().set_collision_layer_value(2, false)
				#%Hitbox.set_deferred("disabled", true)
			else:
				%Hitbox.transform = \
				Transform2D(Danmaku.type_dict[value][2][0],Danmaku.type_dict[value][2][1],Danmaku.type_dict[value][2][2])
			
		queue_redraw()

@export var bottom: Texture2D:
	set(value):
		bottom = value
@export var top: Texture2D:
	set(value):
		top = value
@export var color: Color = Color.RED:
	set(value):
		color = value
		queue_redraw()

var passive_rotation: float = 0

func _draw() -> void:
	if bottom != null:
		draw_texture(bottom, Vector2.ZERO - bottom.get_size()/2, color)
	if top != null:
		draw_texture(top, Vector2.ZERO - top.get_size()/2, lerp(Color.WHITE, color, 0.02))

func _process(delta: float) -> void:
	if passive_rotation != 0:
		rotation_degrees += passive_rotation
