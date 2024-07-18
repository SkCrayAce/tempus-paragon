#Starting state/default state - idle lasts for 1-2 seconds
#will go to avoid state if took a certain amount of damage


class_name IdleState
extends State

@export var actor : Boss
@export var anim : AnimatedSprite2D
@export var healthbar : TextureProgressBar

@onready var tile_map = get_parent().get_parent().get_parent() as TileMap


signal idle_finished
signal take_many_damage

var curr_health

func _ready():
	set_physics_process(false)
	curr_health = healthbar.value

func _enter_state():
	prints("Entered Idle State")
	set_physics_process(true)
	
	var boss_map_pos = tile_map.local_to_map(actor.position)
	#print("idle, current position is: ", boss_map_pos)
	global.enemy_dict[boss_map_pos] = actor
	print("current position in global: ", tile_map.local_to_map(global.enemy_dict[boss_map_pos].position))
	
	anim.play("idle")
	await get_tree().create_timer(randi_range(3, 4)).timeout
	idle_finished.emit()


func _physics_process(delta):
	#idk if this correctly checks if certain damage has been recieved
	if healthbar.value <= curr_health * 0.7:
		take_many_damage.emit()

	
func _exit_state():
	set_physics_process(false)
	prints("Exited Idle State")
	anim.stop()
