extends Control

@onready var return_button = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/ReturnButton as Button
 
# Called when the node enters the scene tree for the first time.
func _ready():
	return_button.pressed.connect(return_to_menu)
	pass # Replace with function body.

func return_to_menu():
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $MainMenuMusic.playing == false:
		$MainMenuMusic.playing = true
