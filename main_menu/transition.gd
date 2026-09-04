extends Control

var next_scene_path: String

var transitioning: bool = false

const trans_time: float = 0.5

signal finished

func _ready() -> void:
	%ColorRect.material.set_shader_parameter("screen_cover", 0.0)
	%ColorRect.hide()
	%Text.hide()
	randomize_noise()

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

func load_next_scene(path: String):
	if transitioning: return
	transitioning = true
	release_focus()
	await fade_in()
	next_scene_path = path
	set_process(true)
	ResourceLoader.load_threaded_request(next_scene_path, "", true)

func _process(delta: float) -> void:
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var next_scene = ResourceLoader.load_threaded_get(next_scene_path)
		get_tree().change_scene_to_packed(next_scene)
		if next_scene.resource_path.contains("stage"):
			await get_tree().scene_changed
			get_tree().current_scene.set_script(Gametray.next_stage)
			get_tree().current_scene.pre_start()
			get_tree().current_scene.start()
			
		fade_out()
		transitioning = false
		set_process(false)
