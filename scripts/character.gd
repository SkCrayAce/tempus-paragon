extends Node2D

enum States {READY, ATTACKING, ON_COOLDOWN, DEFEATED}

var current_state : States
var draggable : bool = false
var on_cooldown : bool = false
var is_defeated : bool = false
var is_attacking : bool

var mouse_map_position : Vector2
var tween : Tween
var tilemap_dict : Dictionary
var hovered_tile : Vector2i
var offset_list : Array
var current_health : int

const grid_length = 120
const grid_height = 68
const ground_layer = 0
const hover_layer = 1
const top_left_tile = Vector2i(9, 3)
const bottom_right_tile = Vector2i(23, 10)

@export var max_health : int = 3000
@export var attack_damage : int
var attack_frame : int 
var sound_frame : int 

# Attack SFX
const BettanyAtkSfx = preload("res://audio/sfx/basicATK_bettany_v03.mp3")
const EmeraldAtkSfx = preload("res://audio/sfx/basicATK_emerald_v03.mp3")
const KaiAtkSfx = preload("res://audio/sfx/basicATK_kai_v02.mp3")
const TyroneAtkSfx = preload("res://audio/sfx/basicATK_tyrone_v01.mp3")

# Take Damage SFX
const BETTANY_HURT_SFX = preload("res://audio/03 - Hurt Sound/Bettany/bettany-hurt.mp3")
const EMERALD_HURT_SFX = preload("res://audio/03 - Hurt Sound/Emerald/emerald-hurt.mp3")
const KAI_HURT_SFX = preload("res://audio/03 - Hurt Sound/Kai/kai-hurt.mp3")
const TYRONE_HURT_SFX = preload("res://audio/03 - Hurt Sound/Tyrone/tyrone-hurt_v02.mp3")

var min_hover_x : int = top_left_tile.x
var max_hover_x : int = bottom_right_tile.x
var min_hover_y : int = top_left_tile.y
var max_hover_y : int = bottom_right_tile.y

const BattleScript = preload("res://scripts/battle.gd")
const EnemyScript = preload("res://scripts/enemy.gd")
const BossScript = preload("res://scripts/slums_boss AI/slumsboss.gd")

const AttackEffectScene = preload("res://scenes/attack_effect.tscn")

@onready var cooldown_bar = $DragIcon/CooldownBar 
@onready var cooldown_timer = $CooldownTimer
@onready var sprite = $DragIcon/SpriteContainer
@onready var health_bar = $DragIcon/HealthBar
@onready var defeat_filter = $DragIcon/DefeatFilter
@onready var battle_node = get_node("../..") as BattleScript
@onready var slums_tile_map = $"../../SlumsTileMap"
@onready var enemy_move_timer = $"../../EnemyMoveTimer"
@onready var animation_timer = $"../../AnimationTimer"
@onready var camera = $"../../Camera2D" as Camera2D
@onready var drag_icon = $DragIcon

@onready var battle_sprite = $BattleSprite as Node2D
@onready var anim_sprite : AnimatedSprite2D = $BattleSprite/AnimatedSprite2D
@onready var hit_effect = $BattleSprite/HitEffect
@onready var attack_sfx_player = $AttackSFXPlayer as AudioStreamPlayer2D
@onready var hurt_sfx_player = $HurtSFXPlayer as AudioStreamPlayer2D

var char_sprite : Node2D

#for camera shake
@export var random_strength : float = 30.0
@export var shake_fade : float = 5.0
var rng = RandomNumberGenerator.new()
var shake_strength : float
var shake_enabled : bool

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
	shake_enabled = false
	set_up_max_hp()
	char_sprite = battle_sprite
	
	initial_pos = char_sprite.global_position
	anim_sprite.frame_changed.connect(inflict_damage)
	anim_sprite.frame_changed.connect(play_attack_sfx)
	anim_sprite.play("idle")
	
	match name :
		"kai" : 
			attack_sfx_player.stream = KaiAtkSfx
			attack_frame = 5
			sound_frame = 4
		"emerald" : 
			attack_sfx_player.stream = EmeraldAtkSfx
			attack_frame = 5
			sound_frame = 5
		"tyrone" : 
			attack_sfx_player.stream = TyroneAtkSfx
			attack_frame = 10
			sound_frame = 8
		"bettany" : 
			attack_sfx_player.stream = BettanyAtkSfx
			attack_frame = 15
			sound_frame = 8
	
	attack_sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
	hurt_sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	current_state = States.READY
	prints("ENUM", current_state)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if draggable and !on_cooldown and !is_defeated:
		if Input.is_action_just_pressed("left_click"):
			global.is_dragging = true
			global.dragged_char_name = name

	cooldown_bar.value = cooldown_timer.time_left
	current_health = health_bar.value
	
	if shake_enabled == true:
		apply_shake()
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		camera.offset = random_offset() + Vector2(15, 0)
		

