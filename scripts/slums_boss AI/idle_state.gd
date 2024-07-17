class_name IdleState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar

#Starting state/default state - idle lasts for 1-2 seconds
#will go to avoid state if took a certain amount of damage

signal idle_finished
signal take_many_damage

var curr_health

func _ready():
	set_physics_process(false)
	curr_health = healthbar.value

func _enter_state():
	set_physics_process(true)
	anim.play("idle")
	await get_tree().create_timer(randi_range(3, 4)).timeout
	idle_finished.emit()


func _physics_process(delta):
	if healthbar.value < curr_health * 0.7:
		take_many_damage.emit()

	
func _exit_state():
	set_physics_process(false)
	anim.stop()
