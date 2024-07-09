extends CharacterBody2D

@export var attack_damage : int

const BattleNode = preload("res://scripts/battle.gd")

@onready var anim = $AnimatedSprite2D
@onready var healthbar = $HealthBar as ProgressBar
@onready var move_timer_bar = get_node("../../MoveTimerBar") as ProgressBar
@onready var move_timer = get_node("../../EnemyMoveTimer") as Timer
@onready var tile_map = get_parent() as TileMap
@onready var battle_node = get_node("../..") as BattleNode

var health : int
var player_chase = false
var player = null
var is_defeated : bool
var is_attacking : bool
var is_waiting : bool
var current_map_position : Vector2i

@onready var kai = get_node("../../VBoxContainer/kai") as Node2D
@onready var emerald = get_node("../../VBoxContainer/emerald") as Node2D
@onready var tyrone = get_node("../../VBoxContainer/tyrone") as Node2D
@onready var bettany = get_node("../../VBoxContainer/bettany") as Node2D

@export var kai_hitbox : Array[int]
@export var emerald_hitbox : Array[int]
@export var tyrone_hitbox : Array[int]
@export var bettany_hitbox : Array[int]

func _ready():
	current_map_position = tile_map.local_to_map(position)
	health = healthbar.max_value
	healthbar.value = health
	#global.add_enemy(current_map_position, self)

	anim.play("idle")
	
func _process(delta):
	current_map_position = tile_map.local_to_map(position)

func action():
	if is_defeated: return
	elif current_map_position.x == 9 or is_attacking:
		attack_character()
		return

	move_animation()
	current_map_position = tile_map.local_to_map(position)

func hit(damage : int):
	healthbar.value -= damage
	if healthbar.value <= 0:
		is_defeated = true
		anim.flip_h = false
		anim.play("death")
		await anim.animation_finished
		anim.stop()
		global.delete_enemy(current_map_position)
		queue_free()
		remove_from_group("enemies")
		#battle_node.record_enemies()

func move_animation():
	var new_position = Vector2(position.x - 16, position.y)
	var new_map_position = tile_map.local_to_map(new_position)
	var next_enemy := global.get_enemy(new_map_position)
	
	if is_blocked(): return
	
	is_waiting = false
		
	var previous_map_position = tile_map.local_to_map(position)
	var tween = create_tween()
	move_timer.stop()
	anim.flip_h = true
	anim.stop()
	anim.play("walk", 2.2)
	tween.tween_property(self, "position", new_position, 0.5).set_ease(Tween.EASE_OUT)
	await anim.animation_finished
	
	move_timer.start()
	#global.delete_enemy(previous_map_position)
	#global.add_enemy(current_map_position, self)
	anim.play("idle")
	
	current_map_position = tile_map.local_to_map(position)

func attack_character():
	var kai_aligned = current_map_position.y in kai_hitbox
	var emerald_aligned = current_map_position.y in emerald_hitbox
	var tyrone_aligned = current_map_position.y in tyrone_hitbox
	var bettany_aligned = current_map_position.y in bettany_hitbox
	is_attacking = true
	
	if current_map_position.x != 9: return
	
	if kai_aligned : kai.take_damage(attack_damage)
	if emerald_aligned : emerald.take_damage(attack_damage)
	if tyrone_aligned : tyrone.take_damage(attack_damage)
	if bettany_aligned : bettany.take_damage(attack_damage)
	
	anim.pause()
	anim.flip_h = false
	anim.play("attack")
	
func is_blocked() -> bool:
	var new_position = Vector2(position.x - 16, position.y)
	var new_map_position = tile_map.local_to_map(new_position)
	var next_enemy := global.get_enemy(new_map_position)
	
	if is_instance_valid(next_enemy):
		prints(get_instance_id(), next_enemy.is_blocked())
		return next_enemy.is_blocked()
		
	return new_map_position.x < 9
			
