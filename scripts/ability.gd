@tool
extends Node

@export var ability_name = ""
@export var ability_description = ""
@export var ability_texture : Texture
@export var ability_by = ""

#Scene tree Node references
@onready var icon_sprite = $Sprite2D

var scene_path = "res://scenes/ability.tscn"


# Called when the node enters the scene tree for the first time.
func _ready():
	#Set texture to reflect in the game
	if not Engine.is_editor_hint():
		icon_sprite.texture = ability_texture
	
func _process(delta):
	#Set texture to reflect in the editor
	if Engine.is_editor_hint():
		icon_sprite.texture = ability_texture

func set_ability_data(ability):
	ability_name = ability["name"]
	ability_description = ability["description"]
	ability_texture = ability["texture"]
