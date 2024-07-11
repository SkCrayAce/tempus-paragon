extends "res://scripts/slums_control.gd"

@onready var player_spawn_point = $PlayerSpawnPoint
@onready var virulent_spawn_point = $VirulentSpawnPoint
#var virulent_scene: PackedScene = preload("res://scenes/characters/virulent_o.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	
	#if global.player_pos_pre_battle and global.battle_won:
		#player_instance.position = global.player_pos_pre_battle
		#global.battle_won = false
		#global.current_scene = null
		#add_child(player_instance)
	#else:
	if not (global.player_pos_pre_battle and global.battle_won):
		player_instance.position = player_spawn_point.position
		virulent_instance.position = virulent_spawn_point.position
		add_child(virulent_instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
