extends "res://scripts/slums_control.gd"

@onready var player_spawn_point = $PlayerSpawnPoint


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	player_instance.position = player_spawn_point.position
	add_child(player_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
