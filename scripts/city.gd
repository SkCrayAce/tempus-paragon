extends Node2D


func _ready():
	$CityMusic.volume_db -= 15


func _process(delta):
	change_scene()
	if $CityMusic.playing == false:
		$CityMusic.playing = true
	pass


func _on_transition_area_0_body_entered(body):
	if body.has_method("player_movement"):
		global.is_transition = true

func change_scene():
	if global.is_transition == true:
		if global.curr_scene == "city":
			get_tree().change_scene_to_file("res://scenes/areas/slums.tscn")
			global.finish_changescenes()
