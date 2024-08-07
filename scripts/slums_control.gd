extends "res://scripts/overworld_control.gd"

var used_vectors : Array[Vector2i]
var player_scene : PackedScene = preload("res://scenes/characters/player.tscn")
var virulent_scene: PackedScene = preload("res://scenes/characters/virulent_o.tscn")
var virulent_scene2: PackedScene = preload("res://scenes/characters/virulent_o2.tscn")
var virulent_scenes = []

var tween


@onready var player_instance = player_scene.instantiate() as CharacterBody2D
@onready var virulent_instance : CharacterBody2D
@onready var item_instance: Node2D
@onready var BattleScene = "res://scenes/areas/battle.tscn"

@export var top_leftmost_spawn_coords : Vector2i
@export var bottom_rightmost_spawn_coords : Vector2i

func _ready():
	super._ready()
	used_vectors.clear()
	prints(global.current_scene, " is the scene mf")
	AudioPlayer.play_music_level()
	prints("would you lose?")
	#for variety
	virulent_scenes.append(virulent_scene)
	virulent_scenes.append(virulent_scene2)
	
	if global.battle_won:
		player_instance.position = global.player_position
		add_child(player_instance)
		#global.current_scene = ""
	
	
func _process(delta):
	#if AudioPlayer.playing == false:
		#AudioPlayer.playing = true
	pass

func generate_random_vector(top_left_coord : Vector2, bottom_right_coord : Vector2) -> Vector2i :
	var rng = RandomNumberGenerator.new()
	while true:
		rng.randomize()
		var random_x = rng.randi_range(top_left_coord.x, bottom_right_coord.x)
		var random_y = rng.randi_range(top_left_coord.y, bottom_right_coord.y)
		var random_vector = Vector2i(random_x, random_y)
		
		if not used_vectors.has(random_vector):
			used_vectors.append(random_vector)
			return random_vector			
	return Vector2i(0, 0)

func spawn_enemy(tile_map : TileMap, top_left : Vector2i, bottom_right : Vector2i):
	var randnum = randi() % virulent_scenes.size()
	virulent_instance = virulent_scenes[randnum].instantiate() as CharacterBody2D
	var random_position = tile_map.map_to_local(generate_random_vector(top_leftmost_spawn_coords, bottom_rightmost_spawn_coords))
	virulent_instance.position = random_position
	add_child(virulent_instance)
	pass

	
func despawn_enemy(enemy_instance : CharacterBody2D):
	remove_child(enemy_instance)
	global.battle_won = false

func player_entry_animation(player_instance, end_position : Vector2):
	global.player_input_enabled = false
	tween = create_tween()
	tween.tween_property(player_instance, "position", end_position, 1)
	await get_tree().create_timer(1).timeout
	player_instance.anim.play("idle")
	global.player_input_enabled = true
