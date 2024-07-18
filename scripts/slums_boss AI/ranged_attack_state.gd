class_name RangedAttackState
#Will move to random position in the grid then perform attack that will damage adjacent character
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar
@export var ranged_attack_range : int
@export var wait_anim_time : float
@export var attack_damage : int

@onready var tile_map = get_node("../../..") as TileMap

@onready var kai = get_node("../../../../DraggableIcons/kai") as Node2D
@onready var emerald =  get_node("../../../../DraggableIcons/emerald") as Node2D
@onready var tyrone =  get_node("../../../../DraggableIcons/tyrone") as Node2D
@onready var bettany =  get_node("../../../../DraggableIcons/bettany") as Node2D

const top_left_tile = Vector2i(9, 3)
const bottom_right_tile = Vector2i(23, 10)
var current_map_position

var kai_hitbox : Array[int]
var emerald_hitbox : Array[int]
var tyrone_hitbox : Array[int]
var bettany_hitbox : Array[int]

signal r_attack_finished

func _ready():
	set_physics_process(false)
	anim.frame_changed.connect(inflict_damage)

func _enter_state():
	prints("Entered Ranged Attack State")
	set_physics_process(true)
	current_map_position = tile_map.local_to_map(actor.position)
	set_up_hitbox()
	#attack character
	anim.play("wind_up_ranged")
	await anim.animation_finished
	
	anim.play("attack_ranged")
	await anim.animation_finished
	r_attack_finished.emit()

func set_up_hitbox():
	kai_hitbox = [top_left_tile.y, top_left_tile.y + 1]
	emerald_hitbox  = [top_left_tile.y + 2, top_left_tile.y + 3]
	tyrone_hitbox = [top_left_tile.y + 4, top_left_tile.y + 5]
	bettany_hitbox = [top_left_tile.y + 6, top_left_tile.y + 7]

func inflict_damage():
	if not anim.animation == "attack_ranged" or not anim.frame == 7:
		return
		
	var kai_aligned = current_map_position.y in kai_hitbox
	var emerald_aligned = current_map_position.y in emerald_hitbox
	var tyrone_aligned = current_map_position.y in tyrone_hitbox
	var bettany_aligned = current_map_position.y in bettany_hitbox
	
	if not within_attack_range(): return
	
	if kai_aligned and not kai.is_defeated:
		kai.take_damage(attack_damage)
		
	if emerald_aligned and not emerald.is_defeated:
		emerald.take_damage(attack_damage)
	
	if tyrone_aligned and not tyrone.is_defeated:
		tyrone.take_damage(attack_damage)
	
	if bettany_aligned and not bettany.is_defeated: 
		bettany.take_damage(attack_damage)
		
	await anim.animation_finished

func within_attack_range() -> bool:
	if abs(top_left_tile.x - current_map_position.x) <= ranged_attack_range:
		return true
	else:
		return false

func _exit_state():
	set_physics_process(false)
	prints("Exited Ranged Attack State")
	anim.stop()
