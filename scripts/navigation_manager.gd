extends Node

var slums_levels = []
var city_levels = []
var underground_levels = []


#mpla == max levels per area
const mpla = 3
const bossfightlevelnum = 4
var area_index = 0
var areas = ["slums", "city", "underground"]
var curr_area
var current_scene : PackedScene
var next_scene


func _ready():
	slums_levels.append(preload("res://scenes/areas/slums1.tscn"))
	slums_levels.append(preload("res://scenes/areas/slums2.tscn"))
	slums_levels.append(preload("res://scenes/areas/slums3.tscn"))
	city_levels.append(preload("res://scenes/areas/city.tscn"))
	city_levels.append(preload("res://scenes/areas/city1.tscn"))
	city_levels.append(preload("res://scenes/areas/city_bf.tscn"))
	underground_levels.append(preload("res://scenes/areas/underground.tscn"))
	underground_levels.append(preload("res://scenes/areas/underground2.tscn"))
	TransitionScreen.on_transition_finished.connect(scene_transition)


func next_level(levels_cleared):
	TransitionScreen.transition_node.play("fade_out")
	var randnum
	if global.levels_cleared % mpla == 0:
		area_index += 1
	
	curr_area = areas[area_index]
	global.curr_area = curr_area
	print(curr_area, " ", global.levels_cleared)
	if curr_area == "slums":
		randnum = randi() % slums_levels.size()
		next_scene = slums_levels[randnum]
		slums_levels.remove_at(randnum)
	elif curr_area == "city":
		randnum = randi() % city_levels.size()
		next_scene = city_levels[randnum]
		city_levels.remove_at(randnum)
	elif curr_area == "underground":
		randnum = randi() % underground_levels.size()
		next_scene = underground_levels[randnum]
		underground_levels.remove_at(randnum)
		
	global.battle_won = false

func scene_transition():
	get_tree().change_scene_to_packed(next_scene)
