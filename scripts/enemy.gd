extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var healthbar = $HealthBar
@onready var move_timer_bar = $"../../MoveTimerBar"
@onready var move_timer = $NextMoveTimer 
@onready var tile_map = get_parent()

var health : int
var player_chase = false
var player = null
var is_defeated : bool
var is_attacking : bool
var map_position : Vector2i

@onready var kai = get_node("../../VBoxContainer/kai") as Node2D
@onready var emerald = get_node("../../VBoxContainer/emerald") as Node2D
@onready var tyrone = get_node("../../VBoxContainer/tyrone") as Node2D
@onready var bettany = get_node("../../VBoxContainer/bettany") as Node2D

func _ready():
	map_position = tile_map.local_to_map(position)
	health = healthbar.max_value
	healthbar.value = health
	global.add_enemy(self)

	anim.play("idle")
	
func _process(delta):
	map_position = tile_map.local_to_map(position)

func action():
	if is_defeated: return
	elif map_position.x == 3 or is_attacking:
		attack_character()
		return
	
	var new_position = Vector2(position.x - 16, position.y)
	var tween = create_tween()
	#move_timer.stop()
	#global.delete_enemy(self)
	move_animation()
	map_position = tile_map.local_to_map(position)
	#move_timer.start()
	#anim.play("idle")

func hit(damage : int):
	healthbar.value -= damage
	if healthbar.value <= 0:
		is_defeated = true
		anim.play("death")
		await anim.animation_finished
		anim.stop()
		global.delete_enemy(self)
		queue_free()
		remove_from_group("enemies")

func move_animation():
	var new_position = Vector2(position.x - 16, position.y)
	var current_position = position
	var tween = create_tween()
	anim.flip_h = true
	anim.stop()
	anim.play("walk")
	tween.tween_property(self, "position", new_position, 0.5).set_ease(Tween.EASE_OUT)
	await anim.animation_finished
	anim.play("idle")
	global.delete_position(current_position)
	global.add_enemy(self)
	

func attack_character():
	is_attacking = true
	if map_position.x != 3: return
	
	if map_position.y == 1 or map_position.y == 2: kai.take_damage(125)
	if map_position.y == 3 or map_position.y == 4: emerald.take_damage(125)
	if map_position.y == 5 or map_position.y == 6: tyrone.take_damage(125)
	if map_position.y == 7 or map_position.y == 8: bettany.take_damage(125)
