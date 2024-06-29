extends Node

@export var grid_length = 18
@export var grid_height = 10
@export var enemy_speed = 60
var dictionary = {}

const enemy_script = preload("res://scripts/enemy.gd")

var enemy
@onready var enemy_move_timer = $TileMap/Enemy/NextMoveTimer
@onready var move_timer_bar = $MoveTimerBar
@onready var tilemap = $TileMap

var kai_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
var emerald_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0)]
var tyrone_offset_list = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
var bettany_offset_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, -1)]

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
	var enemy_tile = tilemap.local_to_map(global.enemy_position)
	
	if is_instance_valid(enemy_move_timer):
		move_timer_bar.value = enemy_move_timer.time_left

	for x in grid_length:
		for y in grid_height:
			tilemap.erase_cell(1, Vector2(x, y))
	
	
	if dictionary.has(str(hovered_tile)) and global.is_dragging: 
		match global.dragged_char_name:
			"kai": attack_AoE(hovered_tile, kai_offset_list)
			"emerald": attack_AoE(hovered_tile, emerald_offset_list)
			"tyrone": attack_AoE(hovered_tile, tyrone_offset_list)
			"bettany": attack_AoE(hovered_tile, tyrone_offset_list)

func attack_AoE(hovered_tile, offset_list):
	for offset in offset_list:
		var target_pos : Vector2 = hovered_tile + offset
		var world_pos : Vector2 = tilemap.map_to_local(target_pos)
		tilemap.set_cell(1, target_pos, 1, Vector2i(0, 0), 0)
		enemy = global.enemy_dict.get(world_pos.snapped(Vector2(16, 16)))
				# prints(Input.is_action_just_released("left_click"))
		if Input.is_action_just_released("left_click"):
			prints(enemy)
		if enemy is enemy_script and Input.is_action_just_released("left_click"):
			prints("success")
			enemy.hit(500)


	
	
	
		

