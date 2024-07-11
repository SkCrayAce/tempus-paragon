extends Node

const snap_position : Vector2 = Vector2(16, 16)
const EnemyBody = preload("res://scripts/enemy.gd") 

# battle scene vars
var is_dragging = false
var is_released = false
var dragged_char_name : String
var enemy_position : Vector2
var enemy_dict : Dictionary 

# overworld scene vars
var enemy_dict : Dictionary 

#Overworld Data
var levels_cleared = 0
var curr_area = "slums"
var current_scene : PackedScene
var player_position : Vector2



func add_level_cleared():
	levels_cleared +=1

func delete_enemy(map_position_key : Vector2i):
	enemy_dict.erase(map_position_key)

func add_enemy(map_position_key : Vector2i, enemy_ref : CharacterBody2D):
	var enemy_reference = enemy_ref as EnemyBody
	enemy_dict[map_position_key] = enemy_reference
	
func get_enemy(map_position_key : Vector2i) -> EnemyBody:
	return enemy_dict.get(map_position_key)
