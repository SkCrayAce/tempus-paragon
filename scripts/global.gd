extends Node

const snap_position : Vector2 = Vector2(16, 16)
const EnemyBody = preload("res://scripts/enemy.gd") 

var is_dragging = false
var is_released = false
var dragged_char_name : String
var enemy_position : Vector2
@onready var tile_map = $TileMap

var levels_cleared = 0
var curr_area = "slums"

var enemy_dict : Dictionary 
	
func delete_enemy(map_position_key : Vector2i):
	enemy_dict.erase(map_position_key)

func add_level_cleared():
	levels_cleared +=1

func delete_position(target_position: Vector2):
	enemy_dict.erase(target_position.snapped(snap_position))
	
func delete_enemy(enemy_ref : Node2D):
	var delete_position = enemy_ref.position.snapped(snap_position)
	enemy_dict.erase(delete_position)

func add_enemy(enemy_ref : Node2D):
	var add_position = enemy_ref.position.snapped(snap_position)
	enemy_dict[add_position] = enemy_ref
