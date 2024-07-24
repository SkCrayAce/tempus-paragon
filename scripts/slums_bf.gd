extends "res://scripts/slums_control.gd"

@onready var player_animation_start = $PlayerAnimationStart
@onready var player_animation_end = $PlayerAnimationEnd
@onready var camera_zoom = $CameraZoom
@onready var zoom = $Zoom
@onready var tile_map = $TileMap
@onready var bossfight_start_anim = $BossfightStartAnim
@onready var slumsboss = $slumsboss_o
@onready var bossfight_trigger = $BossfightTrigger
@onready var item_spawn_point = $ItemSpawnPoint


func _ready():
	#Not count bossfight level to the 3 levels per area
	global.levels_cleared -= 1
	NavigationManager.bossfight_done = true
	
	super._ready()
	if not global.battle_won:
		player_instance.position = player_animation_start.position
		add_child(player_instance)
		play_entry_anim()
		
	elif global.battle_won:
		global.player_input_enabled = true
		super.despawn_enemy(slumsboss)
		camera_zoom.queue_free()
		bossfight_trigger.queue_free()
		zoom.queue_free()
		global.drop_random_item(item_spawn_point.position)

func _process(delta):
	pass
	

func play_entry_anim():
	if not global.battle_won:
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


func _on_bossfight_trigger_body_entered(body):
	if not global.battle_won:
		if body is Player:
			global.slums_boss_battle = true
			global.player_input_enabled = false
			player_instance.cam.enabled = false
			player_instance.anim.play("side_idle_right")
			zoom.enabled = true
			zoom.position = player_instance.position
		
			tween = create_tween()
			tween.tween_property(zoom, "position", slumsboss.position - Vector2(0, slumsboss.position.y - player_animation_end.position.y), 3).set_ease(Tween.EASE_IN_OUT)
			await get_tree().create_timer(3).timeout
			slumsboss.anim.play("laugh")
			slumsboss.boss_laugh.play()
			await get_tree().create_timer(3).timeout
			slumsboss.boss_laugh.stop()
			slumsboss.anim.play("idle")
			print(global.transition_commence)
			
			if global.transition_commence == false:
				global.transition_commence = true
				var trans_screen_scene = load("res://scenes/transitionto_battle.tscn")
				var trans_screen = trans_screen_scene.instantiate()
				get_tree().get_root().add_child(trans_screen)
				trans_screen.play_animation()
				await trans_screen.animation_player.animation_finished
				trans_screen.queue_free()
				get_tree().change_scene_to_file(BattleScene)
