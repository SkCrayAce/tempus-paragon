@tool
extends Node2D

@export var item_type = ""
@export var item_name = ""
@export var item_texture: Texture
@export var item_effect = ""

#Scene tree Node references
@onready var icon_sprite = $Sprite2D

var scene_path: String = "res://scenes/inventory_item.tscn"
var player_in_range = false

func _ready():
	#Set texture to reflect in the game
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture


func _process(delta):
	#Set texture to reflect in the editor
	if Engine.is_editor_hint():
		icon_sprite.texture = item_texture
	
	if player_in_range and Input.is_action_just_pressed("ui_add"):
		pickup_item()

func pickup_item():
	var item = {
		"type": item_type,
		"name": item_name,
		"effect": item_effect,
		"texture": item_texture,
		"scene_path": scene_path
	}
	
	if global.player_node:
		global.add_item(item)
		self.queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		body.interact_ui.visible = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		body.interact_ui.visible = false
