extends "res://scripts/slums_control.gd"

@onready var player_spawn_point = $PlayerSpawnPoint



# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if not (global.player_pos_pre_battle and global.battle_won):
		player_instance.position = player_spawn_point.position
		virulent_instance.position = virulent_spawn_point.position
		add_child(virulent_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
