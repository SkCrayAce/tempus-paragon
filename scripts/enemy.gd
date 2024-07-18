extends CharacterBody2D

@export var health : int
@export var attack_damage : int
@export var attack_range : int
@export var animated_sprite : AnimatedSprite2D


const BattleNode = preload("res://scripts/battle.gd")
const MeleeVirulentScene = "res://scenes/characters/melee_virulent.tscn"
const RangedVirulentScene = "res://scenes/characters/ranged_virulent.tscn"

@onready var healthbar = $HealthBar as TextureProgressBar
@onready var tile_map = get_parent() as TileMap
@onready var battle_node = get_node("../..") as BattleNode
@onready var animation_timer = get_node("../../AnimationTimer") as Timer
@onready var effect = $AnimationPlayer as AnimationPlayer
@onready var damage_number_origin = $DamageNumberOrigin


var player_chase = false
var player = null
var is_defeated : bool
var is_attacking : bool
var is_waiting : bool
var current_map_position : Vector2i
var tween : Tween
var new_position : Vector2

@onready var kai = get_node("../../DraggableIcons/kai") as Node2D
@onready var emerald = get_node("../../DraggableIcons/emerald") as Node2D
@onready var tyrone = get_node("../../DraggableIcons/tyrone") as Node2D
@onready var bettany = get_node("../../DraggableIcons/bettany") as Node2D



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

	healthbar.max_value = health
	healthbar.value = healthbar.max_value
	animated_sprite.play("side_idle_left")
	animated_sprite.frame_changed.connect(inflict_damage)
	current_map_position = tile_map.local_to_map(position)

func _process(delta):
	current_map_position = tile_map.local_to_map(position)

func action():
	if is_defeated: return
	
	elif within_attack_range() or is_attacking:
		attack_character()
		return

	move_animation()
	current_map_position = tile_map.local_to_map(position)

func hit(damage : int):
	show_damage_numbers.call_deferred(damage)
	
	if is_defeated:
		return
	if is_instance_valid(effect):
		effect.play("hit_flash")
		healthbar.value -= damage
		if healthbar.value <= 0:
			enemy_defeated()
			

func show_damage_numbers(damage : int):
	var number = Label.new()
	
	if not is_instance_valid(number): return
	
	number.label_settings = LabelSettings.new()
	number.text = str(damage)
	number.position = damage_number_origin.position
	number.z_index = 30
	
	var color = Color.RED
	
	number.label_settings.font_color = color
	number.label_settings.font_size = 7
	number.label_settings.outline_color = Color.BLACK
	number.label_settings.outline_size = 2
	
	add_child.call_deferred(number)
	number.pivot_offset = Vector2(number.size/2)
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(number, "position:y", number.position.y - 10, 0.25).set_ease(Tween.EASE_OUT)
	await tween.finished
	number.queue_free()
	
func enemy_defeated():
	is_defeated = true
	global.delete_enemy(current_map_position)
	emit_signal("enemy_died")
	animated_sprite.play("death")
	remove_from_group("enemies")
	animated_sprite.animation_finished.connect(queue_free)
	
	if get_tree().get_node_count() <= 5 :
		tree_exited.connect(battle_node.start_wave)

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
		await animated_sprite.animation_finished
		
	animated_sprite.play("side_idle_left")
	
func attack_character():
	is_attacking = true
	
	if not within_attack_range() or not is_attacking: return
	
	animated_sprite.play("attack")
	await animated_sprite.animation_finished
	#animated_sprite.play("side_idle_left")

	
func inflict_damage():
	if scene_file_path == MeleeVirulentScene:
		if not animated_sprite.animation == "attack" or not animated_sprite.frame == 4:
			return
	elif scene_file_path == RangedVirulentScene:
		if not animated_sprite.animation == "attack" or not animated_sprite.frame == 6:
			return
	
	var kai_aligned = current_map_position.y in kai_hitbox
	var emerald_aligned = current_map_position.y in emerald_hitbox
	var tyrone_aligned = current_map_position.y in tyrone_hitbox
	var bettany_aligned = current_map_position.y in bettany_hitbox
	var back_to_idle = func():
		animated_sprite.stop()
		animated_sprite.play("side_idle_left")
		
	if kai_aligned and not kai.is_defeated : kai.take_damage(attack_damage)
	if emerald_aligned and not emerald.is_defeated: emerald.take_damage(attack_damage)
	if tyrone_aligned and not tyrone.is_defeated : tyrone.take_damage(attack_damage)
	if bettany_aligned and not bettany.is_defeated : bettany.take_damage(attack_damage)
	else: 
		is_attacking = false
		back_to_idle.call()

	
func is_blocked() -> bool:
	var next_position = Vector2(position.x - 16, position.y)
	var next_map_position = tile_map.local_to_map(next_position)
	var next_enemy := global.get_enemy(next_map_position)
	
	if is_instance_valid(next_enemy):
		return next_enemy.is_blocked()
	
	if scene_file_path == MeleeVirulentScene:
		return next_map_position.x < battle_node.top_left_tile.x
	elif scene_file_path == RangedVirulentScene:
		return next_map_position.x < battle_node.top_left_tile.x + attack_range
		
	return true
		
func within_attack_range() -> bool:
	if abs(battle_node.top_left_tile.x - current_map_position.x) <= attack_range:
		return true
	else:
		return false
	
