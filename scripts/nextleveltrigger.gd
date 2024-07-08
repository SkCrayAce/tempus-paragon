class_name door extends Area2D

@onready var spawn = $Spawn
const Player = preload("res://scripts/player.gd")

func _on_body_entered(body):
	if body is Player:
		global.levels_cleared += 1
		NavigationManager.next_level(global.levels_cleared)
