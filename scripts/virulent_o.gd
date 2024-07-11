extends CharacterBody2D

var speed = 60
var player_chase = false
var player = null
var init_pos = null
const Player = preload("res://scripts/player.gd")
@onready var BattleScene = "res://scenes/areas/battle.tscn"

@onready var anim = $AnimatedSprite2D
@onready var timer = $Timer

func _ready():
	init_pos = position
	random_idle_anim()

func _physics_process(delta):
	if player_chase:
		velocity = (player.get_global_position() - position).normalized() * speed * delta
		if position > player.position == true:
			anim.play("side_run_left")
		else:
			anim.play("side_run_right")

	else:
		velocity = lerp(velocity, Vector2.ZERO, 0.07)
		
	move_and_collide(velocity)

func random_idle_anim():
	var animations = ["front_idle", "side_idle_left", "side_idle_right"]
	var animation_id = randi() % animations.size()
	var animation_name = animations[animation_id]
	anim.play(animation_name)


func _on_detection_range_body_entered(body):
	if body is Player:
		player = body
		player_chase = true


func _on_detection_range_body_exited(body):
	if body is Player:
		if position > player.position:
			anim.play("side_idle_left")
		else:
			anim.play("side_idle_right")
		player = null
		player_chase = false

func _on_timer_timeout():
	timer.wait_time = randi_range(2, 5)
	if player_chase == false:
		random_idle_anim()


func _on_fight_range_body_entered(body):
	if body is Player:
		global.player_pos_pre_battle = body.position
		global.enemy_pos_at_contact = position
		prints(body is Player)
		get_tree().change_scene_to_file(BattleScene)
