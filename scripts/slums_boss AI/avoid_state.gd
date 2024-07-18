class_name AvoidState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

const BattleScript = preload("res://scripts/battle.gd")

@onready var tile_map = get_node("../../..") as TileMap
@onready var avoid_to_point = get_node("../../../AvoidToPoint") as Marker2D
@onready var battle_node = get_node("../../../..") as BattleScript

var new_position
var tween

#After finishing stunned state, it will enter to this state
#or after recieving a certain amount of damage
#Boss gets out of grid and summons a wave of virulents

signal summon_finished

func _enter_state():
	print("avoiding")
	move_to_new_pos()
	anim.play("laughing")


func move_to_new_pos():
	new_position = avoid_to_point.position
	
	tween = create_tween()
	anim.speed_scale = 2.0
	anim.play("moving")
	tween.tween_property(actor, "position", new_position, 2).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(2).timeout
	anim.speed_scale = 1.0
	battle_node.start_wave()

func _exit_state():
	pass
