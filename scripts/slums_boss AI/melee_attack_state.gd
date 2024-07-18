#Will move towards a random position at the leftmost grid, will damage adjacent player

class_name MeleeAttackState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar
@export var melee_attack_range : int
@export var attack_damage : int

@export var rush_to_character_time : int
@export var wait_anim_time : float

@onready var tile_map = get_parent().get_parent().get_parent() as TileMap

@onready var kai = get_parent().get_parent().get_parent().get_parent().find_child("VBoxContainer").find_child("kai") as Node2D
@onready var emerald =  get_parent().get_parent().get_parent().get_parent().find_child("VBoxContainer").find_child("emerald") as Node2D
@onready var tyrone =  get_parent().get_parent().get_parent().get_parent().find_child("VBoxContainer").find_child("tyrone") as Node2D
@onready var bettany =  get_parent().get_parent().get_parent().get_parent().find_child("VBoxContainer").find_child("bettany") as Node2D

signal m_attack_finished

const top_left_tile = Vector2i(9+1, 3)
const bottom_right_tile = Vector2i(23, 10)
var old_position
var tween
var melee_position
var current_map_position

var kai_hitbox : Array[int]
var emerald_hitbox : Array[int]
var tyrone_hitbox : Array[int]
var bettany_hitbox : Array[int]

func _ready():
	set_physics_process(false)

func _enter_state():
	set_physics_process(true)
	old_position = actor.position
	
	prints("Entered Melee Attack State")
	set_up_hitbox()
	anim.play("wind_up_melee")
	await anim.animation_finished
	
	move_to_new_pos()
	await get_tree().create_timer(1.1).timeout
	
	if actor.position == melee_position:
		attack_character()
		record_position()
		anim.play("attack_melee")
		await anim.animation_finished
		#prints("melee attacking done")
		m_attack_finished.emit()
		
	
func move_to_new_pos():
	#random position in grid
	melee_position = tile_map.map_to_local(Vector2(top_left_tile.x, randi_range(top_left_tile.y, bottom_right_tile.y)))
	prints(melee_position, " in ", rush_to_character_time, " seconds")
	var new_map_position = tile_map.local_to_map(melee_position)
	
	tween = create_tween()
	anim.play("moving")
	anim.speed_scale = 2.0
	tween.tween_property(actor, "position", melee_position, rush_to_character_time).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(rush_to_character_time).timeout
	anim.speed_scale = 1.0
	current_map_position = tile_map.local_to_map(actor.position)

func set_up_hitbox():
	kai_hitbox = [top_left_tile.y, top_left_tile.y + 1]
	emerald_hitbox  = [top_left_tile.y + 2, top_left_tile.y + 3]
	tyrone_hitbox = [top_left_tile.y + 4, top_left_tile.y + 5]
	bettany_hitbox = [top_left_tile.y + 6, top_left_tile.y + 7]

func attack_character():
	var kai_aligned = current_map_position.y in kai_hitbox
	var emerald_aligned = current_map_position.y in emerald_hitbox
	var tyrone_aligned = current_map_position.y in tyrone_hitbox
	var bettany_aligned = current_map_position.y in bettany_hitbox
	
	if not within_attack_range(): return
	
	if kai_aligned and not kai.is_defeated: 
		await get_tree().create_timer(wait_anim_time).timeout
		kai.take_damage(attack_damage)
		
	if emerald_aligned and not emerald.is_defeated:
		await get_tree().create_timer(wait_anim_time).timeout 
		emerald.take_damage(attack_damage)
	
	if tyrone_aligned and not tyrone.is_defeated:
		await get_tree().create_timer(wait_anim_time).timeout 
		tyrone.take_damage(attack_damage)
	
	if bettany_aligned and not bettany.is_defeated: 
		await get_tree().create_timer(wait_anim_time).timeout
		bettany.take_damage(attack_damage)
		
	await anim.animation_finished

func within_attack_range() -> bool:
	if abs(top_left_tile.x - current_map_position.x) <= melee_attack_range:
		return true
	else:
		return false

func record_position():
	global.enemy_dict.erase(tile_map.local_to_map(old_position))
	var boss_map_pos = tile_map.local_to_map(actor.position)
	global.enemy_dict[boss_map_pos] = actor
	print("position recorded! ", boss_map_pos)


func _exit_state():
	prints("Exited Melee Attack State")
	set_physics_process(false)

