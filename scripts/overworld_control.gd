extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	TransitionScreen.transition_node.play("fade_in")
	global.current_scene = scene_file_path
	prints(global.current_scene)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
