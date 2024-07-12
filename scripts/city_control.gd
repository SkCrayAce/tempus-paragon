extends "res://scripts/overworld_control.gd"


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	AudioPlayer.play_music_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
