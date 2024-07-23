extends Node

@export var min_num_of_groups : int = 2
@export var max_num_of_groups : int = 4
@export var num_of_waves : int = 1

var enemy_instance : CharacterBody2D
var dictionary = {}
var rng
var count : int
var waves_cleared : int
var team_health : int
var eme_skill_active : bool
var eme_skill_AoE : Array[Vector2i]


const grid_length : int = 120
const grid_height : int = 68
const ground_layer = 0
const hover_layer = 1
const melee_enemy_scene := preload("res://scenes/characters/melee_virulent.tscn")
const ranged_enemy_scene := preload("res://scenes/characters/ranged_virulent.tscn")
const slums_boss_scene := preload("res://scenes/characters/slums_boss.tscn")
const boss_death_scene := preload("res://scenes/characters/boss_death.tscn")
const top_left_tile = Vector2i(9, 3)
const bottom_right_tile = Vector2i(23, 10)

const min_hover_x : int = top_left_tile.x
const max_hover_x : int = bottom_right_tile.x
const min_hover_y : int = top_left_tile.y
const max_hover_y : int = bottom_right_tile.y

@onready var enemy_move_timer = $EnemyMoveTimer as Timer
@onready var move_timer_bar = $CanvasLayer/MoveTimerBar as TextureProgressBar
@onready var animation_timer = $AnimationTimer as Timer
@onready var push_timer = $PushTimer as Timer
@onready var slums_tile_map = $SlumsTileMap as TileMap
@onready var boss_defeated_anim = $BossDefeatedAnim
@onready var battle_start_popup = $CanvasLayer/BattleStartPopup
@onready var abilities_container = $CanvasLayer/AbilitiesContainer

@onready var kai_drag_icon = $DraggableIcons/kai/DragIcon
@onready var emerald_drag_icon = $DraggableIcons/emerald/DragIcon
@onready var tyrone_drag_icon = $DraggableIcons/tyrone/DragIcon
@onready var bettany_drag_icon = $DraggableIcons/bettany/DragIcon

@onready var kai_ability_btn = $CanvasLayer/AbilitiesContainer/AbilitiesRow/KaiAbility/UseAbilityBtn
@onready var emerald_ability_btn = $CanvasLayer/AbilitiesContainer/AbilitiesRow/EmeraldAbility/UseAbilityBtn
@onready var tyrone_ability_btn = $CanvasLayer/AbilitiesContainer/AbilitiesRow/TyroneAbility/UseAbilityBtn
@onready var bettany_ability_btn = $CanvasLayer/AbilitiesContainer/AbilitiesRow/BettanyAbility/UseAbilityBtn

var kai_offset_list = [Vector2i(1, 0), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
var emerald_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0)]
var tyrone_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var bettany_offset_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, -1)]
var sqaure_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)]
var v_rect_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1),  Vector2i(0, 2), Vector2i(1, 2)]
var h_rect_offset_list = [Vector2i(0, 0), Vector2i(0, 1),  Vector2i(1, 0),  Vector2i(1, 1),  Vector2i(2, 0),  Vector2i(2, 1)]


var current_offset_list : Array

@onready var kai = $DraggableIcons/kai
@onready var emerald = $DraggableIcons/emerald
@onready var tyrone = $DraggableIcons/tyrone
@onready var bettany = $DraggableIcons/bettany

@onready var trans_scene = preload("res://scenes/transitionto_battle.tscn")

var enemy_list : Array[CharacterBody2D]
var used_vectors : Array[Vector2i]
var anim_start = false

signal wave_finished

func _ready():
	show_start_screen()
	ui_start_animation()
	
	AudioPlayer.play_battle_music()
	
	waves_cleared = 0
	global.battle_won = false
	enemy_move_timer.timeout.connect(start_enemy_action)
	animation_timer.timeout.connect(end_enemy_action)
	move_timer_bar.max_value = int(enemy_move_timer.wait_time)
	
	for x in grid_length:
		for y in grid_height:
			dictionary[str(Vector2(x, y))] = {
				"Type" : "Battle Area"
			}
	if global.slums_boss_battle:
		spawn_boss()
	else:
		await get_tree().create_timer(3).timeout
		start_wave()
	prints("battle started:")
	
	
	
