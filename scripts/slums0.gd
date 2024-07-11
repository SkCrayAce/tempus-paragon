extends "res://scripts/slums_control.gd"

@onready var player_spawn_point = $PlayerSpawnPoint



func _ready():
	super._ready()
	prints("nahh, i'd win")
	
	player_instance.position = player_spawn_point.position
	add_child(player_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


