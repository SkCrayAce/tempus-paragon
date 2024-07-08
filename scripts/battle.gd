extends Node


@export var grid_length : int
@export var grid_height : int
@export var enemy_scene : PackedScene
@export var x_spawn_range : Array[int]
@export var y_spawn_range : Array[int]


var enemy_instance : CharacterBody2D
var dictionary = {}
var rng

const enemy_script = preload("res://scripts/enemy.gd")

@onready var enemy_move_timer = $EnemyMoveTimer
@onready var move_timer_bar = $MoveTimerBar
@onready var tilemap = $TileMap as TileMap


var kai_offset_list = [Vector2i(1, 0), Vector2i(0, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
var emerald_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0)]
var tyrone_offset_list = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
var bettany_offset_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, -1)]


@onready var kai = $VBoxContainer/kai
@onready var emerald = $VBoxContainer/emerald
@onready var tyrone = $VBoxContainer/tyrone
@onready var bettany = $VBoxContainer/bettany


var custom_data_name: String = "can_place_attack"
var enemy_list : Array[CharacterBody2D]
var used_vectors : Array[Vector2i]

var character_ids = {}

func _ready():    
	move_timer_bar.max_value = enemy_move_timer.wait_time
	#prints(global.enemy_position)    
	for x in grid_length:
		for y in grid_height:
			dictionary[str(Vector2(x, y))] = {
				"Type" : "Grass"
			}
	wave_spawner.call_deferred()
	

func _process(delta):
	var hovered_tile = tilemap.local_to_map(tilemap.get_global_mouse_position())
	
	move_timer_bar.value = enemy_move_timer.time_left

	for x in grid_length:
		for y in grid_height:
			tilemap.erase_cell(1, Vector2(x, y))
	
	
	if dictionary.has(str(hovered_tile)) and global.is_dragging: 
		match global.dragged_char_name:
			"kai": kai.attack_AoE(hovered_tile, kai_offset_list)
			"emerald": emerald.attack_AoE(hovered_tile, emerald_offset_list)
			"tyrone": tyrone.attack_AoE(hovered_tile, tyrone_offset_list)
			"bettany": bettany.attack_AoE(hovered_tile, bettany_offset_list)

		
func _on_enemy_move_timer_timeout(): 
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.action()
		#record_enemies()

func record_enemies():
	global.enemy_dict.clear()
	for enemy in enemy_list:
		var enemy_map_pos = tilemap.local_to_map(enemy.position)
		global.enemy_dict[enemy_map_pos] = enemy
		
func enemy_defeated(enemy_ref : CharacterBody2D):
	enemy_list.erase(enemy_ref)
	global.enemy_dict.erase(tilemap.local_to_map(enemy_ref.position))
	
	if enemy_list.size() == 0: 
		wave_spawner()
		
func wave_spawner():
	prints("next wave")
	used_vectors.clear()
	enemy_move_timer.start(enemy_move_timer.wait_time)
	
	for pattern in range(4):
		var base_position = generate_random_vector()
		rng = RandomNumberGenerator.new()
		rng.randomize()
		var random_pattern = rng.randi_range(0, 4)
		var offset_list : Array
		
		prints("random pattern:", random_pattern)
		match random_pattern:
			0 : offset_list = kai_offset_list
			1 : offset_list = emerald_offset_list
			2 : offset_list = tyrone_offset_list
			3 : offset_list = bettany_offset_list
		
		var formation_positions : Array
		var target_pos : Vector2i
		for offset in offset_list:
			target_pos = base_position + offset as Vector2i
			#formation_positions.append(target_pos)
			
			#if intersect_exists(formation_positions, used_vectors):
				#formation_positions.clear()
				#continue
				
			var x_valid = target_pos.x in x_spawn_range 
			#prints("x valid:", x_valid, x_spawn_range)
			var y_valid = target_pos.y in y_spawn_range
			#prints("y valid:", y_valid, y_spawn_range)
					
			if x_valid and y_valid and not target_pos in used_vectors :
				enemy_instance = enemy_scene.instantiate() as CharacterBody2D
				enemy_list.append(enemy_instance)
				enemy_instance.position = tilemap.map_to_local(target_pos)
				tilemap.add_child.call_deferred(enemy_instance)
				enemy_instance.tree_exiting.connect(enemy_defeated.bind(enemy_instance))
				used_vectors.append(target_pos)
				prints("enemy spawned")
	#record_enemies()
	#prints("used vectors:", global.enemy_dict)

func generate_random_vector() -> Vector2i :
	rng = RandomNumberGenerator.new()
	while true:
		rng.randomize()
		var random_x = rng.randi_range(x_spawn_range.min(), x_spawn_range.max())
		var random_y = rng.randi_range(y_spawn_range.min(), y_spawn_range.max())
		var random_vector = Vector2i(random_x, random_y)
		
		if not used_vectors.has(random_vector):
			used_vectors.append(random_vector)
			return random_vector			
	return Vector2i(0, 0)

func intersect_exists(first_arr : Array, second_arr : Array) -> bool :
	for value in first_arr:
		if value in second_arr:
			return true
	return false
