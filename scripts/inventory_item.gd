@tool
extends Node2D

@export var item_type = ""
@export var item_name = ""
@export var item_texture: Texture
@export var item_effect = ""
@export var item_rarity = ""
@export var item_quantity = 0

#Scene tree Node references
@onready var icon_sprite = $Sprite2D
@onready var shadow = $Shadow


var scene_path: String = "res://scenes/inventory_item.tscn"
#var shadow_texture: Texture = load("res://tempus_assets/item sprites/item_shadow.png")
var player_in_range = false
var breakloop = false

func _ready():
	#Set texture to reflect in the game
	if not Engine.is_editor_hint():
		icon_sprite.texture = item_texture
	#shadow.texture = shadow_texture
	tween_item(icon_sprite)



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
		"scene_path": scene_path,
		"rarity": item_rarity,
		"quantity": item_quantity
	}
	
	if global.player_node:
		global.add_item(item)
		breakloop = true
		self.queue_free()


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true
		body.interact_ui.visible = true


func _on_area_2d_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false
		body.interact_ui.visible = false
		

func set_item_data(data):
	item_type = data["type"]
	item_name = data["name"]
	item_effect = data["effect"]
	item_texture = data["texture"]
	item_rarity = data["rarity"]
	item_quantity = data["quantity"]

func tween_item(sprite):
	while breakloop == false:
		var tween = create_tween()
		tween.tween_property(sprite, "position", Vector2(sprite.position.x,sprite.position.y-2), 1).set_trans(Tween.TRANS_SINE)
		await tween.finished
		tween = create_tween()
		tween.tween_property(sprite, "position", Vector2(sprite.position.x,sprite.position.y+2), 1).set_trans(Tween.TRANS_SINE)
		await tween.finished
		if breakloop == true:
			break
			
	