func _process(delta):
	if anim_start == false:
		start_anim()
		anim_start = true
		
	move_timer_bar.value = enemy_move_timer.time_left
	
	for x in grid_length:
		for y in grid_height:
			slums_tile_map.erase_cell(1, Vector2(x, y))
			
	var hovered_tile = slums_tile_map.local_to_map(slums_tile_map.get_global_mouse_position())
	
	for x in grid_length:
		for y in grid_height:
			slums_tile_map.erase_cell(1, Vector2(x, y))
	
	if dictionary.has(str(hovered_tile)) and global.is_dragging: 
		match global.dragged_char_name:
			"kai": kai.preview_attack_AoE(hovered_tile, kai_offset_list)
			"emerald": emerald.preview_attack_AoE(hovered_tile, emerald_offset_list)
			"tyrone": tyrone.preview_attack_AoE(hovered_tile, tyrone_offset_list)
			"bettany": bettany.preview_attack_AoE(hovered_tile, bettany_offset_list)


				
func show_start_screen():
	var hide_start_screen = func():
		battle_start_popup.hide()
		get_tree().paused = false
	battle_start_popup.show()
	get_tree().paused = true
	get_tree().create_timer(2).timeout.connect(hide_start_screen)
	set_up_character_health()

func ui_start_animation():
	var ac_old_pos = abilities_container.position
	var mtb_old_pos = move_timer_bar.position
	var kai_da_old_pos = kai_drag_icon.position
	var emerald_da_old_pos = emerald_drag_icon.position
	var tyrone_da_old_pos = tyrone_drag_icon.position
	var bettany_da_old_pos = bettany_drag_icon.position
	
	abilities_container.position.y = abilities_container.position.y + 100
	move_timer_bar.position.x = move_timer_bar.position.x + 100
	kai_drag_icon.position.x = kai_drag_icon.position.x - 500
	emerald_drag_icon.position.x = emerald_drag_icon.position.x - 500
	tyrone_drag_icon.position.x = tyrone_drag_icon.position.x - 500
	bettany_drag_icon.position.x = bettany_drag_icon.position.x - 500
	
	var tween = create_tween().set_parallel()
	tween.tween_property(abilities_container, "position", ac_old_pos, 2).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(move_timer_bar, "position", mtb_old_pos, 2).set_trans(Tween.TRANS_EXPO)
	
	tween.tween_property(kai_drag_icon, "position", kai_da_old_pos, 2).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(emerald_drag_icon, "position", emerald_da_old_pos, 2).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(tyrone_drag_icon, "position", tyrone_da_old_pos, 2).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(bettany_drag_icon, "position", bettany_da_old_pos, 2).set_trans(Tween.TRANS_EXPO)

func set_up_character_health():
	
	if global.kai_curr_hp <= 0:
		kai.character_defeated()
		kai.anim_sprite.visible = false
	else:
		kai.health_bar.max_value = global.kai_max_hp
		kai.health_bar.value = global.kai_curr_hp
		
	if global.emerald_curr_hp <= 0:
		emerald.character_defeated()
		emerald.anim_sprite.visible = false
	else:
		emerald.health_bar.max_value = global.emerald_max_hp
		emerald.health_bar.value = global.emerald_curr_hp
		
	if global.tyrone_curr_hp <= 0:
		tyrone.character_defeated()
		tyrone.anim_sprite.visible = false
	else:
		tyrone.health_bar.max_value = global.tyrone_max_hp
		tyrone.health_bar.value = global.tyrone_curr_hp
	
	if global.bettany_curr_hp <= 0:
		bettany.character_defeated()
		bettany.anim_sprite.visible = false
	else:
		bettany.health_bar.max_value = global.bettany_max_hp
		bettany.health_bar.value = global.bettany_curr_hp
	
	print(kai.health_bar.value)
	print(emerald.health_bar.value)
	print(tyrone.health_bar.value)
	print(bettany.health_bar.value)
	
