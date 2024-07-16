extends CharacterBody2D

@export var attack_damage : int
@export var attack_range : int
@export var animated_sprite : AnimatedSprite2D

const BattleNode = preload("res://scripts/battle.gd")

@onready var healthbar = $HealthBar as TextureProgressBar
@onready var tile_map = get_parent() as TileMap
@onready var battle_node = get_node("../..") as BattleNode
@onready var animation_timer = get_node("../../AnimationTimer") as Timer
@onready var effect = $AnimationPlayer as AnimationPlayer


var health : int
var player_chase = false
var player = null
var is_defeated : bool
var is_attacking : bool
var is_waiting : bool
var current_map_position : Vector2i
var tween : Tween
var new_position : Vector2
var anim_sprite_frame

@onready var kai = get_node("../../VBoxContainer/kai") as Node2D
@onready var emerald = get_node("../../VBoxContainer/emerald") as Node2D
@onready var tyrone = get_node("../../VBoxContainer/tyrone") as Node2D
@onready var bettany = get_node("../../VBoxContainer/bettany") as Node2D

var kai_hitbox : Array[int]
var emerald_hitbox : Array[int]
var tyrone_hitbox : Array[int]
var bettany_hitbox : Array[int]

signal enemy_died

func _ready():
	var top_left_tile = battle_node.top_left_tile
	
	kai_hitbox = [top_left_tile.y, top_left_tile.y + 1]
	emerald_hitbox  = [top_left_tile.y + 2, top_left_tile.y + 3]
	tyrone_hitbox = [top_left_tile.y + 4, top_left_tile.y + 5]
	bettany_hitbox = [top_left_tile.y + 6, top_left_tile.y + 7]

	health = healthbar.max_value
	healthbar.value = health
	animated_sprite.play("side_idle_left")
	animated_sprite.frame_changed.connect(inflict_damage)

func _process(delta):
	current_map_position = tile_map.local_to_map(position)
	anim_sprite_frame = animated_sprite.frame

func action():
	if is_defeated: return
	
	elif within_attack_range() or is_attacking:
		attack_character()
		return

	move_animation()
	current_map_position = tile_map.local_to_map(position)

func hit(damage : int):
	if is_defeated:
		return
	if is_instance_valid(effect):
		effect.play("hit_flash")
		prints("enemy path", get_path())
		healthbar.value -= damage
		if healthbar.value <= 0:
			enemy_defeated()
		
func enemy_defeated():
	is_defeated = true
	global.delete_enemy(current_map_position)
	emit_signal("enemy_died")
	animated_sprite.play("death")
	remove_from_group("enemies")
	animated_sprite.animation_finished.connect(queue_free)

func move_animation():
	new_position = Vector2(position.x - 16, position.y)
	var new_map_position = tile_map.local_to_map(new_position)
	
	if is_blocked() or is_attacking: return
	
	tween = create_tween()
	animated_sprite.stop()
	animated_sprite.play("walk", 2.2)
	tween.tween_property(self, "position", new_position, animation_timer.wait_time).set_ease(Tween.EASE_OUT)
	
	current_map_position = tile_map.local_to_map(position)
	
func stop_animation():
	if is_instance_valid(tween):
		tween.kill()
	if is_attacking:
		animated_sprite.play("attack")
		return
		
	animated_sprite.play("side_idle_left")
	
func attack_character():
	
	is_attacking = true
	
	if not within_attack_range(): return
	
	animated_sprite.pause()
	animated_sprite.play("attack")

	
func inflict_damage():
	var kai_aligned = current_map_position.y in kai_hitbox
	var emerald_aligned = current_map_position.y in emerald_hitbox
	var tyrone_aligned = current_map_position.y in tyrone_hitbox
	var bettany_aligned = current_map_position.y in bettany_hitbox
	
	if not animated_sprite.animation == "attack" or not animated_sprite.frame == 4:
		return
		
	if kai_aligned and not kai.is_defeated : kai.take_damage(attack_damage)
	if emerald_aligned and not emerald.is_defeated: emerald.take_damage(attack_damage)
	if tyrone_aligned and not tyrone.is_defeated : tyrone.take_damage(attack_damage)
	if bettany_aligned and not bettany.is_defeated : bettany.take_damage(attack_damage)
	pass
	
func is_blocked() -> bool:
	var next_position = Vector2(position.x - 16, position.y)
	var next_map_position = tile_map.local_to_map(next_position)
	var next_enemy := global.get_enemy(next_map_position)
	
	if is_instance_valid(next_enemy):
		return next_enemy.is_blocked()
	
	if scene_file_path == "res://scenes/characters/melee_virulent.tscn":
		return next_map_position.x < battle_node.top_left_tile.x
	elif scene_file_path == "res://scenes/characters/ranged_virulent.tscn":
		return next_map_position.x < battle_node.top_left_tile.x + 8
		
	return true
		
func within_attack_range() -> bool:
	if abs(battle_node.top_left_tile.x - current_map_position.x) <= attack_range:
		return true
	else:
		return false
	
