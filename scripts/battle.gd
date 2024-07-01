extends Node

@export var grid_length : int
@export var grid_height : int
@export var attack_damage : int
var dictionary = {}

const enemy_script = preload("res://scripts/enemy.gd")

@onready var enemy_move_timer = $TileMap/Enemy/NextMoveTimer
@onready var move_timer_bar = $MoveTimerBar
@onready var tilemap = $TileMap
@onready var kai_healthbar = $VBoxContainer/kai/Control/HealthBar
@onready var enemy = $TileMap/Enemy


var kai_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
var emerald_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0)]
var tyrone_offset_list = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
var bettany_offset_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, -1)]

var custom_data_name: String = "can_place_attack"
var ground_layer = 0
var hover_layer = 1

func _ready():    
	move_timer_bar.max_value = enemy_move_timer.wait_time
	prints(global.enemy_position)    
	for x in grid_length:
		for y in grid_height:
			dictionary[str(Vector2(x, y))] = {
				"Type" : "Grass"
			}

func _process(delta):
	var hovered_tile = tilemap.local_to_map(tilemap.get_global_mouse_position())
	var enemy_tile : Vector2i = tilemap.local_to_map(enemy.position)
	# var tile_data = tilemap.get_cell_tile_data(0, )
	
	if is_instance_valid(enemy_move_timer):
		move_timer_bar.value = enemy_move_timer.time_left

	for x in grid_length:
		for y in grid_height:
			tilemap.erase_cell(1, Vector2(x, y))
	
	tilemap.set_cell(hover_layer, enemy_tile, 0, Vector2i(0, 0), 0)
	prints("map_coordinates:", enemy_tile)
	
	if dictionary.has(str(hovered_tile)) and global.is_dragging: 
		match global.dragged_char_name:
			"kai": attack_AoE(hovered_tile, kai_offset_list)
			"emerald": attack_AoE(hovered_tile, emerald_offset_list)
			"tyrone": attack_AoE(hovered_tile, tyrone_offset_list)
			"bettany": attack_AoE(hovered_tile, bettany_offset_list)


func attack_AoE(hovered_tile, offset_list):
	for offset in offset_list:
		var target_pos : Vector2i = hovered_tile + offset
		var world_pos : Vector2 = tilemap.map_to_local(target_pos)
		var detected_enemy = global.enemy_dict.get(world_pos.snapped(Vector2(16, 16)))
		
		tilemap.set_cell(hover_layer, target_pos, 1, Vector2i(0, 0), 0)
				
		if Input.is_action_just_released("left_click"):
			prints(detected_enemy)
		if is_instance_valid(detected_enemy) and detected_enemy is enemy_script and Input.is_action_just_released("left_click"):
			prints("success")
			detected_enemy.hit(attack_damage)
		

