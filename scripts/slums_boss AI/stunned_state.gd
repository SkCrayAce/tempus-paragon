class_name StunnedState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar

@onready var tile_map = get_parent().get_parent().get_parent() as TileMap

#If hit by player at during winding up, stun will happen
#Stun will last for 2-4 seconds

signal stun_done

func _enter_state():
	print("Entered Stunned State")
	anim.play("stunned")
	await get_tree().create_timer(randi_range(2, 4)).timeout
	#await anim.animation_finished
	stun_done.emit()
	anim.stop()

func _exit_state():
	prints("Exited Stunned State")
	pass