func set_up_max_hp():
	
	global.kai_max_hp = max_health
	global.emerald_max_hp = max_health
	global.tyrone_max_hp = max_health
	global.bettany_max_hp = max_health
	
	if not global.hp_initialized:
		global.kai_curr_hp = max_health
		global.emerald_curr_hp = max_health
		global.tyrone_curr_hp = max_health
		global.bettany_curr_hp = max_health
		global.hp_initialized = true
		print("health initialized")
	
	
func _on_area_2d_mouse_entered():
	if is_attacking : return
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
	if not draggable: return
	
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
			var attack_position 
			
			if name == "kai" or name == "tyrone": attack_position = tile_map.map_to_local(hovered_tile + Vector2i(-1, 0))
			else: attack_position = tile_map.map_to_local(hovered_tile + 3*Vector2i(-1, 0))
			
			tween = create_tween()
			is_attacking = true
			battle_node.set_timers_paused(true)
			current_state = States.ATTACKING
			anim_sprite.play("walk")
			tween.tween_property(char_sprite, "global_position", attack_position, 0.25).set_ease(Tween.EASE_OUT)
			tween.finished.connect(attack_animation)
			
	
func attack_animation():
	anim_sprite.play("attack")
	anim_sprite.frame_changed.connect(attack_effects)
	anim_sprite.animation_finished.connect(return_to_position)
	
func attack_effects(attack_effect_instance):
	if not anim_sprite.animation == "attack":
		return
	
	get_node("../../SlumsTileMap").add_child(attack_effect_instance)
	attack_effect_instance.show()
	match name:
		"kai":
			attack_effect_instance.scale = Vector2(0.5, 0.5)
			attack_effect_instance.position = attack_effect_instance.position + Vector2(-15, 20)
			attack_effect_instance.play("space_slash")
			await attack_effect_instance.animation_finished
			
		"emerald":
			attack_effect_instance.scale = Vector2(0.9, 0.9)
			attack_effect_instance.position = attack_effect_instance.position + Vector2(0, 28)
			attack_effect_instance.play("bullet_impact")
			await attack_effect_instance.animation_finished
		
		"tyrone":
			attack_effect_instance.hide()
			shake_enabled = true
			await get_tree().create_timer(0.5).timeout
			shake_enabled = false
			
		"bettany":
			attack_effect_instance.play("fire_column")
			await attack_effect_instance.animation_finished
	
	attack_effect_instance.hide()
	attack_effect_instance.queue_free()
	
func play_attack_sfx():
	if anim_sprite.animation == "attack" and anim_sprite.frame == sound_frame:
		attack_sfx_player.play()
	
func inflict_damage():
	if not anim_sprite.animation == "attack" or not anim_sprite.frame == attack_frame:
		return
		
	start_cooldown()
	
	for offset in offset_list:
		var target_pos : Vector2i = hovered_tile + offset as Vector2i
		
		var attack_effect_instance = AttackEffectScene.instantiate()
		attack_effect_instance.position = tile_map.map_to_local(target_pos - Vector2i(0, 2))
		attack_effects(attack_effect_instance)
		
		var detected_enemy = global.enemy_dict.get(target_pos)
		var valid_enemy = detected_enemy is EnemyScript or detected_enemy is BossScript
		if is_instance_valid(detected_enemy) and valid_enemy:
			detected_enemy.hit(attack_damage)

func return_to_position():
	if is_defeated: return
	
	var back_to_idle = func(): 
		anim_sprite.flip_h = false
		anim_sprite.play("idle")
		is_attacking = false
		battle_node.set_timers_paused(false)
		current_state = States.ON_COOLDOWN
		
	tween = create_tween()
	#anim_sprite.flip_h = true
	anim_sprite.play("walk_back")
	tween.tween_property(char_sprite, "global_position", initial_pos, 0.25).set_ease(Tween.EASE_OUT)
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
	#draggable = false

func take_damage(damage : int):
	var play_hurt_sfx = func(stream):
		hurt_sfx_player.stream = stream
		hurt_sfx_player.play()
		
	match name:
		"kai" : play_hurt_sfx.call(KAI_HURT_SFX)
		"emerald" : play_hurt_sfx.call(EMERALD_HURT_SFX)
		"tyrone" : play_hurt_sfx.call(TYRONE_HURT_SFX)
		"bettany" : play_hurt_sfx.call(BETTANY_HURT_SFX)
		
	health_bar.value -= damage
	hit_effect.play("hit_flash", -1, 2)
	battle_node.update_team_health()
	if is_defeated: return
	
	if health_bar.value <= 0:
		character_defeated()

func character_defeated():
	character_killed.emit()
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

func apply_shake():
	shake_strength = random_strength

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))

