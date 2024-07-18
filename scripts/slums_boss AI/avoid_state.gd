class_name AvoidState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

@onready var tile_map = get_parent().get_parent().get_parent() as TileMap
@onready var avoid_to_marker = get_parent().get_parent().get_parent().find_child("AvoidToPoint") as Marker2D

var avoid_to_position
var new_position
var current_map_position
var tween
var old_position

#After finishing stunned state, it will enter to this state
#or after recieving a certain amount of damage
#Boss gets out of grid and summons a wave of virulents

signal summon_finished

func _enter_state():
	print(avoid_to_marker)
	old_position = tile_map.local_to_map(actor.position)
	print("avoiding")
	avoid_to_position = avoid_to_marker.position
	move_to_new_pos()
	anim.play("laughing")


func move_to_new_pos():
	prints("moving to new pos")
	new_position = tile_map.map_to_local(avoid_to_position)
	prints(new_position, " in ", 2, " seconds")
	var new_map_position = tile_map.local_to_map(new_position)
	prints("new_map_positon: ", new_map_position)
	
	tween = create_tween()
	anim.speed_scale = 2.0
	anim.play("moving")
	tween.tween_property(actor, "position", new_position, 2).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(2).timeout
	anim.speed_scale = 1.0
	current_map_position = tile_map.local_to_map(actor.position)

func delete_pos_on_enemy_dict():
	global.enemy_dict.erase(old_position)

func _exit_state():
	pass
