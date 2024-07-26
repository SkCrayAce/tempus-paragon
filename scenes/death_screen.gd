extends Control

@onready var return_button = $ColorRect/VBoxContainer/ReturnButton
@onready var button_fade = $ColorRect/VBoxContainer/ReturnButton/AnimationPlayer

var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	global.player_input_enabled = true
	return_button = get_node("ColorRect/VBoxContainer/ReturnButton")
	button_fade = get_node("ColorRect/VBoxContainer/ReturnButton/AnimationPlayer")
	return_button.self_modulate = Color(1, 1, 1, 0)
	TransitionScreen.transition_node.play("fade_in", -1, 0.1)
	await TransitionScreen.fade_in_finished
	button_fade.play("fade_in")
	
	return_button.pressed.connect(get_tree().change_scene_to_file.bind("res://scenes/mainmenu.tscn"))
	
	pass # Replace with function body.

func show_button():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
