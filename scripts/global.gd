extends Node

const snap_position : Vector2 = Vector2(16, 16)
const enemy_body = preload("res://scripts/enemy.gd") 

var is_dragging = false
var is_released = false
var dragged_char_name : String
var enemy_position : Vector2
@onready var tile_map = $TileMap

var enemy_dict : Dictionary 
	
func delete_enemy(map_position_key : Vector2i):
	enemy_dict.erase(map_position_key)

func add_enemy(map_position_key : Vector2i, enemy_ref : CharacterBody2D):
	var enemy_reference = enemy_ref as enemy_body
	enemy_dict[map_position_key] = enemy_reference
