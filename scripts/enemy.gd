extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var healthbar = $HealthBar
@onready var move_timer_bar = $"../../MoveTimerBar"
@onready var move_timer = $NextMoveTimer 
# @onready var tilemap 
@export var speed : int

var health : int
var player_chase = false
var player = null

func _ready():
	health = healthbar.max_value
	healthbar.value = health

	global.add_enemy(self)
	# global.enemy_dict[position] = self
	anim.play("idle")

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false

func _on_next_move_timer_timeout():
	var tween = create_tween()
	var new_position = Vector2(position.x - 16, position.y)
	# var enemy_position = 
	move_timer.stop()
	global.delete_enemy(self)
	anim.flip_h = true
	anim.play("walk")
	tween.tween_property(self, "position", new_position, 0.5).set_ease(Tween.EASE_OUT)
	await anim.animation_finished
	move_timer.start()
	anim.play("idle")
	global.add_enemy(self)
	# position.snapped()

func hit(damage : int):
	prints("Before:", healthbar.value)
	healthbar.value -= damage
	prints("After:", healthbar.value)
	if healthbar.value <= 0:
		anim.stop()
		anim.play("death")
		await anim.animation_finished
		global.delete_enemy(self)
		# move_timer_bar.queue_free()
		move_timer.queue_free()
		queue_free()
