extends Node2D

var player_scene : PackedScene = preload("res://scenes/characters/player.tscn")
var virulent_scene: PackedScene = preload("res://scenes/characters/virulent_o.tscn")

@onready var player_instance = player_scene.instantiate() as CharacterBody2D
@onready var virulent_instance = virulent_scene.instantiate() as CharacterBody2D

func _ready():
	AudioPlayer.play_music_level()
	prints("would you lose?")
	
	if global.player_pos_pre_battle and global.battle_won:
		player_instance.position = global.player_pos_pre_battle
		global.battle_won = false
		global.current_scene = null
		add_child(player_instance)
	
	

func _process(delta):
	if AudioPlayer.playing == false:
		AudioPlayer.playing = true
