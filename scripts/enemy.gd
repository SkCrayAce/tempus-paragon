extends CharacterBody2D

@export var attack_damage : int

@onready var anim = $AnimatedSprite2D
@onready var healthbar = $HealthBar as ProgressBar
@onready var move_timer_bar = get_node("../../MoveTimerBar") as ProgressBar
@onready var move_timer = get_node("../../EnemyMoveTimer") as Timer
@onready var tile_map = get_parent() as TileMap

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

func _ready():
	current_map_position = tile_map.local_to_map(position)
	health = healthbar.max_value
	healthbar.value = health
	global.add_enemy(current_map_position, self)

	anim.play("idle")
	
func _process(delta):
	current_map_position = tile_map.local_to_map(position)

func action():
	if is_defeated: return
	elif current_map_position.x == 3 or is_attacking:
		attack_character()
		return

	move_animation()
	current_map_position = tile_map.local_to_map(position)

func hit(damage : int):
	healthbar.value -= damage
	prints("enemy health changed:", healthbar.value_changed)
	if healthbar.value <= 0:
		is_defeated = true
		anim.play("death")
		await anim.animation_finished
		anim.stop()
		global.delete_enemy(current_map_position)
		queue_free()
		remove_from_group("enemies")

func move_animation():
	var new_position = Vector2(position.x - 16, position.y)
	var new_map_position = tile_map.local_to_map(new_position)
	var next_enemy := global.get_enemy(new_map_position)
	
	if is_blocked(): return
			

	#if  is_instance_valid(global.enemy_dict.get(new_map_position)) and new_map_position in global.enemy_dict:
		#
	
	is_waiting = false
		
	var previous_map_position = tile_map.local_to_map(position)
	var tween = create_tween()
	move_timer.stop()
	anim.flip_h = true
	anim.stop()
	anim.play("walk")
	tween.tween_property(self, "position", new_position, 0.5).set_ease(Tween.EASE_OUT)
	await anim.animation_finished
	
	move_timer.start()
	global.delete_enemy(previous_map_position)
	global.add_enemy(current_map_position, self)
	anim.play("idle")
	
	current_map_position = tile_map.local_to_map(position)
	
	
	

func attack_character():
	is_attacking = true
	if current_map_position.x != 3: return
	
	if current_map_position.y == 1 or current_map_position.y == 2: kai.take_damage(attack_damage)
	if current_map_position.y == 3 or current_map_position.y == 4: emerald.take_damage(attack_damage)
	if current_map_position.y == 5 or current_map_position.y == 6: tyrone.take_damage(attack_damage)
	if current_map_position.y == 7 or current_map_position.y == 8: bettany.take_damage(attack_damage)
	
func is_blocked() -> bool:
	var new_position = Vector2(position.x - 16, position.y)
	var new_map_position = tile_map.local_to_map(new_position)
	var next_enemy := global.get_enemy(new_map_position)
	
	if  is_instance_valid(next_enemy):
		return next_enemy.is_blocked()
		
	return new_map_position.x == 2
			
