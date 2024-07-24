extends "res://scripts/slums_control.gd"

@onready var player_spawn_point = $PlayerSpawnPoint
@onready var item_spawn_point = $ItemSpawnPoint


func _ready():
	super._ready()
	global.levels_cleared -= 1
	prints(global.levels_cleared)
	player_instance.position = player_spawn_point.position
	add_child(player_instance)
	global.drop_random_item(item_spawn_point.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


