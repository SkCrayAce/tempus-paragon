extends "res://scripts/city_control.gd"



func _ready():
	super._ready()
	pass


func _process(delta):
	if AudioPlayer.playing == false:
		AudioPlayer.playing = true




