extends Node

@export var player_scene : PackedScene 
var player_instance = player_scene.instantiate() as CharacterBody2D

func _ready():
	if global.player_position and global.battle_won:
		player_instance.position = global.player_position



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
