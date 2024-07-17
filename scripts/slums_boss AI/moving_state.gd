class_name MovingState
extends State

const BattleNode = preload("res://scripts/battle.gd")

@export var actor: Boss
@export var anim: AnimatedSprite2D
@export var healthbar : TextureProgressBar

@onready var tile_map = get_parent().get_parent().get_parent() as TileMap
@onready var battle_node = get_node("../..") as BattleNode

var current_map_position : Vector2i
var tween : Tween
var new_position : Vector2
var moving_time : int

#Will move to random positions in the grid, will move 1-3 times to different random positions
#will go to avoid state if took a certain amount of damage

signal moving_finished
signal take_many_damage

const top_left_tile = Vector2i(9+1, 3)
const bottom_right_tile = Vector2i(23, 10)

func _enter_state():
	anim.play("moving")
	randomize_moving_time()
	move_to_new_pos()
	
	await get_tree().create_timer(moving_time).timeout
	
	if actor.position == new_position:
		prints("moving finished")
		moving_finished.emit()

func move_to_new_pos():
	prints("moving to new pos")
	#random position in grid
	new_position = tile_map.map_to_local(Vector2(randi_range(top_left_tile.x, bottom_right_tile.x), randi_range(top_left_tile.y, bottom_right_tile.y)))
	prints(new_position, " in ", moving_time, " seconds")
	var new_map_position = tile_map.local_to_map(new_position)
	prints("new_map_positon: ", new_map_position)
	
	tween = create_tween()
	anim.play("moving")
	tween.tween_property(actor, "position", new_position, moving_time).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(moving_time).timeout
	current_map_position = tile_map.local_to_map(actor.position)

func randomize_moving_time():
	moving_time = randi_range(2, 3)

func _process(delta):
	current_map_position = tile_map.local_to_map(actor.position)

func _exit_state():
	anim.stop()
