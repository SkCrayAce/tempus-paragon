extends Node2D

var draggable : bool = false
var on_cooldown : bool = false
var is_defeated : bool = false
var ground_layer = 0
var hover_layer = 1
var mouse_map_position : Vector2
var tween : Tween
var tilemap_dict : Dictionary
var hovered_tile : Vector2i
var offset_list : Array

const grid_length = 120
const grid_height = 68

@export var attack_damage : int
@export var min_hover_x : int
@export var max_hover_x : int
@export var min_hover_y : int
@export var max_hover_y : int

const BattleScript = preload("res://scripts/battle.gd")
const EnemyScript = preload("res://scripts/enemy.gd")

@onready var cooldown_bar = $Control/CooldownBar 
@onready var cooldown_timer = $CooldownTimer
@onready var sprite = $SpriteContainer
@onready var health_bar = $Control/HealthBar
@onready var defeat_filter = $Control/DefeatFilter
@onready var battle_node = get_node("../..") as BattleScript
@onready var slums_tile_map = $"../../SlumsTileMap"
@onready var enemy_move_timer = $"../../EnemyMoveTimer"
@onready var animation_timer = $"../../AnimationTimer"

# Character Sprite Node
@onready var kai_sprite = $"../../Characters/kai" as Node2D
@onready var emerald_sprite = $"../../Characters/emerald" as Node2D
@onready var tyrone_sprite = $"../../Characters/tyrone" as Node2D
@onready var bettany_sprite = $"../../Characters/bettany" as Node2D
var char_sprite : Node2D

# Animated Sprites
@onready var kai_anim_sprite = $"../../Characters/kai/AnimatedSprite2D" as AnimatedSprite2D
@onready var emerald_anim_sprite = $"../../Characters/emerald/AnimatedSprite2D" as AnimatedSprite2D
@onready var tyrone_anim_sprite = $"../../Characters/tyrone/AnimatedSprite2D" as AnimatedSprite2D
@onready var bettany_anim_sprite = $"../../Characters/bettany/AnimatedSprite2D" as AnimatedSprite2D
var anim_sprite : AnimatedSprite2D

# offsets
var kai_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
var emerald_offset_list = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0)]
var tyrone_offset_list = [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)]
var bettany_offset_list = [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, -1)]

var initial_pos
var tile_map : TileMap

signal character_damaged
signal character_killed


func _ready():
	tile_map = slums_tile_map
	on_cooldown = false
	health_bar.value = health_bar.max_value
	
	for x in grid_length:
		for y in grid_height:
			tilemap_dict[str(Vector2(x, y))] = {
				"Type" : "Battle Area"
			}
			
	match name:
		"kai":
			char_sprite = kai_sprite
			anim_sprite = kai_anim_sprite
		"emerald":
			char_sprite = emerald_sprite
			anim_sprite = emerald_anim_sprite
		"tyrone":
			char_sprite = tyrone_sprite
			anim_sprite = tyrone_anim_sprite
		"bettany":
			char_sprite = bettany_sprite
			anim_sprite = bettany_anim_sprite
			
	initial_pos = char_sprite.global_position
	anim_sprite.frame_changed.connect(inflict_damage)

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if draggable and !on_cooldown and !is_defeated:
		if Input.is_action_just_pressed("left_click"):
			global.is_dragging = true
			global.dragged_char_name = name
		if Input.is_action_pressed("left_click"):
			pass
			#global.dragged_char_name = name
		#elif Input.is_action_just_released("left_click") and name == global.dragged_char_name:
			#global.is_dragging = false
			#prints("dragged:", global.dragged_char_name)
			#global.dragged_char_name = ""

	cooldown_bar.value = cooldown_timer.time_left
	
	
func _on_area_2d_mouse_entered():
	var tween := create_tween()
	if !global.is_dragging and !on_cooldown and !is_defeated:
		draggable = true
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_exited():
	var tween := create_tween()
	if !global.is_dragging:
		draggable = false
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)

func preview_attack_AoE(new_hovered_tile, new_offset_list):
	hovered_tile = new_hovered_tile
	offset_list = new_offset_list
	
	var hover_active : bool
	
	var attack_animation = func():
		anim_sprite.play("attack")
		anim_sprite.animation_finished.connect(return_to_position)
	prints(hovered_tile)
	prints("bago mag loop:", offset_list)
	for offset in offset_list:
		var target_pos : Vector2i = hovered_tile + offset as Vector2i
		prints("within bounds:", within_bounds(target_pos))
		if within_bounds(target_pos):
			tile_map.set_cell(hover_layer, target_pos, 2, Vector2i(0, 0), 0)
			hover_active = true
		else:
			hover_active = false
			
	
	if Input.is_action_just_released("left_click"):
		global.is_dragging = false
		prints("dragged:", global.dragged_char_name)
		global.dragged_char_name = ""
		prints("i am called")
		prints("hover active: ", hover_active)
		
		if hover_active:
			tween = create_tween()
			
			enemy_move_timer.set_paused(true)
			animation_timer.set_paused(true)
			anim_sprite.play("walk")
			tween.tween_property(char_sprite, "position", tile_map.map_to_local(hovered_tile), 0.5)
			tween.finished.connect(attack_animation)
			prints("start cd")
			start_cooldown()
	
func inflict_damage():
	if not anim_sprite.animation == "attack" or not anim_sprite.frame == 5:
		return
	
	for offset in offset_list:
		var target_pos : Vector2i = hovered_tile + offset as Vector2i
		var detected_enemy = global.enemy_dict.get(target_pos)
		var valid_enemy = detected_enemy is EnemyScript
		if is_instance_valid(detected_enemy) and valid_enemy:
			detected_enemy.hit(attack_damage)

func return_to_position():
	var back_to_idle = func(): 
		anim_sprite.flip_h = false
		anim_sprite.play("idle")
		enemy_move_timer.set_paused(false)
		animation_timer.set_paused(false)
		
	tween = create_tween()
	anim_sprite.flip_h = true
	anim_sprite.play("walk")
	tween.tween_property(char_sprite, "position", initial_pos, 0.5)
	tween.finished.connect(back_to_idle)
	
func start_cooldown():
	on_cooldown = true
	global.is_dragging = false
	
	if not on_cooldown or is_defeated: return 
	
	cooldown_bar.max_value = cooldown_timer.wait_time
	cooldown_timer.start()
	cooldown_bar.show()
	#cooldown_timer.timeout.connect(end_cooldown)
	scale = Vector2(1, 1)

func _on_cooldown_timer_timeout():
	on_cooldown = false
	cooldown_bar.hide()
	draggable = false
	
#func end_cooldown():
	#on_cooldown = false
	#cooldown_bar.hide()
	#draggable = false

func take_damage(damage : int):
	character_damaged.emit()
	health_bar.value -= damage
	
	if is_defeated: return
	
	if health_bar.value <= 0:
		character_killed.emit()
		character_defeated()

func character_defeated():
	is_defeated = true
	defeat_filter.show()
	global.is_dragging = false
	global.is_released = false
	global.dragged_char_name = ""
	
func within_bounds(coordinate : Vector2) -> bool:
	var x_valid = coordinate.x >= min_hover_x and coordinate.x <= max_hover_x + 1
	var y_valid = coordinate.y >= min_hover_y and coordinate.y <= max_hover_y
	
	if x_valid and y_valid:
		return true
	return false



