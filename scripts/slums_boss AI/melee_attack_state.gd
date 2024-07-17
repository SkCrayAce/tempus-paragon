class_name MeleeAttackState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar

@onready var tile_map = get_parent().get_parent().get_parent() as TileMap

#Will move towards a random position at the leftmost grid, will damage adjacent player

signal m_attack_finished

const top_left_tile = Vector2i(9+1, 3)
const bottom_right_tile = Vector2i(23, 10)
var tween
var melee_position
var current_map_position

func _enter_state():
	#attack character
	prints("melee attacking")
	
	anim.play("wind_up_melee")
	await anim.animation_finished
	
	move_to_new_pos()
	await get_tree().create_timer(2.1).timeout
	
	if actor.position == melee_position:
		anim.play("attack_melee")
		await anim.animation_finished
		prints("melee attacking done")
		m_attack_finished.emit()
		
	
func move_to_new_pos():
	prints("moving to new pos")
	#random position in grid
	melee_position = tile_map.map_to_local(Vector2(top_left_tile.x, randi_range(top_left_tile.y, bottom_right_tile.y)))
	prints(melee_position, " in ", 2, " seconds")
	var new_map_position = tile_map.local_to_map(melee_position)
	
	tween = create_tween()
	anim.play("moving")
	tween.tween_property(actor, "position", melee_position, 2).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(2).timeout
	current_map_position = tile_map.local_to_map(actor.position)

func _exit_state():
	pass

