class_name PowerAttackState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar
@export var attack_damage : int
@export var wait_anim_time : float
@export var attack_frame : int

@onready var tile_map = get_node("../../..") as TileMap

@onready var kai = get_node("../../../../DraggableIcons/kai") as Node2D
@onready var emerald =  get_node("../../../../DraggableIcons/emerald") as Node2D
@onready var tyrone =  get_node("../../../../DraggableIcons/tyrone") as Node2D
@onready var bettany =  get_node("../../../../DraggableIcons/bettany") as Node2D
@onready var boss_sfx =  get_node("../../BossSFX") as AudioStreamPlayer2D
@onready var camera = get_node("../../../../Camera2D") as Camera2D


#for camera shake
@export var random_strength : float = 30.0
@export var shake_fade : float = 5.0
var rng = RandomNumberGenerator.new()
var shake_strength : float
var shake_enabled : bool


const top_left_tile = Vector2i(9, 3)
const bottom_right_tile = Vector2i(23, 10)
var current_map_position
var curr_health
var stun_signal_emitted = false

const BOSS_POWER_ATTACK = preload("res://audio/04 - Boss/06 - Power Attack/boss-power attack.mp3")
const BOSS_CHARGING_UP_V_02 = preload("res://audio/04 - Boss/03 - Charging up/boss-charging up_v02.mp3")

signal p_attack_finished
signal hit_at_wind_up

func _ready():
	if global.boss_is_defeated:
		return
	set_physics_process(false)
	anim.frame_changed.connect(inflict_damage)
	anim.frame_changed.connect(play_sfx)

func _enter_state():
	prints("Entered Power Attack State")
	#go to random position in grid
	#wind up
	set_physics_process(true)
	shake_enabled = false
	curr_health = healthbar.value
	prints("power attacking")
	anim.play("wind_up_power")
	boss_sfx.stream = BOSS_CHARGING_UP_V_02
	boss_sfx.play()
	await anim.animation_finished
	
	#shake camera?
	anim.play("attack_power")
	await anim.animation_finished
	if anim.animation == "attack_power" and anim.animation_finished:
		p_attack_finished.emit()

func inflict_damage():
	if not anim.animation == "attack_power" or not anim.frame == attack_frame:
		return
	shake_enabled = true
	if !kai.is_defeated :
		#await get_tree().create_timer(wait_anim_time).timeout
		kai.take_damage(attack_damage)
	if !emerald.is_defeated:
		emerald.take_damage(attack_damage)
	if !tyrone.is_defeated:
		tyrone.take_damage(attack_damage)
	if !bettany.is_defeated: 
		bettany.take_damage(attack_damage)
		
	await anim.animation_finished

func _physics_process(delta):
	record_position()
	wind_up_check()
	
	if shake_enabled == true:
		apply_shake()
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)
		camera.offset = random_offset() + Vector2(15, 0)
	else:
		shake_enabled = false
		

func record_position():
	global.enemy_dict.clear()
	var boss_map_pos = tile_map.local_to_map(actor.position)
	global.enemy_dict[boss_map_pos + Vector2i.LEFT] = actor
	global.enemy_dict[boss_map_pos] = actor
	global.enemy_dict[boss_map_pos + Vector2i.RIGHT] = actor

func wind_up_check():
	if healthbar.value < curr_health and stun_signal_emitted == false:
		anim.stop()
		hit_at_wind_up.emit()
		stun_signal_emitted = true
		set_physics_process(false)

func play_sfx():
	if anim.animation == "attack_power":
		if anim.frame == attack_frame:
			boss_sfx.stream = BOSS_POWER_ATTACK
			boss_sfx.play()

func apply_shake():
	shake_strength = random_strength

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
	

func _exit_state():
	prints("Exited Power Attack State")
	print("shake enabled? ", shake_enabled)
	set_physics_process(false)
	anim.stop()
	stun_signal_emitted = false
