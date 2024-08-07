extends Node

var slums_levels = []
var slums_bossfight_area
var city_levels = []
var city_bossfight_area
var underground_levels = []


#mpla == max levels per area
const mpla = 3
var bossfight_done = false
var area_index = 0
var areas = ["slums", "city", "underground"]
var curr_area
var current_scene : PackedScene
var next_scene
var target_scene : PackedScene


func _ready():
	load_levels()
	TransitionScreen.fade_out_finished.connect(transition_finished)

func start_game():
	target_scene = load("res://scenes/areas/slums0.tscn")
	TransitionScreen.play_transition("fade_out")

func next_map():
	target_scene = load(next_scene)
	TransitionScreen.play_transition("fade_out")

func death_screen():
	target_scene = load("res://scenes/death_screen.tscn")
	TransitionScreen.play_transition("fade_out")
	
func transition_finished():
	get_tree().change_scene_to_packed(target_scene)

func next_level(levels_cleared):
	var randnum
	
	if levels_cleared != 0 and levels_cleared % mpla == 0 and bossfight_done == true:
		area_index += 1
		global.levels_cleared = 0
		levels_cleared = global.levels_cleared
		bossfight_done = false
		prints("working, bossfight_done == ", bossfight_done)
	
	
	print("area index is ", area_index, " levels_cleared % mpla = ", levels_cleared % mpla)
	curr_area = areas[area_index]
	global.curr_area = curr_area
	print(curr_area, " ", levels_cleared)
	
	match curr_area:
		"slums":
			if levels_cleared != mpla and bossfight_done == false:
				randnum = randi() % slums_levels.size()
				next_scene = slums_levels[randnum]
				slums_levels.remove_at(randnum)
			elif levels_cleared == mpla and bossfight_done == false:
				next_scene = slums_bossfight_area
				bossfight_done = true
		"city":
			if levels_cleared != mpla and bossfight_done == false:
				randnum = randi() % city_levels.size()
				next_scene = city_levels[randnum]
				city_levels.remove_at(randnum)
				print("city level selected")
			elif levels_cleared == mpla and bossfight_done == false:
				next_scene = slums_bossfight_area
				bossfight_done = true
		"underground":
			if levels_cleared != mpla and bossfight_done == false:
				randnum = randi() % underground_levels.size()
				next_scene = underground_levels[randnum]
				underground_levels.remove_at(randnum)
		
	global.battle_won = false
	target_scene = next_scene
	TransitionScreen.play_transition("fade_out")

func load_levels():
	slums_levels.append(load("res://scenes/areas/slums1.tscn"))
	slums_levels.append(load("res://scenes/areas/slums2.tscn"))
	slums_levels.append(load("res://scenes/areas/slums3.tscn"))
	slums_bossfight_area = load("res://scenes/areas/slums_bf.tscn")
	city_levels.append(load("res://scenes/areas/city.tscn"))
	city_levels.append(load("res://scenes/areas/city1.tscn"))
	city_bossfight_area = load("res://scenes/areas/city_bf.tscn")
	underground_levels.append(load("res://scenes/areas/underground.tscn"))
	underground_levels.append(load("res://scenes/areas/underground2.tscn"))

