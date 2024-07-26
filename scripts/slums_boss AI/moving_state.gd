class_name MovingState
extends State

const BattleNode = preload("res://scripts/battle.gd")

@export var actor: Boss
@export var anim: AnimatedSprite2D
@export var healthbar : TextureProgressBar

@onready var tile_map = get_node("../../..") as TileMap
@onready var battle_node = get_node("../..") as BattleNode
@onready var boss_sfx =  get_node("../../BossSFX") as AudioStreamPlayer2D

var current_map_position : Vector2i
var tween : Tween
var new_position : Vector2
var moving_time : int
var curr_health

#Will move to random positions in the grid, will move 1-3 times to different random positions
#will go to avoid state if took a certain amount of damage

signal moving_finished
signal take_many_damage

const BOSS_STOMP = preload("res://audio/04 - Boss/01 - Stomping/boss-stomp.mp3")
const top_left_tile = Vector2i(9+1, 3)
const bottom_right_tile = Vector2i(23, 10)

func _ready():
	if global.boss_is_defeated:
		return
	set_physics_process(false)

func _enter_state():
	boss_sfx.stream = BOSS_STOMP
	prints("Entered Moving State")
	set_physics_process(true)
	curr_health = healthbar.value
	#record_position()
	
	anim.play("moving")
	randomize_moving_time()
	move_to_new_pos()
	
	await get_tree().create_timer(float(moving_time)+0.1).timeout
	
	if actor.position == new_position:
		record_position()
		moving_finished.emit()

func move_to_new_pos():
	new_position = tile_map.map_to_local(Vector2(randi_range(top_left_tile.x, bottom_right_tile.x), randi_range(top_left_tile.y, bottom_right_tile.y)))
	var new_map_position = tile_map.local_to_map(new_position)

	if new_position.distance_to(actor.position) <= 50:
		moving_time = 1

	
	tween = create_tween()
	anim.play("moving")
	tween.tween_property(actor, "position", new_position, moving_time).set_ease(Tween.EASE_OUT)
	await get_tree().create_timer(moving_time).timeout
	current_map_position = tile_map.local_to_map(actor.position)

func randomize_moving_time():
	moving_time = randi_range(2, 3)

func _physics_process(delta):
	record_position()
	#idk if this correctly checks if certain damage has been recieved
	if curr_health != null:
		if healthbar.value <= curr_health * 0.7:
			print("took a lot of damage")
			take_many_damage.emit()
	current_map_position = tile_map.local_to_map(actor.position)
	
	
func record_position():
	global.enemy_dict.clear()
	var boss_map_pos = tile_map.local_to_map(actor.position)
	global.enemy_dict[boss_map_pos + Vector2i.LEFT] = actor
	global.enemy_dict[boss_map_pos] = actor
	global.enemy_dict[boss_map_pos + Vector2i.RIGHT] = actor
	#print("position recorded", boss_map_pos)

	
	
func _exit_state():
	prints("Exited Moving State")
	set_physics_process(false)
	anim.stop()
