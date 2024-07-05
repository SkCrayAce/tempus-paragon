extends Node2D

func _ready():
	AudioPlayer.play_music_level()
	global.levels_cleared = 0

func _process(delta):
	if AudioPlayer.playing == false:
		AudioPlayer.playing = true


