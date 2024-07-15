extends CharacterBody2D

@export var attack_damage : int

const BattleNode = preload("res://scripts/battle.gd")


@onready var healthbar = $HealthBar as ProgressBar
@onready var tile_map = get_parent() as TileMap
@onready var battle_node = get_node("../..") as BattleNode
@onready var animation_timer = get_node("../../AnimationTimer") as Timer
@onready var effect = $Effect as AnimationPlayer
@onready var ranged_animated_sprite = $RangedAnimatedSprite as AnimatedSprite2D

var health : int
var player_chase = false
var player = null
var is_defeated : bool
var is_attacking : bool
var is_waiting : bool
var current_map_position : Vector2i
var tween : Tween
var new_position : Vector2

@onready var kai = get_node("../../VBoxContainer/kai") as Node2D
@onready var emerald = get_node("../../VBoxContainer/emerald") as Node2D
@onready var tyrone = get_node("../../VBoxContainer/tyrone") as Node2D
@onready var bettany = get_node("../../VBoxContainer/bettany") as Node2D


@export var kai_hitbox : Array[int]
@export var emerald_hitbox : Array[int]
@export var tyrone_hitbox : Array[int]
@export var bettany_hitbox : Array[int]

signal enemy_died

func _ready():
	current_map_position = tile_map.local_to_map(position)
	health = healthbar.max_value
	healthbar.value = health
	ranged_animated_sprite.play("side_idle_left")

	
	
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
	effect.play("hit_flash")
	healthbar.value -= damage
	if healthbar.value <= 0:
		enemy_defeated()
		
func enemy_defeated():
	is_defeated = true
	emit_signal("enemy_died")
	global.delete_enemy(current_map_position)
	ranged_animated_sprite.play("death")
	remove_from_group("enemies")
	await ranged_animated_sprite.animation_finished
	ranged_animated_sprite.stop()
	queue_free()

func move_animation():
	new_position = Vector2(position.x - 16, position.y)
	var new_map_position = tile_map.local_to_map(new_position)
	
	if is_blocked(): return
	
	is_waiting = false
	
	tween = create_tween()
	ranged_animated_sprite.stop()
	ranged_animated_sprite.play("walk", 2.2)
	tween.tween_property(self, "position", new_position, animation_timer.wait_time).set_ease(Tween.EASE_OUT)
	
	current_map_position = tile_map.local_to_map(position)
	
func stop_animation():
	if is_instance_valid(tween):
		tween.kill()
	if is_attacking:
		ranged_animated_sprite.play("attack")
		return
		
	ranged_animated_sprite.play("side_idle_left")
	
func attack_character():
	var kai_aligned = current_map_position.y in kai_hitbox
	var emerald_aligned = current_map_position.y in emerald_hitbox
	var tyrone_aligned = current_map_position.y in tyrone_hitbox
	var bettany_aligned = current_map_position.y in bettany_hitbox
	is_attacking = true
	
	if current_map_position.x != 9: return
	
	ranged_animated_sprite.pause()
	ranged_animated_sprite.play("attack")
	
	
	#if ranged_animated_sprite.frame == 4:
	if kai_aligned : kai.take_damage(attack_damage)
	if emerald_aligned : emerald.take_damage(attack_damage)
	if tyrone_aligned : tyrone.take_damage(attack_damage)
	if bettany_aligned : bettany.take_damage(attack_damage)
		
	await ranged_animated_sprite.animation_finished
	
func is_blocked() -> bool:
	var next_position = Vector2(position.x - 16, position.y)
	var next_map_position = tile_map.local_to_map(next_position)
	var next_enemy := global.get_enemy(next_map_position)
	
	if is_instance_valid(next_enemy):
		return next_enemy.is_blocked()
		
	return next_map_position.x < 9
			
