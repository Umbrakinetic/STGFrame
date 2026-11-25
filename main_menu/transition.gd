extends Control

var next_scene_path: String

var transitioning: bool = false

const trans_time: float = 0.5

signal finished

const MAIN_MENU = "res://main_menu/main_menu.tscn"
const STAGE     = "res://stage/stage.tscn"

var next_stage_script: GDScript = preload("uid://d1vogmed8b64b")

func _ready() -> void:
	%ColorRect.material.set_shader_parameter("screen_cover", 0.0)
	%ColorRect.hide()
	%Text.hide()
	randomize_noise()
	set_process(false)

func fade_in():
	%ColorRect.show()
	var tween = Tool.quick_tween(%ColorRect, "material:shader_parameter/screen_cover", 1.0, trans_time)
	await tween.finished
	
	randomize_noise()
	%Text.show()
	
	emit_signal("finished")

func fade_out():
	%Text.hide()
	var tween = Tool.quick_tween(%ColorRect, "material:shader_parameter/screen_cover", 0.0, trans_time)
	await tween.finished
	
	randomize_noise()
	%ColorRect.hide()
	
	emit_signal("finished")

func randomize_noise():
	%ColorRect.material.get_shader_parameter("noise").noise.seed = randi()

func load_next_scene(scene_path: String, stage_script: GDScript = preload("uid://d1vogmed8b64b")):
	if transitioning: return
	transitioning = true
	
	next_scene_path = scene_path
	next_stage_script = stage_script
	
	release_focus()
	await fade_in()
	
	ResourceLoader.load_threaded_request(scene_path, "", true)
	set_process(true)

var progress = []
func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	
	%Text.text = "Please Wait Warmly\n(Loading... " + str(int(progress[0] / 100)) + "%)"
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var next_scene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(next_scene)
		if next_scene.resource_path.contains("stage"):
			await get_tree().scene_changed
			get_tree().current_scene.set_script(next_stage_script)
			get_tree().current_scene.start()
			
		fade_out()
		transitioning = false
		set_process(false)

func next_stage(stage: GDScript):
	get_tree().current_scene.set_script(stage)
	get_tree().current_scene.start()
