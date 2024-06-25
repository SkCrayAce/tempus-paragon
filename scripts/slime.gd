extends CharacterBody2D

var speed = 40
var player_chase = false
var player = null
var init_pos = null
@onready var anim = $AnimatedSprite2D

func _ready():
	init_pos = position
	anim.play("front_idle")

func _physics_process(delta):
	if player_chase:
		velocity = (player.get_global_position() - position).normalized() * speed * delta
		anim.flip_h = (position > player.position)
		anim.play("side_jumping")

	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.07)
		
	move_and_collide(velocity)

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true
	


func _on_detection_area_body_exited(body):
	player = null
	player_chase = false
	anim.play("side_idle")

