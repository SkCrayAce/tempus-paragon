extends Node2D

var draggable : bool = false
var on_cooldown : bool = false
var is_defeated : bool = false
var is_dragging : bool = false
var hover_active : bool = false
var ground_layer = 0
var hover_layer = 1
var mouse_map_position : Vector2

@export var attack_damage : int
@export var min_hover_x : int
@export var max_hover_x : int
@export var min_hover_y : int
@export var max_hover_y : int

const EnemyScript = preload("res://scripts/enemy.gd")


@onready var cooldown_bar = $Control/CooldownBar
@onready var cooldown_timer = $CooldownTimer
@onready var sprite = $Sprite2D
@onready var health_bar = $Control/HealthBar
@onready var defeat_filter = $Control/DefeatFilter
@onready var tile_map = get_node("../../TileMap2") as TileMap

signal character_damaged
signal character_killed

func _ready():
	on_cooldown = false
	health_bar.value = health_bar.max_value # health_bar.max_value

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	mouse_map_position = tile_map.local_to_map(get_global_mouse_position())
	
	if draggable and !on_cooldown and !is_defeated:
		if Input.is_action_just_pressed("left_click"):
			global.is_dragging = true
			global.dragged_char_name = name
		if Input.is_action_pressed("left_click"):
			global.dragged_char_name = name
		elif Input.is_action_just_released("left_click") and name == global.dragged_char_name:
			sprite.scale = Vector2(0.2, 0.2)
			global.is_dragging = false
			global.dragged_char_name = ""

			
	cooldown_bar.value = cooldown_timer.time_left

func _on_area_2d_mouse_entered():
	var tween := create_tween()
	# prints("mouse entered")
	if !global.is_dragging and !on_cooldown and !is_defeated:
		draggable = true
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_exited():
	var tween := create_tween()
	if !global.is_dragging:
		draggable = false
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)
		
func preview_attack_AoE(hovered_tile, offset_list):
	for offset in offset_list:
		var target_pos : Vector2i = hovered_tile + offset as Vector2i
		var detected_enemy = global.enemy_dict.get(target_pos)
		
		if within_bounds(target_pos):
			tile_map.set_cell(hover_layer, target_pos, 2, Vector2i(0, 0), 0)
			hover_active = true
		else:
			hover_active = false
		
		if Input.is_action_just_released("left_click"):
			var valid_enemy = detected_enemy is EnemyScript
			if is_instance_valid(detected_enemy) and valid_enemy:
				drop_attack(detected_enemy)
			
			if hover_active:
				start_cooldown()
			

func drop_attack(detected_enemy : CharacterBody2D):
	detected_enemy.hit(attack_damage)
	start_cooldown()
	
func start_cooldown():
	on_cooldown = true
	global.is_dragging = false
	
	if not on_cooldown or is_defeated: return 
	
	cooldown_bar.max_value = cooldown_timer.wait_time
	cooldown_timer.start()
	cooldown_bar.show()
	scale = Vector2(1, 1)
	
func _on_cooldown_timer_timeout():
	on_cooldown = false
	cooldown_bar.hide()
	draggable = false

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
	is_dragging = false
	global.is_dragging = false
	global.is_released = false
	global.dragged_char_name = ""
	
func within_bounds(coordinate : Vector2) -> bool:
	var x_valid = coordinate.x >= min_hover_x and coordinate.x <= max_hover_x
	var y_valid = coordinate.y >= min_hover_y and coordinate.y <= max_hover_y
	
	if x_valid and y_valid:
		return true
	return false
