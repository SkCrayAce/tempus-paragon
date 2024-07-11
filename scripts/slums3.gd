extends "res://scripts/slums_control.gd"

@onready var player_spawn_point = $PlayerSpawnPoint
@onready var virulent_spawn_point = $VirulentSpawnPoint
@onready var tile_map = $TileMap as TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	var random_position
	if not (global.player_pos_pre_battle and global.battle_won):
		player_instance.position = player_spawn_point.position
		add_child(player_instance)
		for i in range(4):
			virulent_instance = virulent_scene.instantiate() as CharacterBody2D
			random_position = tile_map.map_to_local(super.generate_random_vector(top_leftmost_spawn_coords, bottom_rightmost_spawn_coords))
			virulent_instance.position = random_position
			add_child(virulent_instance)
		
	if global.battle_won:
		remove_child(virulent_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
