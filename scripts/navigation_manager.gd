extends Node

var slums_levels = []
var city_levels = []
var underground_levels = []

#mpla == max levels per area
const mpla = 3
var area_index = 0
var areas = ["slums", "city", "underground"]


func _ready():
	##slums_levels.append(preload("res://scenes/areas/slums.tscn"))
	slums_levels.append(preload("res://scenes/areas/slums2.tscn"))
	slums_levels.append(preload("res://scenes/areas/slums3.tscn"))
	city_levels.append(preload("res://scenes/areas/city.tscn"))
	underground_levels.append(preload("res://scenes/areas/underground.tscn"))
	underground_levels.append(preload("res://scenes/areas/underground2.tscn"))


func next_level(levels_cleared):
	var next_scene
	var randnum
	if levels_cleared % mpla == 0:
		area_index += 1
	
	var curr_area = areas[area_index]
	global.curr_area = curr_area
	print(curr_area, " ", levels_cleared)
	if curr_area == "slums":
		randnum = randi() % slums_levels.size()
		next_scene = slums_levels[randnum]
		get_tree().change_scene_to_packed(next_scene)
		slums_levels.remove_at(randnum)
	elif curr_area == "city":
		randnum = randi() % city_levels.size()
		next_scene = city_levels[randnum]
		get_tree().change_scene_to_packed(next_scene)
		slums_levels.remove_at(randnum)
	elif curr_area == "underground":
		randnum = randi() % slums_levels.size()
		next_scene = underground_levels[randnum]
		get_tree().change_scene_to_packed(next_scene)
		slums_levels.remove_at(randnum)
	
	