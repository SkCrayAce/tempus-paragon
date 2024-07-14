extends "res://scripts/slums_control.gd"

@onready var player_animation_start = $PlayerAnimationStart
@onready var player_animation_end = $PlayerAnimationEnd
@onready var camera_zoom = $CameraZoom
@onready var zoom = $Zoom
@onready var tile_map = $TileMap


func _ready():
	#Not count bossfight level to the 3 levels per area
	global.levels_cleared -= 1
	NavigationManager.bossfight_done = true
	
	super._ready()
	if not global.battle_won:
		player_instance.position = player_animation_start.position
		add_child(player_instance)
		play_entry_anim()
		

func _process(delta):
	pass
	


func play_entry_anim():
	setup_cam()
	global.player_input_enabled = false
	tween = create_tween()
	tween.tween_property(player_instance, "position", player_animation_end.position, 2)
	
	player_instance.cam.enabled = false
	player_instance.anim.play("side_walk_right")
	await get_tree().create_timer(2).timeout
	
	player_instance.anim.play("side_idle_right")
	camera_zoom.play("Zoom")
	await get_tree().create_timer(1).timeout
	
	zoom.enabled = false
	player_instance.cam.enabled = true
	global.player_input_enabled = true

func setup_cam():
	zoom.position = player_animation_end.position
	var tilemap_rect = player_instance.current_tile_map.get_used_rect()
	var tilemap_cell_size = player_instance.current_tile_map.tile_set.tile_size 
	zoom.limit_left = tilemap_rect.position.x * tilemap_cell_size.x 
	zoom.limit_right = tilemap_rect.end.x * tilemap_cell_size.x
	zoom.limit_bottom = tilemap_rect.end.y * tilemap_cell_size.y 
	zoom.limit_top = tilemap_rect.position.y * tilemap_cell_size.y 
