class_name IdleState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

#Starting state/default state - idle lasts for 1-2 seconds

signal idle_finished

func _enter_state():
	anim.play("idle")
	await get_tree().create_timer(randi_range(1, 2)).timeout
	idle_finished.emit()

func _exit_state():
	anim.stop()
