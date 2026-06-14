extends ColorRect


func fade_in():
	var tween: = Tool.quick_tween(self, "color:a", 1, 0.5)
	await tween.finished


func fade_out():
	var tween: = Tool.quick_tween(self, "color:a", 0, 0.5)
	await tween.finished
