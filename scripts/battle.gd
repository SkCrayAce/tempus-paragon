extends Node

@export var grid_length : int
@export var grid_height : int
@export var attack_damage : int
@export var enemy_scene : PackedScene

var enemy_instance : CharacterBody2D
var dictionary = {}

const enemy_script = preload("res://scripts/enemy.gd")

@onready var enemy_move_timer = $EnemyMoveTimer
@onready var move_timer_bar = $MoveTimerBar
@onready var tilemap = $TileMap


var kai_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
var emerald_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0)]
var tyrone_offset_list = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
var bettany_offset_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, -1)]

var custom_data_name: String = "can_place_attack"
var ground_layer = 0
var hover_layer = 1
var enemy_list : Array[CharacterBody2D]

var character_ids = {}

func _ready():    
	move_timer_bar.max_value = enemy_move_timer.wait_time
	#prints(global.enemy_position)    
	for x in grid_length:
		for y in grid_height:
			dictionary[str(Vector2(x, y))] = {
				"Type" : "Grass"
			}
	wave_spawner()
	

		

func _process(delta):
	var hovered_tile = tilemap.local_to_map(tilemap.get_global_mouse_position())
	
	move_timer_bar.value = enemy_move_timer.time_left

	for x in grid_length:
		for y in grid_height:
			tilemap.erase_cell(1, Vector2(x, y))
	
	
	if dictionary.has(str(hovered_tile)) and global.is_dragging: 
		match global.dragged_char_name:
			"kai": attack_AoE(hovered_tile, kai_offset_list)
			"emerald": attack_AoE(hovered_tile, emerald_offset_list)
			"tyrone": attack_AoE(hovered_tile, tyrone_offset_list)
			"bettany": attack_AoE(hovered_tile, bettany_offset_list)


func attack_AoE(hovered_tile, offset_list):
	for offset in offset_list:
		var target_pos : Vector2i = hovered_tile + offset as Vector2i
		var x_valid = target_pos.x > 0 and target_pos.x <= 16 
		var y_valid = target_pos.y > 0 and target_pos.y <= 8
		var world_pos : Vector2 = tilemap.map_to_local(target_pos)
		var detected_enemy = global.enemy_dict.get(world_pos.snapped(Vector2(16, 16)))
		
		if x_valid and y_valid:
			tilemap.set_cell(hover_layer, target_pos, 1, Vector2i(0, 0), 0)
			
		if offset_list == kai_offset_list and Input.is_action_just_released("left_click"):
			prints("kai offset", offset)

		if is_instance_valid(detected_enemy) and detected_enemy is enemy_script and Input.is_action_just_released("left_click"):
			detected_enemy.hit(attack_damage)
		
func _on_enemy_move_timer_timeout():
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.action()
		
func enemy_defeated(enemy_ref : CharacterBody2D):
	enemy_list.erase(enemy_ref)
	
	if enemy_list.size() == 0: 
		wave_spawner()
		
func wave_spawner():
	prints("next wave")
	for y in range (1, 9):
		enemy_instance = enemy_scene.instantiate() as CharacterBody2D
		enemy_list.append(enemy_instance)
		enemy_instance.position = tilemap.map_to_local(Vector2i(10, y))
		tilemap.add_child.call_deferred(enemy_instance)
		enemy_instance.tree_exiting.connect(enemy_defeated.bind(enemy_instance))
