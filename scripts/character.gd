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
const top_left_tile = Vector2i(9, 3)
const bottom_right_tile = Vector2i(23, 10)

@export var max_health : int
@export var attack_damage : int

var min_hover_x : int = top_left_tile.x
var max_hover_x : int = bottom_right_tile.x
var min_hover_y : int = top_left_tile.y
var max_hover_y : int = bottom_right_tile.y

const BattleScript = preload("res://scripts/battle.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const BossScript = preload("res://scripts/slums_boss AI/slumsboss.gd")

@onready var cooldown_bar = $DragIcon/CooldownBar 
@onready var cooldown_timer = $CooldownTimer
@onready var sprite = $DragIcon/SpriteContainer
@onready var health_bar = $DragIcon/HealthBar
@onready var defeat_filter = $DragIcon/DefeatFilter
@onready var battle_node = get_node("../..") as BattleScript
@onready var slums_tile_map = $"../../SlumsTileMap"
@onready var enemy_move_timer = $"../../EnemyMoveTimer"
@onready var animation_timer = $"../../AnimationTimer"
@onready var drag_icon = $DragIcon

@onready var battle_sprite = $BattleSprite as Node2D
@onready var anim_sprite : AnimatedSprite2D = $BattleSprite/AnimatedSprite2D
@onready var hit_effect = $BattleSprite/HitEffect
@onready var attack_sfx = $AttackSFX as AudioStreamPlayer2D

var char_sprite : Node2D


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
	set_up_max_hp()
	char_sprite = battle_sprite
	
	initial_pos = char_sprite.global_position
	anim_sprite.frame_changed.connect(inflict_damage)
	anim_sprite.play("idle")

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if draggable and !on_cooldown and !is_defeated:
		if Input.is_action_just_pressed("left_click"):
			global.is_dragging = true
			global.dragged_char_name = name

	cooldown_bar.value = cooldown_timer.time_left

func set_up_max_hp():
	
	global.kai_max_hp = max_health
	global.emerald_max_hp = max_health
	global.tyrone_max_hp = max_health
	global.bettany_max_hp = max_health
	
	if global.hp_initialized == false:
		global.kai_curr_hp = max_health
		global.emerald_curr_hp = max_health
		global.tyrone_curr_hp = max_health
		global.bettany_curr_hp = max_health
		global.hp_initialized = true
		print("health initialized")
	
	
func _on_area_2d_mouse_entered():
	var tween := create_tween()
	if !global.is_dragging and !on_cooldown and !is_defeated:
		draggable = true
		tween.tween_property(drag_icon, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_OUT)

func _on_area_2d_mouse_exited():
	var tween := create_tween()
	if !global.is_dragging:
		draggable = false
		tween.tween_property(drag_icon, "scale", Vector2(1, 1), 0.1).set_ease(Tween.EASE_OUT)

func preview_attack_AoE(new_hovered_tile, new_offset_list):
	hovered_tile = new_hovered_tile
	offset_list = new_offset_list
	var hover_active : bool
	
	for offset in offset_list:
		var target_pos : Vector2i = hovered_tile + offset as Vector2i
		if within_bounds(target_pos):
			tile_map.set_cell(hover_layer, target_pos, 2, Vector2i(0, 0), 0)
			hover_active = true
			
	if Input.is_action_just_released("left_click"):
		global.is_dragging = false
		global.dragged_char_name = ""
		draggable = false
		if hover_active:
			var attack_position = tile_map.map_to_local(hovered_tile + Vector2i(-1, 0))
			tween = create_tween()
			enemy_move_timer.set_paused(true)
			animation_timer.set_paused(true)
			anim_sprite.play("walk")
			tween.tween_property(char_sprite, "global_position", attack_position, 0.5).set_ease(Tween.EASE_OUT)
			tween.finished.connect(attack_animation)
			
	
func attack_animation():
	match name:
		"kai": attack_sfx.stream = load("res://audio/sfx/basicATK_kai_v02.mp3") as AudioStream
		"emerald" : attack_sfx.stream = load("res://audio/sfx/basicATK_emerald_v03.mp3")
		"tyrone" : attack_sfx.stream = load("res://audio/sfx/basicATK_tyrone_v01.mp3")
		"bettany" : attack_sfx.stream = load("res://audio/sfx/basicATK_bettany_v03.mp3")
	attack_sfx.play()
	anim_sprite.play("attack")
	anim_sprite.animation_finished.connect(return_to_position)
			
func inflict_damage():
	if not anim_sprite.animation == "attack" or not anim_sprite.frame == 5:
		return
		
	start_cooldown()
	
	for offset in offset_list:
		var target_pos : Vector2i = hovered_tile + offset as Vector2i
		var detected_enemy = global.enemy_dict.get(target_pos)
		var valid_enemy = detected_enemy is EnemyScript or detected_enemy is BossScript
		if is_instance_valid(detected_enemy) and valid_enemy:
			detected_enemy.hit(attack_damage)

func return_to_position():
	if is_defeated: return
	
	var back_to_idle = func(): 
		anim_sprite.flip_h = false
		anim_sprite.play("idle")
		enemy_move_timer.set_paused(false)
		animation_timer.set_paused(false)
		
	tween = create_tween()
	anim_sprite.flip_h = true
	anim_sprite.play("walk")
	tween.tween_property(char_sprite, "global_position", initial_pos, 0.5).set_ease(Tween.EASE_OUT)
	tween.finished.connect(back_to_idle)
	
func start_cooldown():
	on_cooldown = true
	draggable = false
	if not on_cooldown or is_defeated: return 
	
	cooldown_bar.max_value = cooldown_timer.wait_time
	cooldown_timer.start()
	cooldown_bar.show()
	cooldown_timer.timeout.connect(end_cooldown)
	drag_icon.scale = Vector2(1, 1)
	
func end_cooldown():
	on_cooldown = false
	cooldown_bar.hide()
	draggable = false

func take_damage(damage : int):
	
	health_bar.value -= damage
	hit_effect.play("hit_flash")
	
	if is_defeated: return
	
	if health_bar.value <= 0:
		character_defeated()

func character_defeated():
	is_defeated = true
	anim_sprite.play("death")
	defeat_filter.show()
	global.is_dragging = false
	global.dragged_char_name = ""
	
func within_bounds(coordinate : Vector2) -> bool:
	var x_valid = coordinate.x >= min_hover_x and coordinate.x <= max_hover_x 
	var y_valid = coordinate.y >= min_hover_y and coordinate.y <= max_hover_y
	
	if x_valid and y_valid:
		return true
	else:
		return false



