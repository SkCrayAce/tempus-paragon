extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var healthbar = $HealthBar
@onready var move_timer_bar = $"../../MoveTimerBar"
@onready var move_timer = $NextMoveTimer 
@onready var tile_map = get_parent()
@export var speed : int

var health : int
var player_chase = false
var player = null
var is_defeated : bool
var map_position : Vector2i

func _ready():
	map_position = tile_map.local_to_map(position)
	health = healthbar.max_value
	healthbar.value = health
	global.add_enemy(self)
	#prints(position)
	anim.play("idle")
	
func _process(delta):
	map_position = tile_map.local_to_map(position)

func action():
	if is_defeated: return
	
	var new_position = Vector2(position.x - 16, position.y)
	var tween = create_tween()
	#move_timer.stop()
	#global.delete_enemy(self)
	move_animation()
	map_position = tile_map.local_to_map(position)
	#move_timer.start()
	#anim.play("idle")
	prints(map_position)

func hit(damage : int):
	prints("Before:", healthbar.value)
	healthbar.value -= damage
	prints("After:", healthbar.value)
	if healthbar.value <= 0:
		is_defeated = true
		anim.play("death")
		await anim.animation_finished
		anim.stop()
		global.delete_enemy(self)
		queue_free()

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
	pass
