class_name PowerAttackState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar
@export var attack_damage : int
@export var wait_anim_time : float

@onready var tile_map = get_node("../../..") as TileMap

@onready var kai = get_node("../../../../DraggableIcons/kai") as Node2D
@onready var emerald =  get_node("../../../../DraggableIcons/emerald") as Node2D
@onready var tyrone =  get_node("../../../../DraggableIcons/tyrone") as Node2D
@onready var bettany =  get_node("../../../../DraggableIcons/bettany") as Node2D


const top_left_tile = Vector2i(9, 3)
const bottom_right_tile = Vector2i(23, 10)
var current_map_position
var curr_health
var stun_signal_emitted = false

#Will move towards a random position, wind up, then damage all players
#if hit during wind up, will go to stun state

signal p_attack_finished
signal hit_at_wind_up

func _ready():
	set_physics_process(false)
	anim.frame_changed.connect(inflict_damage)

func _enter_state():
	prints("Entered Power Attack State")
	#go to random position in grid
	#wind up
	set_physics_process(true)
	curr_health = healthbar.value
	prints("power attacking")
	anim.play("wind_up_power")
	await anim.animation_finished
	
	#shake camera?
	anim.play("attack_power")
	await anim.animation_finished
	if anim.animation == "attack_power" and anim.animation_finished:
		p_attack_finished.emit()

func inflict_damage():
	if not anim.animation == "attack_power" or not anim.frame == 7:
		return
	if !kai.is_defeated and !emerald.is_defeated and !tyrone.is_defeated and !bettany.is_defeated : 
		await get_tree().create_timer(wait_anim_time).timeout
		kai.take_damage(attack_damage)
		emerald.take_damage(attack_damage)
		tyrone.take_damage(attack_damage)
		bettany.take_damage(attack_damage)
		
	await anim.animation_finished

func _physics_process(delta):
	wind_up_check()

func wind_up_check():
	if healthbar.value < curr_health and stun_signal_emitted == false:
		hit_at_wind_up.emit()
		stun_signal_emitted = true
		set_physics_process(false)

func _exit_state():
	prints("Exited Power Attack State")
	set_physics_process(false)
	anim.stop()
	stun_signal_emitted = false
