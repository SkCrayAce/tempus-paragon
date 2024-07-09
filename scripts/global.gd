extends Node

const snap_position : Vector2 = Vector2(16, 16)
const EnemyBody = preload("res://scripts/enemy.gd") 

var is_dragging = false
var is_released = false
var dragged_char_name : String
var enemy_position : Vector2
@onready var tile_map = $TileMap

var enemy_dict : Dictionary 

#Overworld Data
var levels_cleared = 0
var curr_area = "slums"

#Scene and node references
var player_node: Node = null

#Inventory Data and Stuff
var inventory = []
signal inventory_updated


#Inventory Functions------------

func _ready():
	inventory.resize(15)

func add_item(item):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["type"] == inventory[i]["type"] and inventory[i]["effect"] == inventory[i]["effect"]:
			#inventory[i]["0quantity"] += item["quantity"]
			#inventory_updated.emit()
			#retrun true
			print("item added", inventory)
			pass
		elif inventory[i] == null:
			inventory[i] = item
			inventory_updated.emit()
			print("item added", inventory)
			return true
		return false

func remove_item():
	inventory_updated.emit()

func increase_inventory_size():
	inventory_updated.emit()

func set_player_reference(player):
	player_node = player
#---------------------------------

func add_level_cleared():
	levels_cleared +=1

func delete_enemy(map_position_key : Vector2i):
	enemy_dict.erase(map_position_key)

func add_enemy(map_position_key : Vector2i, enemy_ref : CharacterBody2D):
	var enemy_reference = enemy_ref as EnemyBody
	enemy_dict[map_position_key] = enemy_reference
	
func get_enemy(map_position_key : Vector2i) -> EnemyBody:
	return enemy_dict.get(map_position_key)
