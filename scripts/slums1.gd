extends "res://scripts/slums_control.gd"


@onready var player_animation_start = $PlayerAnimationStart
@onready var player_animation_end = $PlayerAnimationEnd
@onready var tile_map = $TileMap as TileMap


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	var random_position
	if not (global.player_position and global.battle_won):
		player_instance.position = player_animation_start.position
		add_child(player_instance)
		super.player_entry_animation(player_instance, player_animation_end.position)
		
		for i in range(4):
			var randnum = randi() % virulent_scenes.size()
			virulent_instance = virulent_scenes[randnum].instantiate() as CharacterBody2D
			random_position = tile_map.map_to_local(super.generate_random_vector(top_leftmost_spawn_coords, bottom_rightmost_spawn_coords))
			virulent_instance.position = random_position
			add_child(virulent_instance)
			super.spawn_enemy(tile_map, top_leftmost_spawn_coords, bottom_rightmost_spawn_coords)
		
	elif global.battle_won:
		super.despawn_enemy(virulent_instance)
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
