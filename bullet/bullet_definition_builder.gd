##Tool that easily allows building of the bullet definition.
##This includes the constants and enum, and an editor to prepare bullet types visually

@tool
extends Node2D

@export var bullet_types: PackedStringArray

var anim_count: int = 0
var anim_frame_count: int = 0
func _process(delta: float) -> void:
	anim_count += 1
	if anim_count % anim_fps == 0: anim_frame_count += 1
	for i: Sprite2D in [$TopSprite, $BottomSprite]:
		i.global_rotation_degrees += passive_rotation
		i.frame = anim_frame_count % i.hframes

@export_tool_button("Print Bullet Definition List", "Script") var export_bullet_definition_string = export_bullet_definition
func export_bullet_definition():
	
	## Get the longest entry in the array
	## (To format the constants section)
	var longest_count: int = 0
	for i in bullet_types:
		if i.length() > longest_count: longest_count = i.length()
	
	var to_print: String = ""
	
	## Create the constants
	var count: int = 0
	var const_string: String = ""
	for i in bullet_types:
		var spacing: String = ""
		for l in (longest_count - i.length()):
			spacing += " "
		const_string += "const " + i + spacing + " = " + str(count) + "\n"
		count += 1
	to_print += const_string
	
	## Create the enum
	var enum_string: String = "enum Bullet_Type {\n"
	for i in bullet_types:
		enum_string += ("	" + i + ",\n")
	enum_string += "}"
	to_print += enum_string
	
	print(to_print)

@export_tool_button("Print Bullet Info", "Script") var export_bullet_info_string = export_bullet_info
func export_bullet_info():
	var bottom_uid: = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(str($BottomSprite.texture.resource_path)))
	var top_uid: = ResourceUID.id_to_text(ResourceLoader.get_resource_uid(str($TopSprite.texture.resource_path)))
	
	var bullet_info_string: String = "TYPE_BULLETNAMEHERE : [\n" + \
	
	"\tpreload(\"" + bottom_uid + "\"),\n" + \
	"\tpreload(\"" + top_uid    + "\"),\n"
	
	var hitbox_string = "\t" + \
	"PackedVector2Array([" + \
	"Vector2" + str(%BulletHitbox.get_transform().x) + ", " + \
	"Vector2" + str(%BulletHitbox.get_transform().y) + ", " + \
	"Vector2" + str(%BulletHitbox.get_transform().origin) + "]),"
	
	bullet_info_string += hitbox_string
	bullet_info_string += "\n],"
	
	print(bullet_info_string)

@export_category("Bullet Properties")
@export var bullet_name: String = ""
@export var frames: int = 1:
	set(value):
		frames = max(value, 1)
		$TopSprite.hframes = frames
		$BottomSprite.hframes = frames
@export var anim_fps: int = 8:
	set(value):
		anim_fps = max(value, 1)
@export var passive_rotation: float = 0
@export_tool_button("Reset Rotation", "Undo") var reset_rotation = func():
	passive_rotation = 0
	$TopSprite.global_rotation_degrees = 0
	$BottomSprite.global_rotation_degrees = 0
