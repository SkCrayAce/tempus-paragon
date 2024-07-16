class_name IdleState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D

#Starting state/default state - idle lasts for 1-2 seconds
#will go to avoid state if took a certain amount of damage

signal idle_finished
signal take_many_damage

func _enter_state():
	anim.play("idle")
	await get_tree().create_timer(randi_range(1, 2)).timeout
	idle_finished.emit()

func _exit_state():
	anim.stop()
