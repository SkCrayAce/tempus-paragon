extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if $MainMenuMusic.playing == false:
		$MainMenuMusic.playing = true


func _on_play_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/areas/slums.tscn")


func _on_button_3_pressed():
	get_tree().quit()
