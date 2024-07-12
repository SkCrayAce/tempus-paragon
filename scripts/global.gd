extends Node

const snap_position : Vector2 = Vector2(16, 16)
const EnemyBody = preload("res://scripts/enemy.gd") 


# battle scene vars
var is_dragging = false
var is_released = false
var dragged_char_name : String
var enemy_position : Vector2
var enemy_dict : Dictionary 

#Overworld Data
var levels_cleared = 0
var curr_area = "slums"
var current_scene : String
var player_position : Vector2 
var enemy_pos_at_contact : Vector2
var battle_won : bool

#Scene and node references
var player_node: Node = null
@onready var inventory_slot_scene = preload("res://scenes/inventory_slot.tscn")

#Inventory Data and Stuff
var inventory = []
signal inventory_updated


#Inventory Functions------------

func _ready():
	inventory.resize(12)

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


func remove_item(item_type, item_effect):
	for i in range(inventory.size()):
		if inventory[i] != null and inventory[i]["type"] == item_type and inventory[i]["effect"] == item_effect:
			inventory[i]["quantity"] -= 1
			if inventory[i]["quantity"] <= 0:
				inventory[i] = null
			inventory_updated.emit()
			return true
	return false

func increase_inventory_size():
	inventory_updated.emit()

func set_player_reference(player):
	player_node = player
	
func adjust_drop_position(position):
	var radius = 30
	var nearby_items = get_tree().get_nodes_in_group("Items")
	for item in nearby_items:
		if item.global_position.distance_to(position) < radius:
			var random_offset = Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
			position += random_offset
			break
	return position

func drop_item(item_data, drop_position):
	var item_scene = load(item_data["scene_path"])
	var item_instance = item_scene.instantiate()
	item_instance.set_item_data(item_data)
	drop_position = adjust_drop_position(drop_position)
	item_instance.global_position = drop_position
	get_tree().current_scene.add_child(item_instance)

func swap_inventory_items(index1, index2):
	if index1 < 0 or index1 > inventory.size() or index2 < 0 or index2 > inventory.size():
		return false
	
	var temp = inventory[index1]
	inventory[index1] = inventory[index2]
	inventory[index2] = temp
	print("swap happened")
	inventory_updated.emit()
	return true
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
