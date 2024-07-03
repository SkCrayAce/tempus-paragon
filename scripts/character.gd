extends Node2D

var draggable = false
var offset : Vector2
var initialPos : Vector2
var on_cooldown = false
var defeated = false
var is_dragging : bool = false
var ground_layer = 0
var hover_layer = 1

@export var attack_damage : int

const enemy_script = preload("res://scripts/enemy.gd")

@onready var cooldown_bar = $Control/CooldownBar
@onready var cooldown_timer = $CooldownTimer
@onready var sprite = $Sprite2D
@onready var health_bar = $Control/HealthBar
@onready var defeat_filter = $Control/DefeatFilter
@onready var battle = $"../../Battle"
@onready var tile_map = get_node("../../TileMap")


func _ready():
	#prints("character ready")
	on_cooldown = false
	initialPos = sprite.position
	health_bar.value = health_bar.max_value # health_bar.max_value
	#battle.attack_finished.connect(start_cooldown)
	#prints(character_ids)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if health_bar.value <= 0:
		#defeat_filter.visible = true
		#defeated = true
	if draggable and !on_cooldown and !defeated:
		if Input.is_action_just_pressed("left_click"):
			global.is_dragging = true
			offset = get_global_mouse_position() - global_position
			global.dragged_char_name = name
		if Input.is_action_pressed("left_click"):
			global.dragged_char_name = name
		elif Input.is_action_just_released("left_click") and name == global.dragged_char_name:
			sprite.scale = Vector2(0.2, 0.2)
			global.is_dragging = false
			global.dragged_char_name = " "
			start_cooldown()
			
	cooldown_bar.value = cooldown_timer.time_left

func _on_area_2d_mouse_entered():
	#prints("mouse entered at:", name)
	var tween := create_tween()
	# prints("mouse entered")
	if !global.is_dragging and !on_cooldown and !defeated:
		draggable = true
		#sprite.scale = Vector2(0.25, 0.25)
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_exited():
	#prints("mouse exited at:", name)
	var tween := create_tween()
	if !global.is_dragging:
		draggable = false
		tween.tween_property(self, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)
		
func attack_AoE(hovered_tile, offset_list):
	for offset in offset_list:
		var target_pos : Vector2i = hovered_tile + offset as Vector2i
		var x_valid = target_pos.x > 0 and target_pos.x <= 16 
		var y_valid = target_pos.y > 0 and target_pos.y <= 8
		var world_pos : Vector2 = tile_map.map_to_local(target_pos)
		
		var detected_enemy = global.enemy_dict.get(target_pos)
		prints("detected_enemy:", detected_enemy)
		
		if x_valid and y_valid:
			tile_map.set_cell(hover_layer, target_pos, 1, Vector2i(0, 0), 0)
		
		if is_instance_valid(detected_enemy) and detected_enemy is enemy_script and Input.is_action_just_released("left_click"):
			prints("enemy hit")
			detected_enemy.hit(attack_damage)
			
func start_cooldown():
	on_cooldown = true

	if not on_cooldown or defeated: return 
	
	cooldown_bar.max_value = cooldown_timer.wait_time
	cooldown_timer.start()
	cooldown_bar.show()
	scale = Vector2(1, 1)
	
func _on_cooldown_timer_timeout():
	on_cooldown = false
	#cooldown_timer.stop()
	cooldown_bar.hide()
	#prints(name, "cooldown at timer end:", on_cooldown)
	draggable = false

func take_damage(damage : int):
	health_bar.value -= damage
	
	if defeated: return
	
	if health_bar.value <= 0:
		defeated = true
		defeat_filter.show()
		is_dragging = false
		global.is_dragging = false
		global.is_released = false
		global.dragged_char_name = ""
	#prints("damage taken: ")
	
		
