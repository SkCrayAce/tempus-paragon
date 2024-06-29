extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
@onready var healthbar = $HealthBar
@onready var move_timer_bar = $"../../MoveTimerBar"
@onready var move_timer = $NextMoveTimer
@export var speed = 60
@export var health = 1000
var player_chase = false
var player = null

func _ready():
	healthbar.value = health
	healthbar.max_value = 1000
	global.add_enemy(self)
	# global.enemy_dict[position] = self
	anim.play("idle")

# func _process(delta):
	
func _physics_process(delta):
	if player_chase:
		# position += (player.position - position)/speed
		global.enemy_position = position
		prints(position)
		anim.play("walk")
		
		if (player.position.x - position.x) > 0: anim.flip_h = false
		else: anim.flip_h = true
		
		if position == Vector2(0, 0): return
	else:
		anim.play("idle")

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true

func _on_detection_area_body_exited(body):
	player = null
	player_chase = false

func _on_next_move_timer_timeout():
	anim.play("walk")
	global.delete_enemy(self)
	position.x += 16
	# position = position.snapped(Vector2(64, 64))
	global.add_enemy(self)
	# position.snapped()

#func update_healthbar():
	#healthbar.value = health

func hit(damage : int):
	prints("Before:", healthbar.value)
	healthbar.value -= damage
	prints("After:", healthbar.value)
	if healthbar.value <= 0:
		#anim.play("death")
		#await anim.animation_finished
		global.delete_enemy(self)
		move_timer_bar.queue_free()
		move_timer.queue_free()
		queue_free()