func update_team_health():
	team_health = 0
	for character in get_node("DraggableIcons").get_children():
		team_health += character.health_bar.value
		
	if team_health <= 0:
		global.battle_won = false
		battle_victory(false)
		
func start_enemy_action(): 
	record_enemies()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.action()
		
	animation_timer.start()

func end_enemy_action():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.stop_animation()
	record_enemies()
	enemy_move_timer.start()

func record_enemies():
	global.enemy_dict.clear()
	for enemy in enemy_list:
		add_enemy(enemy)


func add_enemy(enemy : CharacterBody2D):
	var enemy_map_pos = slums_tile_map.local_to_map(enemy.position)
	global.enemy_dict[enemy_map_pos] = enemy
	
func start_wave():
	if not global.slums_boss_battle:
		if waves_cleared == num_of_waves:
			battle_victory(true)
			return
		
	prints("new wave")
	count = 0
	enemy_move_timer.start(enemy_move_timer.wait_time)
	used_vectors.clear()
	global.enemy_dict.clear()
	var num_of_groups = randi_range(min_num_of_groups, max_num_of_groups)
	while count < num_of_groups:
		place_formation()
		
		
	enemy_move_timer.start()

		
func place_formation():
	var x_valid : bool
	var y_valid : bool
	var spawn_position
	var spawn_positions : Array[Vector2i]
	var base_position = generate_random_vector()
	rng = RandomNumberGenerator.new()
	rng.randomize()
	var random_pattern = rng.randi_range(0, 4)	
	
	match random_pattern:
		0 : current_offset_list = kai_offset_list
		1 : current_offset_list = emerald_offset_list
		2 : current_offset_list = tyrone_offset_list
		3 : current_offset_list = bettany_offset_list
		#4 : current_offset_list = sqaure_offset_list
		#5 : current_offset_list = h_rect_offset_list
		#6 : current_offset_list = v_rect_offset_list
	
	for offset in current_offset_list:
		spawn_position = base_position + offset as Vector2i
		
		if current_offset_list == bettany_offset_list or current_offset_list == v_rect_offset_list:
			x_valid = spawn_position.x in range(top_left_tile.x + 11, bottom_right_tile.x) 
		elif not (current_offset_list == bettany_offset_list or current_offset_list == v_rect_offset_list):
			x_valid = spawn_position.x in range(top_left_tile.x + 3, bottom_right_tile.x - 8) 
			
		y_valid = spawn_position.y in range(top_left_tile.y, bottom_right_tile.y+1) 
			
		if not spawn_position in global.enemy_dict and x_valid and y_valid:
			spawn_positions.append(spawn_position)
		else:
			spawn_positions.clear()
			#prints("spawn_position in global.enemy_dict", spawn_position in global.enemy_dict)
			#prints("x valid", x_valid)
			#prints("y valid", y_valid)
			#prints("invalid position")
			return
		
	for position in spawn_positions:
		spawn_enemy(position)
		
	record_enemies()	

	count += 1
	spawn_positions.clear()
			
func spawn_enemy(spawn_position : Vector2i):	
	var enemy_local_pos = slums_tile_map.map_to_local(spawn_position)
	
	if current_offset_list == bettany_offset_list or current_offset_list == v_rect_offset_list:
		enemy_instance = ranged_enemy_scene.instantiate() as CharacterBody2D
	else:
		enemy_instance = melee_enemy_scene.instantiate() as CharacterBody2D
		
	enemy_list.append(enemy_instance)
	enemy_instance.position = enemy_local_pos
	enemy_instance.z_index = enemy_local_pos.y
	slums_tile_map.add_child.call_deferred(enemy_instance) 
	enemy_instance.enemy_died.connect(enemy_defeated.bind(enemy_instance))
	used_vectors.append(spawn_position)
	add_enemy(enemy_instance)
	record_enemies()

	
