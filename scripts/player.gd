extends CharacterBody2D


const SPEED = 100.0
var current_direction = "none"
@onready var anim = $AnimatedSprite2D

func _ready():
	anim.play("front_idle")

func _physics_process(delta):
	player_movement(delta)
	
func player_movement(delta):
	if Input.is_action_pressed("move_right"):
		current_direction = "right"
		play_animation(1)                    
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("move_left"):
		current_direction = "left"
		play_animation(1)
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("move_down"):
		current_direction = "down"
		play_animation(1)
		velocity.x = 0
		velocity.y = SPEED
	elif Input.is_action_pressed("move_up"):
		current_direction = "up"
		play_animation(1)
		velocity.x = 0
		velocity.y = -SPEED
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		play_animation(2)
	else:
		play_animation(0)
		velocity.x = 0
		velocity.y = 0
		
	move_and_slide()
	
func play_animation(movement : int):
	var dir = current_direction

	if dir == "right":
		anim.flip_h = false
		if movement == 1: anim.play("side_walk")
		elif movement == 2: anim.play("side_attack")
		else: anim.play("side_idle")
	elif dir == "left":
		anim.flip_h = true
		if movement == 1: anim.play("side_walk")
		elif movement == 2: anim.play("side_attack")
		else: anim.play("side_idle")
	elif dir == "down":
		if movement == 1: anim.play("front_walk")
		elif movement == 2: anim.play("front_attack")		
		else: anim.play("front_idle")
	elif dir == "up":
		if movement == 1: anim.play("back_walk")
		elif movement == 2: anim.play("back_attack")		
		else: anim.play("back_idle")
		
