extends Node


@export var grid_length : int
@export var grid_height : int
@export var num_of_patterns : int

var enemy_instance : CharacterBody2D
var dictionary = {}
var rng
var count : int
var waves_cleared : int

const melee_enemy_scene := preload("res://scenes/characters/melee_virulent.tscn")
const ranged_enemy_scene := preload("res://scenes/characters/ranged_virulent.tscn")
const top_left_tile = Vector2i(9, 3)
const bottom_right_tile = Vector2i(23, 10)

@onready var enemy_move_timer = $EnemyMoveTimer as Timer
@onready var move_timer_bar = $CanvasLayer/MoveTimerBar as TextureProgressBar
@onready var tilemap = $TileMap2 as TileMap
@onready var animation_timer = $AnimationTimer as Timer



var kai_offset_list = [Vector2i(1, 0), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
var emerald_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0)]
var tyrone_offset_list = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
var bettany_offset_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, -1)]
var current_offset_list : Array


@onready var kai = $VBoxContainer/kai
@onready var emerald = $VBoxContainer/emerald
@onready var tyrone = $VBoxContainer/tyrone
@onready var bettany = $VBoxContainer/bettany

@onready var trans_scene = preload("res://scenes/transitionto_battle.tscn")

var enemy_list : Array[CharacterBody2D]
var used_vectors : Array[Vector2i]
var anim_start = false

func _ready():
	waves_cleared = 0
	global.battle_won = false
	animation_timer.timeout.connect(animation_ended)
	move_timer_bar.max_value = int(enemy_move_timer.wait_time)
   
	for x in grid_length:
		for y in grid_height:
			dictionary[str(Vector2(x, y))] = {
				"Type" : "Battle Area"
			}
	start_wave()
	prints("battle started")
	
	
func _process(delta):
	if anim_start == false:
		start_anim()
		anim_start = true
		
	var hovered_tile = tilemap.local_to_map(tilemap.get_global_mouse_position())
	
	move_timer_bar.value = enemy_move_timer.time_left

	for x in grid_length:
		for y in grid_height:
			tilemap.erase_cell(1, Vector2(x, y))
	
	
	if dictionary.has(str(hovered_tile)) and global.is_dragging: 
		match global.dragged_char_name:
			"kai": kai.preview_attack_AoE(hovered_tile, kai_offset_list)
			"emerald": emerald.preview_attack_AoE(hovered_tile, emerald_offset_list)
			"tyrone": tyrone.preview_attack_AoE(hovered_tile, tyrone_offset_list)
			"bettany": bettany.preview_attack_AoE(hovered_tile, bettany_offset_list)

		
func _on_enemy_move_timer_timeout(): 
	record_enemies()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.action()
		
	animation_timer.start()


func animation_ended():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.stop_animation()
	record_enemies()
	enemy_move_timer.start()

func record_enemies():
	global.enemy_dict.clear()
	for enemy in enemy_list:
		add_enemy(enemy)


func add_enemy(enemy : CharacterBody2D):
	var enemy_map_pos = tilemap.local_to_map(enemy.position)
	global.enemy_dict[enemy_map_pos] = enemy
	
func start_wave():
	if waves_cleared == 1:
		battle_ended()
		
	prints("new wave")
	count = 0
	used_vectors.clear()
	enemy_move_timer.start(enemy_move_timer.wait_time)
	
	while count < num_of_patterns:
		place_formation()
		
func place_formation():
	var base_position = generate_random_vector()
	rng = RandomNumberGenerator.new()
	rng.randomize()
	var random_pattern = rng.randi_range(0, 4)	
	
	match random_pattern:
		0 : current_offset_list = kai_offset_list
		1 : current_offset_list = emerald_offset_list
		2 : current_offset_list = tyrone_offset_list
		3 : current_offset_list = bettany_offset_list
	
	for offset in current_offset_list:
		var spawn_position = base_position + offset as Vector2i
		var x_valid : bool
		var y_valid : bool
		
		if current_offset_list == kai_offset_list or current_offset_list == bettany_offset_list:
			x_valid = spawn_position.x in range(top_left_tile.x + 11, bottom_right_tile.x + 1) 
			y_valid = spawn_position.y in range(top_left_tile.y, bottom_right_tile.y + 1) 
		elif current_offset_list == emerald_offset_list or current_offset_list == tyrone_offset_list:
			x_valid = spawn_position.x in range(top_left_tile.x + 3, bottom_right_tile.x + 1) 
			y_valid = spawn_position.y in range(top_left_tile.y, bottom_right_tile.y + 1) 
		
		if spawn_position in global.enemy_dict:
			prints("intersect exists")
			continue
			
		if x_valid and y_valid:
			wave_spawner(spawn_position)
	
		record_enemies()
	count += 1
		
func wave_spawner(spawn_position : Vector2i):	
	var enemy_local_pos = tilemap.map_to_local(spawn_position)
	
	if current_offset_list == kai_offset_list or current_offset_list == bettany_offset_list:
		enemy_instance = ranged_enemy_scene.instantiate() as CharacterBody2D
	else:
		enemy_instance = melee_enemy_scene.instantiate() as CharacterBody2D
		
	enemy_list.append(enemy_instance)
	enemy_instance.position = enemy_local_pos
	enemy_instance.z_index = enemy_local_pos.y
	tilemap.add_child.call_deferred(enemy_instance) 
	enemy_instance.enemy_died.connect(wave_cleared.bind(enemy_instance))
	used_vectors.append(spawn_position)
	add_enemy(enemy_instance)

	
func wave_cleared(enemy_ref : CharacterBody2D):
	enemy_list.erase(enemy_ref)
	global.enemy_dict.erase(tilemap.local_to_map(enemy_ref.position))
	
	if enemy_list.size() == 0: 
		waves_cleared += 1
		prints("wave cleared:", waves_cleared)
		start_wave()

func battle_ended():
	global.battle_won = true
	prints("battle ended")
	var trans_screen = trans_scene.instantiate()
	add_child(trans_screen)
	trans_screen.play_animation()
	await get_tree().create_timer(1).timeout
	trans_screen.queue_free()
	get_tree().change_scene_to_file(global.current_scene)

func generate_random_vector() -> Vector2i :
	rng = RandomNumberGenerator.new()
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