func enemy_defeated(enemy_ref : CharacterBody2D):
	enemy_list.erase(enemy_ref)
	global.enemy_dict.erase(slums_tile_map.local_to_map(enemy_ref.position))
	record_enemies()
	
	if enemy_list.size() == 0: 
		enemy_move_timer.stop()
		waves_cleared += 1
		prints("wave cleared:", waves_cleared)
		if not global.slums_boss_battle:
			start_wave.call_deferred()
		if global.boss_spawning:
			wave_finished.emit()
		if not global.boss_spawning:
			start_wave.call_deferred()

func battle_victory(victory : bool):
	var tween = create_tween()
	tween.tween_property(AudioPlayer, "volume_db", -100.0, 3)
	await tween.finished
	if victory:
		record_char_health()
		global.battle_won = true
		prints("battle ended")
		
		#tween.tween_property(AudioPlayer, "volume_db", -100.0, 3)
		#await tween.finished
		var trans_screen = trans_scene.instantiate()
		add_child(trans_screen)
		trans_screen.play_animation()
		await get_tree().create_timer(1).timeout
		trans_screen.queue_free()

		if global.current_scene != "":
			get_tree().change_scene_to_packed.call_deferred(load(global.current_scene))
	else:
		global.battle_won = false
		#tween.tween_property(AudioPlayer, "volume_db", -100.0, 3)
		#await tween.finished
		TransitionScreen.transition_node.play("fade_out")
		TransitionScreen.fade_out_finished.connect(get_tree().change_scene_to_file.bind("res://scenes/death_screen.tscn"))
		#get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
	

func generate_random_vector() -> Vector2i :
	rng = RandomNumberGenerator.new()
	rng.seed
	while true:
		rng.randomize()
		var random_x = rng.randi_range(top_left_tile.x, bottom_right_tile.x + 1) 
		var random_y = rng.randi_range(top_left_tile.y, bottom_right_tile.y + 1) 
		var random_vector = Vector2i(random_x, random_y)
		
		if not used_vectors.has(random_vector):
			used_vectors.append(random_vector)
			return random_vector
	return Vector2i(0, 0)
		
func start_anim():
	var trans_screen = trans_scene.instantiate()
	add_child(trans_screen)
	trans_screen.play_animation_backwards()
	await get_tree().create_timer(1).timeout
	trans_screen.queue_free()
	global.transition_commence = false
	
func record_char_health():
	global.kai_curr_hp = kai.health_bar.value
	global.emerald_curr_hp = emerald.health_bar.value
	global.tyrone_curr_hp = tyrone.health_bar.value
	global.bettany_curr_hp = bettany.health_bar.value
	print("health recorded")

func spawn_boss():
	var boss_instance = slums_boss_scene.instantiate() as CharacterBody2D
	boss_instance.position = slums_tile_map.map_to_local(Vector2i(21, 7))
	slums_tile_map.add_child.call_deferred(boss_instance)
	boss_instance.boss_killed.connect(_on_boss_killed)

func _on_boss_killed():
	var dead_boss_instance = boss_death_scene.instantiate() as AnimatedSprite2D
	add_child(dead_boss_instance)
	dead_boss_instance.position = Vector2(250, 112)
	slums_tile_map.modulate = Color.BLACK
	boss_defeated_anim.play("boss_defeated_anim")
	
	await get_tree().create_timer(0.5).timeout
	dead_boss_instance.play("death")
	var tween = create_tween()
	await dead_boss_instance.animation_finished
	tween.tween_property(dead_boss_instance, "modulate", Color(0, 0, 0, 0), 3)
	await get_tree().create_timer(3).timeout
	dead_boss_instance.queue_free()
	
	battle_victory(true)

func within_bounds(coordinate : Vector2) -> bool:
	var x_valid = coordinate.x >= min_hover_x and coordinate.x <= max_hover_x + 1
	var y_valid = coordinate.y >= min_hover_y and coordinate.y <= max_hover_y
	
	if x_valid and y_valid:
		return true
	else:
		return false
