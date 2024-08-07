extends "res://scripts/slums_control.gd"

@onready var virulent_spawn_point = $VirulentSpawnPoint
@onready var player_animation_start = $PlayerAnimationStart
@onready var player_animation_end = $PlayerAnimationEnd
@onready var item_spawn_point = $ItemSpawnPoint

@onready var tile_map = $TileMap as TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if not global.battle_won:
		player_instance.position = player_animation_start.position
		add_child(player_instance)
		player_instance.anim.play("side_walk_right")
		super.player_entry_animation(player_instance, player_animation_end.position)
		player_instance.anim.play("idle")
		
		for i in randi_range(3, 5):
			super.spawn_enemy(tile_map, top_leftmost_spawn_coords, bottom_rightmost_spawn_coords)
		
	elif global.battle_won:
		super.despawn_enemy(virulent_instance)
		global.drop_random_item(item_spawn_point.position)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
