extends Control

@onready var return_button = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/ReturnButton as Button
const MAIN_MENU_MUSIC = preload("res://audio/music/main_menu_music.mp3") 


func _ready():
	if AudioPlayer.stream == MAIN_MENU_MUSIC:
		AudioPlayer.set_stream_paused(false)
		
	return_button.pressed.connect(return_to_menu)


func return_to_menu():
	get_tree().change_scene_to_file("res://scenes/mainmenu.tscn")

