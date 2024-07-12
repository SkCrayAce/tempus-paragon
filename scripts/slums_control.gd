extends Node2D

var used_vectors : Array[Vector2i]
var player_scene : PackedScene = preload("res://scenes/characters/player.tscn")
var virulent_scene: PackedScene = preload("res://scenes/characters/virulent_o.tscn")
var virulent_scene2: PackedScene = preload("res://scenes/characters/virulent_o2.tscn")
var virulent_scenes = []

var tween


@onready var player_instance = player_scene.instantiate() as CharacterBody2D
@onready var virulent_instance : CharacterBody2D
@onready var item_instance: Node2D

@export var top_leftmost_spawn_coords : Vector2i
@export var bottom_rightmost_spawn_coords : Vector2i

func _ready():
	TransitionScreen.transition_node.play("fade_in")
	used_vectors.clear()
	global.current_scene = scene_file_path
	prints(global.current_scene)
	AudioPlayer.play_music_level()
	prints("would you lose?")
	#for variety
	virulent_scenes.append(virulent_scene)
	virulent_scenes.append(virulent_scene2)
	
	if global.battle_won:
		player_instance.position = global.player_position
		add_child(player_instance)
		global.drop_random_item(player_instance.position)
		global.current_scene = ""
	
	
func _process(delta):
	if AudioPlayer.playing == false:
		AudioPlayer.playing = true

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

	
func despawn_enemy(enemy_instance : CharacterBody2D):
	remove_child(enemy_instance)
	global.battle_won = false

func player_entry_animation(player_instance, end_position : Vector2):
	tween = create_tween()
	tween.tween_property(player_instance, "position", end_position, 1)
