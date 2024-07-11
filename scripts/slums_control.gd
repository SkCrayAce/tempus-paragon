extends Node2D

var player_scene : PackedScene = preload("res://scenes/characters/player.tscn")
@onready var player_instance = player_scene.instantiate() as CharacterBody2D

func _ready():
	AudioPlayer.play_music_level()
	global.levels_cleared = 0
	prints("would you lose?")
	

func _process(delta):
	if AudioPlayer.playing == false:
		AudioPlayer.playing = true
