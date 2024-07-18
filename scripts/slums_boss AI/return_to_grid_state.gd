#Will return to a random valid position in grid

class_name ReturnToGridState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

@onready var tile_map = get_node("../../..") as TileMap

var current_map_position
var tween : Tween
var new_position : Vector2
const top_left_tile = Vector2i(9+1, 3)
const bottom_right_tile = Vector2i(23, 10)

signal returned_to_grid

func _ready():
	if global.boss_is_defeated:
		return
	set_physics_process(false)


func _enter_state():
	set_physics_process(true)
	#go to random valid position in grid from being outside the grid
	move_to_new_pos()
	await get_tree().create_timer(2).timeout
	returned_to_grid.emit()

func move_to_new_pos():
	new_position = tile_map.map_to_local(Vector2(randi_range(top_left_tile.x, bottom_right_tile.x), randi_range(top_left_tile.y, bottom_right_tile.y)))
	var new_map_position = tile_map.local_to_map(new_position)

	
	tween = create_tween()
	anim.speed_scale = 2.0
	anim.play("moving")
	tween.tween_property(actor, "position", new_position, 2).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(2).timeout
	anim.speed_scale = 1.0
	current_map_position = tile_map.local_to_map(actor.position)


func _exit_state():
	set_physics_process(false)
