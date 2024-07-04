extends Node2D



func _ready():
	if global.isfirstload == true:
		$Player.position = global.playerstartpos
	else:
		$Player.position = global.playerexitpos


func _process(delta):
	change_scene()
	if $bgmusic.playing == false:
		$bgmusic.playing = true


func _on_transition_area_body_entered(body):
	if body.has_method("player_movement"):
		global.is_transition = true
		

func _on_transition_area_body_exited(body):
	
	pass
	
func change_scene():
	if global.is_transition == true:
		if global.curr_scene == "slums":
			get_tree().change_scene_to_file("res://scenes/areas/city.tscn")
			global.isfirstload = false
			global.finish_changescenes()
