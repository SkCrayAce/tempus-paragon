extends CharacterBody2D

@onready var anim = $AnimatedSprite2D
var speed = 60
var player_chase = false
var player = null

func _ready():
	anim.play("idle")

func _physics_process(delta):
	if player_chase:
		position += (player.position - position)/speed
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
