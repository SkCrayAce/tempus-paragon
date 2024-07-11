extends Node2D



func _ready():
	get_tree().change_scene_to_file("res://scenes/areas/battle.tscn")
	AudioPlayer.play_music_level()


func _process(delta):
	if AudioPlayer.playing == false:
		AudioPlayer.playing = true




