extends Node2D

var used_vectors : Array[Vector2i]
var player_scene : PackedScene = preload("res://scenes/characters/player.tscn")
var virulent_scene: PackedScene = preload("res://scenes/characters/virulent_o.tscn")
var virulent_scene2: PackedScene = preload("res://scenes/characters/virulent_o2.tscn")
var virulent_scenes = []


@onready var player_instance = player_scene.instantiate() as CharacterBody2D
@onready var virulent_instance : CharacterBody2D
@onready var item_instance: Node2D

@export var top_leftmost_spawn_coords : Vector2i
@export var bottom_rightmost_spawn_coords : Vector2i

func _ready():
	global.current_scene = scene_file_path
	prints(global.current_scene)
	AudioPlayer.play_music_level()
	prints("would you lose?")
	virulent_scenes.append(virulent_scene)
	virulent_scenes.append(virulent_scene2)
	
	if global.player_pos_pre_battle and global.battle_won:
		player_instance.position = global.player_pos_pre_battle
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
	

