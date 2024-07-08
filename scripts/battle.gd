extends Node


@export var grid_length : int
@export var grid_height : int
@export var enemy_scene : PackedScene
@export var x_spawn_range : Array[int]
@export var y_spawn_range : Array[int]


var enemy_instance : CharacterBody2D
var dictionary = {}
var rng
var count : int


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
	start_wave()
	

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
		
		
func wave_cleared(enemy_ref : CharacterBody2D):
	enemy_list.erase(enemy_ref)
	global.enemy_dict.erase(tilemap.local_to_map(enemy_ref.position))
	
	if enemy_list.size() == 0: 
		start_wave()
	
func start_wave():
	prints("new wave")
	count = 0
	used_vectors.clear()
	enemy_move_timer.start(enemy_move_timer.wait_time)
	
	while count <= 4:
		place_formation()
		
func place_formation():
	prints("Place formation")
	var base_position = generate_random_vector()
	var formation_positions : Array
	var spawn_position : Vector2i
	rng = RandomNumberGenerator.new()
	rng.randomize()
	var random_pattern = rng.randi_range(0, 4)
	var offset_list : Array	
	
	match random_pattern:
		0 : offset_list = kai_offset_list
		1 : offset_list = emerald_offset_list
		2 : offset_list = tyrone_offset_list
		3 : offset_list = bettany_offset_list
	
	for offset in offset_list:
		spawn_position = base_position + offset as Vector2i
		formation_positions.append(spawn_position)
		
		var x_valid = spawn_position.x in range(x_spawn_range.min(), x_spawn_range.max() + 1) 
		var y_valid = spawn_position.y in range(y_spawn_range.min(), y_spawn_range.max() + 1) 
		
		if intersect_exists(formation_positions, used_vectors):
			prints("intersect exists")
			return
			
		if x_valid and y_valid:
			wave_spawner(spawn_position)
			count += 1
			return
		else:
			formation_positions.clear()
			return
		
func wave_spawner(spawn_position : Vector2i):	
	enemy_instance = enemy_scene.instantiate() as CharacterBody2D
	enemy_list.append(enemy_instance)
	enemy_instance.position = tilemap.map_to_local(spawn_position)
	tilemap.add_child.call_deferred(enemy_instance)
	enemy_instance.tree_exiting.connect(wave_cleared.bind(enemy_instance))
	used_vectors.append(spawn_position)
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
