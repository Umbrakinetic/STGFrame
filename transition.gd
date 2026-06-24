extends Control

var next_scene_path: String

const trans_time: float = 0.5

signal finished

func _ready() -> void:
	%ColorRect.material.set_shader_parameter("screen_cover", 0.0)
	%ColorRect.hide()
	%Text.hide()

func fade_in():
	%ColorRect.show()
	var tween = Tool.quick_tween(%ColorRect, "material:shader_parameter/screen_cover", 1.0, trans_time)
	await tween.finished
	%Text.show()
	
	emit_signal("finished")

func fade_out():
	%Text.hide()
	var tween = Tool.quick_tween(%ColorRect, "material:shader_parameter/screen_cover", 0.0, trans_time)
	await tween.finished
	%ColorRect.hide()
	
	emit_signal("finished")

func load_next_scene(path: String):
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
		fade_out()
		set_process(false)
