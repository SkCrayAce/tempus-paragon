class_name door extends Area2D

@export var destination_level_tag: String
@export var destination_door_tag: String
@export var spawn_direction = "up"

@onready var spawn = $Spawn

func _on_body_entered(body):
	if body is Player:
		global.levels_cleared += 1
		NavigationManager.next_level(global.levels_cleared)
